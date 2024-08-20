## AWS RDS PostgreSQL

Amazon RDS for PostgreSQL provides a fully managed relational database service that simplifies the setup, operation, and scaling of PostgreSQL deployments in the cloud.

### Design Decisions

1. **Encryption**: The database is encrypted using a KMS key, ensuring that the data at rest is secure.
2. **Backup and Recovery**: Automated backups are configured with a user-defined retention period. Final snapshots can be skipped or configured based on user preferences.
3. **Network and Security**: The database is placed in a specific subnet group and security group, ensuring controlled access and network isolation.
4. **Scaling**: Autoscaling for read replicas is supported, allowing the database to handle increasing or decreasing workloads dynamically.
5. **Monitoring**: CloudWatch logging and enhanced monitoring are configurable to provide insights into database performance.
6. **Parameter Management**: While the module supports flexibility in how instances are generated, it avoids complex dynamic blocks to prevent configuration issues.

### Runbook

#### Connection Issues

To diagnose connection issues, check the security groups and subnet configurations.

Verify security group rules:

```sh
aws ec2 describe-security-groups --group-id ${SECURITY_GROUP_ID}
```

Confirm that the security group allows access to the PostgreSQL port (default 5432).

#### Database Performance Issues

Investigate the performance metrics using AWS CloudWatch.

List recent CloudWatch metrics for the RDS instance:

```sh
aws cloudwatch get-metric-statistics --namespace "AWS/RDS" --metric-name "CPUUtilization" --start-time $(date -u -d '1 hour ago' +%FT%TZ) --end-time $(date -u +%FT%TZ) --period 300 --statistics "Average" --dimensions Name=DBInstanceIdentifier,Value=${DB_INSTANCE_IDENTIFIER}
```

This command retrieves the average CPU utilization for the past hour. High CPU utilization may indicate that the instance class needs to be upgraded.

#### Slow Queries

To identify slow queries, utilize the PostgreSQL `pg_stat_statements` extension if enabled.

Connect to PostgreSQL:

```sh
psql "host=${DB_HOST} port=${DB_PORT} dbname=${DB_NAME} user=${DB_USER} password=${DB_PASSWORD}"
```

Run the following SQL to get the list of slow queries:

```sql
SELECT query, total_time, calls FROM pg_stat_statements ORDER BY total_time DESC LIMIT 5;
```

This will list the top 5 queries based on the total execution time.

#### Debugging Backup Failures

Examine the RDS logs and recent events for backup failures.

Check recent events:

```sh
aws rds describe-events --source-identifier ${DB_INSTANCE_IDENTIFIER} --source-type db-instance --duration 60
```

This retrieves events from the past 60 minutes for the specified RDS instance. Look for entries related to backup failures.

#### Storage Threshold Alerts

If alarms based on storage thresholds are triggered, investigate immediately.

List current alarms:

```sh
aws cloudwatch describe-alarms --alarm-names ${ALARM_NAME}
```

Examine the metrics leading to the alarm being triggered:

```sh
aws cloudwatch get-metric-statistics --namespace "AWS/RDS" --metric-name "VolumeBytesUsed" --start-time $(date -u -d '1 day ago' +%FT%TZ) --end-time $(date -u +%FT%TZ) --period 3600 --statistics "Maximum" --dimensions Name=DBClusterIdentifier,Value=${DB_CLUSTER_IDENTIFIER}
```

Evaluate if the RDS cluster is nearing its maximum storage capacity.

Always ensure to replace `${VARIABLE}` with appropriate values specific to your RDS instance when running the commands.

