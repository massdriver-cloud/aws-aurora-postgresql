# AWS Aurora PostgreSQL

Amazon Aurora (Aurora) is a fully managed relational database engine that's compatible with PostgreSQL. You already know how PostgreSQL combines the speed and reliability of high-end commercial databases with the simplicity and cost-effectiveness of open-source databases. The code, tools, and applications you use today with your existing PostgreSQL databases can be used with Aurora. With some workloads, Aurora can deliver up to three times the throughput of PostgreSQL without requiring changes to most of your existing applications.

Aurora includes a high-performance storage subsystem. Its PostgreSQL-compatible database engines are customized to take advantage of that fast distributed storage. The underlying storage grows automatically as needed. An Aurora cluster volume can grow to a maximum size of 128 tebibytes (TiB). Aurora also automates and standardizes database clustering and replication, which are typically among the most challenging aspects of database configuration and administration.

Aurora is part of the managed database service Amazon Relational Database Service (Amazon RDS). Amazon RDS is a web service that makes it easier to set up, operate, and scale a relational database in the cloud.

## Design Decisions

* Aurora Clusters can only be provisioned on internal or private subnets.
* A KMS key is created for encryption and retained after cluster deletion.
* Tags are copied to snapshots.
* Daily snapshots.
* Root username and password are automatically generated to reduce exposure.
  * Username is generated when not being restored from snapshot, otherwise it will use the snapshots username [note](https://github.com/hashicorp/terraform-provider-aws/pull/9505/files#diff-9d869fc908da636b09ac45e62cd373de7223e04ab7a2279385d6ea31004fcbacR92)
  * Password is reset on snapshot restore
* No schema is created by default.
* No blue/green support as it is not supported for [PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/blue-green-deployments-overview.html) yes.
* Instances AZs are auto-assigned by AWS
* 2 artifacts, one for the writer, one for the readers. If no readers the writer will be present here so you can
  * For applications that dont use load balanced reader, the writer endpoint can be read from
* Minimum retention period for backups is 1 day, as they [cannot be disabled in Aurora](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Managing.Backups.html)

## Caveats


* IAM Authentication is *not* implemented, but on our roadmap. Please add a comment/thumbs up on this [issue](https://github.com/massdriver-cloud/aws-aurora-postgresql/issues/4) and we will prioritize.
* RDS Proxy is *not* implemented, but on our roadmap. Please add a comment/thumbs up on this [issue](https://github.com/massdriver-cloud/aws-aurora-postgresql/issues/3) and we will prioritize.
* Backup Plans are *not* implemented, but on our roadmap. Please add a comment/thumbs up on this [issue](https://github.com/massdriver-cloud/aws-aurora-postgresql/issues/5) and we will prioritize.
* [Custom endpoints](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Overview.Endpoints.html#Aurora.Endpoints.Cluster) aren't currently on our roadmap. Please open a ticket if you need support for this.
* Cluster role associations aren't currently on our roadmap. Please open a ticket if you need support for this.
* Automatic minor version upgrades are disabled. Please open an [issue](https://github.com/massdriver-cloud/aws-aurora-postgresql/issues) if you need support for this.
* No support for Aurora Global. Please open an [issue](https://github.com/massdriver-cloud/aws-aurora-postgresql/issues) if you need support for this.
* No support for non-Aurora Clusters. Please open an [issue](https://github.com/massdriver-cloud/aws-aurora-postgresql/issues) if you need support for this.


## Links

* [AWS Aurora Postgres User Guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.AuroraPostgreSQL.html)
* [AWS Aurora User Guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Overview.html)
* [AWS Aurora Serverless v2 Guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.html)
* [TLS w/ Serverless v2](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2-administration.html#aurora-serverless-v2.tls)
