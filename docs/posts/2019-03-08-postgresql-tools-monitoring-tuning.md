# 🐘 PostgreSQL Tools — Monitoring & Tuning

A collection of useful PostgreSQL queries to monitor database performance, find bottlenecks, and optimize your database.

---

## 📊 Database & Table Sizes

### Get Database Size

```sql
SELECT 
  pg_database.datname, 
  pg_database_size(pg_database.datname),
  pg_size_pretty(pg_database_size(pg_database.datname))
FROM pg_database 
ORDER BY 2 DESC;
```

### Get Table Size and Index Size

```sql
SELECT 
  table_name,
  pg_size_pretty(table_size) AS table_size,
  pg_size_pretty(indexes_size) AS indexes_size,
  pg_size_pretty(total_size) AS total,
  to_char((indexes_size / total_size::float) * 100.0, '999D99%') AS "%indexes/total",
  to_char((total_size / 916681971175.0) * 100.0, '999D99%') AS "%total/db"
FROM (
  SELECT
    table_name,
    pg_table_size(table_name) AS table_size,
    pg_indexes_size(table_name) AS indexes_size,
    pg_total_relation_size(table_name) AS total_size
  FROM (
    SELECT ('"' || table_schema || '"."' || table_name || '"') AS table_name
    FROM information_schema.tables
  ) AS all_tables
  ORDER BY total_size DESC
) AS pretty_sizes 
LIMIT 20;
```

---

## 🔍 Index Management

### Get Index Size and Usage Statistics

```sql
SELECT 
  TableName,
  IndexName,
  TotalRows,
  pg_size_pretty(TableSize),
  pg_size_pretty(IndexSize),
  TotalNumberOfScan,
  TotalTupleRead
FROM (
  SELECT
    pt.tablename AS TableName,
    t.indexname AS IndexName,
    pc.reltuples AS TotalRows,
    pg_relation_size(quote_ident(pt.tablename)::text) as TableSize,
    pg_relation_size(quote_ident(t.indexrelname)::text) AS IndexSize,
    t.idx_scan AS TotalNumberOfScan,
    t.idx_tup_read AS TotalTupleRead,
    t.idx_tup_fetch AS TotalTupleFetched
  FROM pg_tables AS pt
  LEFT OUTER JOIN pg_class AS pc 
    ON pt.tablename=pc.relname
  LEFT OUTER JOIN (
    SELECT 
      pc.relname AS TableName,
      pc2.relname AS IndexName,
      psai.idx_scan,
      psai.idx_tup_read,
      psai.idx_tup_fetch,
      psai.indexrelname
    FROM pg_stat_user_indexes AS psai
    JOIN pg_class AS pc ON psai.relid = pc.oid
    JOIN pg_class AS pc2 ON psai.indexrelid = pc2.oid
  ) AS t ON pt.tablename = t.TableName
) AS indexes
ORDER BY TotalNumberOfScan DESC;
```

### Find Unused Indexes

```sql
SELECT
  PSUI.indexrelid::regclass AS IndexName,
  PSUI.relid::regclass AS TableName
FROM pg_stat_user_indexes AS PSUI
JOIN pg_index AS PI ON PSUI.IndexRelid = PI.Indexrelid
WHERE PSUI.idx_scan = 0
  AND PI.indisunique IS FALSE;
```

### Find Unused Indexes with Size

```sql
SELECT 
  TableName,
  IndexName,
  TotalRows,
  pg_size_pretty(TableSize) as Table_Size,
  pg_size_pretty(IndexSize) as Index_Size
FROM (
  SELECT
    pt.tablename AS TableName,
    t.indexname AS IndexName,
    pc.reltuples AS TotalRows,
    pg_relation_size(quote_ident(pt.tablename)::text) as TableSize,
    pg_relation_size(quote_ident(t.indexrelname)::text) AS IndexSize,
    t.idx_scan AS TotalNumberOfScan
  FROM pg_tables AS pt
  LEFT OUTER JOIN pg_class AS pc ON pt.tablename=pc.relname
  LEFT OUTER JOIN (
    SELECT 
      pc.relname AS TableName,
      pc2.relname AS IndexName,
      psai.idx_scan,
      psai.indexrelname
    FROM pg_stat_user_indexes AS psai
    JOIN pg_class AS pc ON psai.relid = pc.oid
    JOIN pg_class AS pc2 ON psai.indexrelid = pc2.oid
  ) AS t ON pt.tablename = t.TableName
) AS indexes
WHERE TotalNumberOfScan = 0
ORDER BY Table_Size DESC;
```

