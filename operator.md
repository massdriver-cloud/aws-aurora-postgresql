# AWS Aurora PostgreSQL

Amazon Aurora (Aurora) is a fully managed relational database engine that's compatible with PostgreSQL. You already know how PostgreSQL combines the speed and reliability of high-end commercial databases with the simplicity and cost-effectiveness of open-source databases. The code, tools, and applications you use today with your existing PostgreSQL databases can be used with Aurora. With some workloads, Aurora can deliver up to three times the throughput of PostgreSQL without requiring changes to most of your existing applications.

Aurora includes a high-performance storage subsystem. Its PostgreSQL-compatible database engines are customized to take advantage of that fast distributed storage. The underlying storage grows automatically as needed. An Aurora cluster volume can grow to a maximum size of 128 tebibytes (TiB). Aurora also automates and standardizes database clustering and replication, which are typically among the most challenging aspects of database configuration and administration.

Aurora is part of the managed database service Amazon Relational Database Service (Amazon RDS). Amazon RDS is a web service that makes it easier to set up, operate, and scale a relational database in the cloud.

## Design Decisions

* Aurora Clusters can only be provisioned on internal or private subnets.
* A KMS key is created for encryption and retained after cluster deletion.
* Tags are copied to snapshots.
* Daily snapshots are configured.
* Root username and password are automatically generated to reduce exposure.
  * Username is generated when not being restored from snapshot, otherwise it will use the snapshots username [note](https://github.com/hashicorp/terraform-provider-aws/pull/9505/files#diff-9d869fc908da636b09ac45e62cd373de7223e04ab7a2279385d6ea31004fcbacR92)
  * Password is reset on snapshot restore
* No schema is created by default.
* No blue/green support as it is not supported for [PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/blue-green-deployments-overview.html) yes.
* Instances AZs are auto-assigned by AWS
* 2 artifacts, one for the writer, one for the readers. If no readers the writer will be present here so you can
  * For applications that dont use load balanced reader, the writer endpoint can be read from
* Minimum retention period for backups is 1 day, as they [cannot be disabled in Aurora](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Managing.Backups.html)

## Runbook

### Connection Issues

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

### High Latency Queries

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

### Backup Verification

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

### Disk Space Usage

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



## Links

* [AWS Aurora Postgres User Guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.AuroraPostgreSQL.html)
* [AWS Aurora User Guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Overview.html)
* [AWS Aurora Serverless v2 Guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.html)
* [TLS w/ Serverless v2](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2-administration.html#aurora-serverless-v2.tls)
