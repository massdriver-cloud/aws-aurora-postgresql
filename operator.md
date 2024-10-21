
# AWS Aurora PostgreSQL Combined Runbook

Amazon Aurora is a fully managed relational database engine that's compatible with PostgreSQL. This runbook will guide you through connecting to your Aurora PostgreSQL cluster, troubleshooting common issues, and monitoring your database's performance.

## Connecting to Your Database

### Connect via AWS CLI
Check the status and endpoint of your Aurora cluster:

```sh
aws rds describe-db-clusters --query "DBClusters[?DBClusterIdentifier=='<cluster_identifier>'].[Status, Endpoint, ReaderEndpoint]" --output table
```

> Expect to see the status of the cluster along with the primary and reader endpoints.

### Connect via PostgreSQL
Use the following command to connect to your PostgreSQL database:

```sh
psql -h <host> -U <username> -d <database>
```

Replace `<host>`, `<username>`, and `<database>` with your database's details.

## Troubleshooting Common Issues

### Connection Issues

1. **Check Cluster Status**: Use the AWS CLI to check the cluster's status and ensure it is available:
   
   ```sh
   aws rds describe-db-clusters --query "DBClusters[?DBClusterIdentifier=='<cluster_identifier>'].[Status, Endpoint, ReaderEndpoint]" --output table
   ```

2. **Verify Security Groups**: Ensure that the correct ingress rules are configured in the security group:

   ```sh
   aws ec2 describe-security-groups --group-ids <security_group_id> --query "SecurityGroups[*].[GroupId, IpPermissions]" --output table
   ```

3. **Monitor Active Connections**: In PostgreSQL, check all active connections to see if the database is overloaded:

   ```sql
   SELECT pid, usename, datname, client_addr, application_name, state
   FROM pg_stat_activity;
   ```

### High Latency or Slow Queries

1. **Identify Slow Queries**: Use the following query to identify long-running queries:

   ```sql
   SELECT query, state, waiting, query_start
   FROM pg_stat_activity
   WHERE state <> 'idle'
   ORDER BY query_start DESC;
   ```

2. **Enable Slow Query Logging**: Log queries that take longer than a specified threshold (1000ms in this example):

   ```sql
   ALTER SYSTEM SET log_min_duration_statement = 1000;  -- Logs queries taking more than 1000ms
   SELECT pg_reload_conf();
   ```

3. **Analyze Query Performance**: Analyze a specific table to update statistics for better query performance:

   ```sql
   ANALYZE VERBOSE <table_name>;
   ```

### Deadlock & Blocking Issues

1. **Check for Deadlocks**: Use this query to identify any deadlocks in the database:

   ```sql
   SELECT locktype, relation::regclass, mode, granted, pid, usename, application_name
   FROM pg_locks
   WHERE NOT granted;
   ```

2. **Identify Blocking Queries**: Find queries that are blocking other queries:

   ```sql
   SELECT blocked_locks.pid AS blocked_pid, blocked_activity.usename AS blocked_user, blocking_locks.pid AS blocking_pid, blocking_activity.usename AS blocking_user, blocked_activity.query AS blocked_query, blocking_activity.query AS current_query
   FROM pg_catalog.pg_locks blocked_locks
   JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
   JOIN pg_catalog.pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
   JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
   WHERE NOT blocked_locks.granted;
   ```

## Monitoring & Backup Management

### Backup Verification

1. **List Snapshots**: Use this AWS CLI command to check for available snapshots:

   ```sh
   aws rds describe-db-cluster-snapshots --db-cluster-identifier <cluster_identifier> --query "DBClusterSnapshots[].[DBClusterSnapshotIdentifier, SnapshotCreateTime]" --output table
   ```

2. **Verify Retention Policy**: Check your backup retention settings to ensure backups are kept as per your policy:

   ```sh
   aws rds describe-db-clusters --db-cluster-identifier <cluster_identifier> --query "DBClusters[0].[BackupRetentionPeriod]" --output table
   ```

### Disk Space Usage

1. **Monitor Free Storage Space**: Use CloudWatch to monitor disk space usage for your Aurora PostgreSQL cluster:

   ```sh
   aws cloudwatch get-metric-statistics --namespace "AWS/RDS" --metric-name "FreeStorageSpace" --dimensions Name=DBClusterIdentifier,Value=<cluster_identifier> --statistics Average --period 300 --start-time $(date -u -d '1 hour ago' +"%Y-%m-%dT%H:%M:%SZ") --end-time $(date -u +"%Y-%m-%dT%H:%M:%SZ")
   ```

2. **Reclaim Disk Space**: Reclaim disk space in your PostgreSQL database by running the following commands:

   ```sql
   VACUUM;
   VACUUM FULL;  -- This might lock tables, use it during maintenance windows
   REINDEX DATABASE your_database_name;
   ```

### Monitor Storage Usage by Tables

Use this query to check the disk usage for each table in your database:

```sql
SELECT relname AS "Table", pg_size_pretty(pg_total_relation_size(relid)) AS "Size"
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;
```

## Advanced Monitoring

### Check Replication Status

Ensure that your Aurora PostgreSQL cluster's replication is healthy by running this query:

```sql
SELECT client_addr, state, sent_lsn, write_lsn, flush_lsn, replay_lsn
FROM pg_stat_replication;
```

### Monitor WAL (Write-Ahead Logging) Statistics

Track the statistics of Write-Ahead Logging (WAL) with this query:

```sql
SELECT * FROM pg_stat_wal;
```

### Autovacuum Status

Monitor autovacuum to ensure dead tuples are being cleaned up regularly:

```sql
SELECT relname, last_autovacuum, n_dead_tup
FROM pg_stat_user_tables
WHERE last_autovacuum IS NOT NULL;
```

---

## Additional Resources

- [AWS Aurora Postgres User Guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.AuroraPostgreSQL.html)
- [AWS Aurora User Guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Overview.html)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

---