### Find Duplicate Indexes

```sql
SELECT
  indrelid::regclass AS TableName,
  array_agg(indexrelid::regclass) AS Indexes
FROM pg_index 
GROUP BY indrelid, indkey 
HAVING COUNT(*) > 1;
```

---

## 🔎 Long Running Queries

### Find Long Running Queries

```sql
SELECT 
  pid,
  now() - pg_stat_activity.query_start AS duration,
  query,
  state
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes';
```

> **Note:** If `state` is `idle`, you don't need to worry. Active queries may be causing performance issues.

### Cancel a Query

```sql
SELECT pg_cancel_backend(__pid__);
```

> This may take a few seconds.

### Terminate a Query

```sql
SELECT pg_terminate_backend(__pid__);
```

> ⚠️ **Be careful!** This terminates the entire process and may require a full database restart to recover consistency.

---

## 📈 Performance Monitoring

### Check PostgreSQL Version

```sql
SELECT version();
```

### Get Client IP Addresses Connecting to PostgreSQL

```sql
SELECT client_addr, count(*) as total 
FROM pg_stat_activity 
GROUP BY client_addr
ORDER BY total DESC 
LIMIT 5;
```

### Classify Table by Read/Write Operations

```sql
SELECT 
  relname AS TableName,
  pg_size_pretty(pg_relation_size(quote_ident(relname)::text)) AS size,
  TotalTupleRead,
  TotalTupleWrite,
  TotalInsertedRows,
  TotalUpdatedRows,
  TotalDeletedRows,
  CASE
    WHEN TotalTupleRead = 0 AND TotalTupleWrite = 0 THEN 'Unused'
    WHEN TotalTupleRead = 0 THEN 'No read'
    WHEN TotalTupleWrite = 0 THEN 'No write'
    WHEN TotalTupleWrite <= TotalTupleRead * 0.2 THEN 'Read table'
    WHEN TotalTupleWrite >= TotalTupleRead * 0.8 THEN 'Write table'
    ELSE 'Balance table'
  END AS Type
FROM (
  SELECT 
    relname,
    seq_scan,
    idx_scan,
    (seq_tup_read + idx_tup_fetch) as TotalTupleRead,
    n_tup_ins AS TotalInsertedRows,
    n_tup_upd AS TotalUpdatedRows,
    n_tup_del AS TotalDeletedRows,
    (n_tup_ins + n_tup_upd + n_tup_del) AS TotalTupleWrite
  FROM pg_stat_user_tables
) AS pretty_sizes
ORDER BY TotalTupleWrite DESC;
```

---

## 🧹 Maintenance

### Reset Statistics

```sql
SELECT pg_stat_reset();
```

### Monitor Autovacuum and Autoanalyze

```sql
SELECT 
  relname, 
  n_live_tup, 
  n_dead_tup,
  trunc(100*n_dead_tup/(n_live_tup+1))::float "ratio%",
  to_char(last_autovacuum, 'YYYY-MM-DD HH24:MI:SS') as autovacuum_date,
  to_char(last_autoanalyze, 'YYYY-MM-DD HH24:MI:SS') as autoanalyze_date
FROM pg_stat_all_tables
WHERE schemaname = 'public'
ORDER BY n_live_tup DESC, last_autovacuum;
```

### Check if UPDATE Query Rewrote Table

```sql
SELECT relfilenode FROM pg_class WHERE relname = 'parcel';
```

---

## 📚 References

- [Anvesh Patel: PostgreSQL Index Statistics](https://www.dbrnd.com/2017/01/postgresql-script-to-find-index-size-index-usage-statistics-of-a-database-pg_stat_all_indexes/)
- [Peterbe: Weight of PostgreSQL Tables](https://www.peterbe.com/plog/weight-of-your-postgresql-tables)
- [Anderson Dias: Finding and Killing Long-Running Queries](https://medium.com/little-programming-joys/finding-and-killing-long-running-queries-on-postgres-7c4f0449e86d)

---

`#postgresql` `#database` `#monitoring` `#tuning` `#performance` `#devops`