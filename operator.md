# AWS Aurora PostgreSQL

Amazon Aurora (Aurora) is a fully managed relational database engine that's compatible with PostgreSQL. You already know how PostgreSQL combines the speed and reliability of high-end commercial databases with the simplicity and cost-effectiveness of open-source databases. The code, tools, and applications you use today with your existing PostgreSQL databases can be used with Aurora. With some workloads, Aurora can deliver up to three times the throughput of PostgreSQL without requiring changes to most of your existing applications.

Aurora includes a high-performance storage subsystem. Its PostgreSQL-compatible database engines are customized to take advantage of that fast distributed storage. The underlying storage grows automatically as needed. An Aurora cluster volume can grow to a maximum size of 128 tebibytes (TiB). Aurora also automates and standardizes database clustering and replication, which are typically among the most challenging aspects of database configuration and administration.

Aurora is part of the managed database service Amazon Relational Database Service (Amazon RDS). Amazon RDS is a web service that makes it easier to set up, operate, and scale a relational database in the cloud.

## Notes

ACU - 2GB / 1 ACU

## Design Decisions

* Aurora Clusters can only be provisioned on internal or private subnets.
* A KMS key is created for encryption and retained after cluster deletion.
* Tags are copied to snapshots.
* Root username and password are automatically generated to reduce exposure.
* No support for Aurora Global (File an issue)
* No support for non-Aurora Clusters (See RDS Bundle)
* No blue/green support as it is not supported for [PostgreSQL yet](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/blue-green-deployments-overview.html)
* Instances AZs are auto-assigned by AWS
* 2 artifacts, one for the writer, one for the readers. If no readers the writer will be present here so you can 
  * For applications that dont use load balanced reader, the writer endpoint can be read from

## Caveats
* [Custom endpoints](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Overview.Endpoints.html#Aurora.Endpoints.Cluster) aren't supported at this time, please open a ticket if you need support for this.
* Cluster role associations aren't supported at this time. Please open an issue if you need support.
* IAM auth isnt supported at this time. Please open an issue if you need support.

## WIP

* [ ] app & svlss scaling
  * if db.serverless a depenency that shows serverless autoscaling
* [ ] snapshot restore
* [ ] metrics / alarms
* [ ] using instance pools to do an instance type swap, how does major upgrade effect?

* [ ] examples (development, development-serverless, production, production-serverless)
* [ ] make public
* [ ] UI & descriptions
* [ ] test tls w/ the rails app https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html
* [ ] sync to aws-aurora-mysql
* [ ] deprecate aurora serverless
* [ ] https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-postgresql-planning/methods.html
  * https://medium.com/arvind-blogs/migrating-self-managed-postgresql-9-6-to-aws-aurora-postgresql-12-7-or-13-4-ff8f6d42434d
  * https://aws.amazon.com/blogs/database/migrating-legacy-postgresql-databases-to-amazon-rds-or-aurora-postgresql-using-bucardo/

PUNT:
* [ ] RDS Proxy
* [ ] extract as public module
* [ ] IAM Auth 
  * https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/UsingWithRDS.IAMDBAuth.IAMPolicy.html
  * https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/UsingWithRDS.IAMDBAuth.DBAccounts.html
* [ ] automated backups
  * [ ] terraform module to run lambda to do hourly backups & expiration of manual snapshots
* Serverless Wal ? kinesis?
* serverless pgdash (https://docs.pgdash.io/self-hosted)
* [ ] make: watch src & masssdriver.yaml, republish, foreach example, mass deploy __slug: svlsdev for testing...
* [ ] json-schemas repo (networking)
  * [ ] rfcs/ # actual schemas for real rfcs
  * [ ] k8s/ # real JSON Schema for k8s stuff
  * [ ] massdriver/properties # our opinions on params … ie alarm input
  * [ ] massdriver/controls # fancy UI tricks ie conditional alarm input

## Links

* [AWS Aurora Postgres User Guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.AuroraPostgreSQL.html)
* [AWS Aurora User Guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Overview.html)
* [AWS Aurora Serverless v2 Guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.html)
* [TLS w/ Serverless v2](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2-administration.html#aurora-serverless-v2.tls)
