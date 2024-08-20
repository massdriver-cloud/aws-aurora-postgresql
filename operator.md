## AWS Aurora PostgreSQL

Amazon Aurora PostgreSQL is a fully managed relational database engine that combines the performance and availability of high-end commercial databases with the simplicity and cost-effectiveness of open-source databases. It is compatible with PostgreSQL, making it easy to migrate existing PostgreSQL applications without changes to the code.

### Design Decisions

1. **Database Encryption**: Uses AWS KMS for encryption with key rotation enabled to enhance security.
2. **Network**: Limits exposure by setting up Security Groups and subnets for controlled inbound access.
3. **Authentication**: Automatically generates unique root usernames and passwords for database access.
4. **Scaling**: Configured for automatic scaling with defined policy parameters for handling load.
5. **Observability**: Integrates with CloudWatch for enhanced logging and monitoring.
6. **Storage Management**: Configured with backup strategies, encryption, and tagging for snapshots.
7. **Performance Insights**: Option to enable insights for detailed performance analysis.

### Runbook

#### Connection Issues

If unable to connect to the Aurora PostgreSQL cluster:

Check the cluster's current status and endpoint information:

```sh
aws rds describe-db-clusters --query "DBClusters[?DBClusterIdentifier=='<cluster_identifier>'].[Status, Endpoint, ReaderEndpoint]" --output table
```

> Expect to see the status of the cluster along with the primary and reader endpoints.

Verify the security group rules to ensure proper ingress rules are set up:

```sh
aws ec2 describe-security-groups --group-ids <security_group_id> --query "SecurityGroups[*].[GroupId, IpPermissions]" --output table
```

> Confirm that the ingress rules allow traffic from your IP or subnet.

#### High Latency Queries

If queries are running slow, use the following commands to identify problematic queries:

Connect to your PostgreSQL instance and check for slow queries:

```sql
SELECT query, state, waiting, query_start
FROM pg_stat_activity
WHERE state <> 'idle'
ORDER BY query_start DESC;
```

> Look for queries that have been running for a long time and investigate their execution plans.

Enable and review PostgreSQL's slow query log:

```sql
ALTER SYSTEM SET log_min_duration_statement = 1000;  -- Logs queries that take longer than 1000ms
SELECT pg_reload_conf();
```

> This will log slow queries to help identify and optimize them.

#### Backup Verification

Ensure your backups are being created and managed as expected.

List the available snapshots for your Aurora PostgreSQL cluster:

```sh
aws rds describe-db-cluster-snapshots --db-cluster-identifier <cluster_identifier> --query "DBClusterSnapshots[].[DBClusterSnapshotIdentifier, SnapshotCreateTime]" --output table
```

> Verify that snapshots are created according to your backup policy.

Check backup retention settings:

```sh
aws rds describe-db-clusters --db-cluster-identifier <cluster_identifier> --query "DBClusters[0].[BackupRetentionPeriod]" --output table
```

> Ensure that the retention period is set according to your organization's policy.

#### Disk Space Usage

Monitor and manage the disk space usage for your Aurora PostgreSQL cluster.

Check the current disk space usage metrics:

```sh
aws cloudwatch get-metric-statistics --namespace "AWS/RDS" --metric-name "FreeStorageSpace" --dimensions Name=DBClusterIdentifier,Value=<cluster_identifier> --statistics Average --period 300 --start-time $(date -u -d '1 hour ago' +"%Y-%m-%dT%H:%M:%SZ") --end-time $(date -u +"%Y-%m-%dT%H:%M:%SZ")
```

> Monitor the free storage space to ensure you do not run out of disk space.

Reclaiming disk space in PostgreSQL:

```sql
VACUUM;
VACUUM FULL;  -- This might lock tables, use it during maintenance windows
REINDEX DATABASE your_database_name;
```

> Regular maintenance tasks like vacuum and reindex help to reclaim space and improve performance.

