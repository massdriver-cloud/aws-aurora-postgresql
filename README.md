[![Massdriver][logo]][website]

# aws-aurora-postgres

[![Release][release_shield]][release_url]
[![Contributors][contributors_shield]][contributors_url]
[![Forks][forks_shield]][forks_url]
[![Stargazers][stars_shield]][stars_url]
[![Issues][issues_shield]][issues_url]
[![MIT License][license_shield]][license_url]

Amazon Aurora is a fully managed relational database engine that's compatible with PostgreSQL. Aurora includes a high-performance storage subsystem. Its PostgreSQL-compatible database engines are customized to take advantage of that fast distributed storage. The underlying storage grows automatically as needed. An Aurora cluster volume can grow to a maximum size of 128 tebibytes (TiB). Aurora also automates and standardizes database clustering and replication, which are typically among the most challenging aspects of database configuration and administration.

---

_Note:_ Engine versions and applicable instance types in `massdriver.yaml` are generated via scripts in `hack/`.

## Design

For detailed information, check out our [Operator Guide](operator.md) for this bundle.

## Usage

Our bundles aren't intended to be used locally, outside of testing. Instead, our bundles are designed to be configured, connected, deployed and monitored in the [Massdriver][website] platform.

### What are Bundles?

Bundles are the basic building blocks of infrastructure, applications, and architectures in [Massdriver][website]. Read more [here](https://docs.massdriver.cloud/concepts/bundles).

## Bundle

<!-- COMPLIANCE:START -->

Security and compliance scanning of our bundles is performed using [Bridgecrew](https://www.bridgecrew.cloud/). Massdriver also offers security and compliance scanning of operational infrastructure configured and deployed using the platform.

| Benchmark                                                                                                                                                                                                                                                       | Description                        |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| [![Infrastructure Security](https://www.bridgecrew.cloud/badges/github/massdriver-cloud/aws-aurora-postgres/general)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=massdriver-cloud%2Faws-aurora-postgres&benchmark=INFRASTRUCTURE+SECURITY) | Infrastructure Security Compliance |

| [![CIS AWS](https://www.bridgecrew.cloud/badges/github/massdriver-cloud/aws-aurora-postgres/cis_aws)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=massdriver-cloud%2Faws-aurora-postgres&benchmark=CIS+AWS+V1.2) | Center for Internet Security, AWS Compliance |
| [![PCI-DSS](https://www.bridgecrew.cloud/badges/github/massdriver-cloud/aws-aurora-postgres/pci)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=massdriver-cloud%2Faws-aurora-postgres&benchmark=PCI-DSS+V3.2) | Payment Card Industry Data Security Standards Compliance |
| [![NIST-800-53](https://www.bridgecrew.cloud/badges/github/massdriver-cloud/aws-aurora-postgres/nist)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=massdriver-cloud%2Faws-aurora-postgres&benchmark=NIST-800-53) | National Institute of Standards and Technology Compliance |
| [![ISO27001](https://www.bridgecrew.cloud/badges/github/massdriver-cloud/aws-aurora-postgres/iso)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=massdriver-cloud%2Faws-aurora-postgres&benchmark=ISO27001) | Information Security Management System, ISO/IEC 27001 Compliance |
| [![SOC2](https://www.bridgecrew.cloud/badges/github/massdriver-cloud/aws-aurora-postgres/soc2)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=massdriver-cloud%2Faws-aurora-postgres&benchmark=SOC2)| Service Organization Control 2 Compliance |
| [![HIPAA](https://www.bridgecrew.cloud/badges/github/massdriver-cloud/aws-aurora-postgres/hipaa)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=massdriver-cloud%2Faws-aurora-postgres&benchmark=HIPAA) | Health Insurance Portability and Accountability Compliance |

<!-- COMPLIANCE:END -->

### Params

Form input parameters for configuring a bundle for deployment.

<details>
<summary>View</summary>

<!-- PARAMS:START -->
## Properties

- **`availability`** *(object)*
  - **`autoscaling_mode`** *(string)*: Default: `DISABLED`.
    - **One of**
      - Disabled
      - Database Connections
      - CPU Utilization
  - **`min_replicas`** *(integer)*: Replicas and primary are automatically spread across AWS zones. Minimum: `0`. Maximum: `15`. Default: `0`.
- **`backup`** *(object)*
  - **`retention_period`** *(integer)*: The days to retain backups for. Minimum: `1`. Maximum: `35`. Default: `7`.
  - **`skip_final_snapshot`** *(boolean)*: Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. Default: `False`.
- **`database`** *(object)*
  - **`ca_cert_identifier`** *(string)*: The identifier of the CA certificate for the DB instances. [Learn more](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html). Default: `rds-ca-rsa2048-g1`.
    - **One of**
      - RSA 2048
      - RSA 4096
      - ECC 384
  - **`deletion_protection`** *(boolean)*: Explicitly requires this field to be unset before allowing deletion. Default: `True`.
  - **`source_snapshot`** *(string)*: Cluster or database snapshot ARN. Specifies whether or not to **create** this cluster from a snapshot. Aurora clusters can be restored from cluster snapshots *or* database snapshots. [Learn more](https://docs.massdriver.cloud/runbook/aws/migrating-rds-databases).

    Examples:
    ```json
    "arn:aws:rds::ACCOUNT_NUMBER:db/prod"
    ```

    ```json
    "arn:aws:ec2::ACCOUNT_NUMBER:vpc/vpc-foo"
    ```

  - **`version`** *(string)*: Must be one of: `['11.9', '11.12', '11.13', '11.14', '11.15', '11.16', '11.17', '11.18', '12.7', '12.8', '12.9', '12.10', '12.11', '12.12', '12.13', '13.3', '13.4', '13.5', '13.6', '13.7', '13.8', '13.9', '14.3', '14.4', '14.5', '14.6']`. Default: `14.6`.
- **`networking`** *(object)*
  - **`subnet_type`** *(string)*: Deploy to internal subnets (cannot reach the internet) or private subnets (internet egress traffic allowed). Must be one of: `['internal', 'private']`. Default: `internal`.
- **`observability`** *(object)*
  - **`enable_cloudwatch_logs_export`** *(boolean)*: Default: `True`.
  - **`enhanced_monitoring_interval`** *(integer)*: Monitor the operating system of DB instances in real time. Enhanced Monitoring is stored in Cloudwatch Logs and may incur additional changes. [Learn more](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.html). Default: `0`.
    - **One of**
      - Disabled
      - 1 second
      - 5 seconds
      - 10 seconds
      - 15 seconds
      - 30 seconds
      - 60 seconds
  - **`performance_insights_retention_period`** *(integer)*: Performance Insights is a database performance tuning and monitoring feature that helps you quickly assess the load on your database, and determine when and where to take action. Performance Insights allows non-experts to detect performance problems with an easy-to-understand dashboard that visualizes database load. Default: `0`.
    - **One of**
      - Disabled
      - 1 Week
      - 1 Month
      - 3 Months
      - 6 Months
      - 1 Year
      - 2 Years
## Examples

  ```json
  {
      "__name": "Development",
      "availability": {
          "min_replicas": 0
      },
      "backup": {
          "retention_period": 1,
          "skip_final_snapshot": true
      },
      "database": {
          "deletion_protection": false,
          "instance_class": "db.r6g.large",
          "version": "14.6"
      },
      "networking": {
          "subnet_type": "internal"
      },
      "observability": {
          "enable_cloudwatch_logs_export": false,
          "enhanced_monitoring_interval": 0,
          "performance_insights_retention_period": 0
      }
  }
  ```

  ```json
  {
      "__name": "Development Serverless",
      "availability": {
          "min_replicas": 0
      },
      "backup": {
          "retention_period": 1,
          "skip_final_snapshot": true
      },
      "database": {
          "deletion_protection": false,
          "instance_class": "db.serverless",
          "version": "14.6"
      },
      "networking": {
          "subnet_type": "internal"
      },
      "observability": {
          "enable_cloudwatch_logs_export": false,
          "enhanced_monitoring_interval": 0,
          "performance_insights_retention_period": 0
      }
  }
  ```

  ```json
  {
      "__name": "Production",
      "availability": {
          "min_replicas": 2
      },
      "backup": {
          "retention_period": 35,
          "skip_final_snapshot": false
      },
      "database": {
          "deletion_protection": true,
          "instance_class": "db.r6g.2xlarge",
          "version": "14.6"
      },
      "networking": {
          "subnet_type": "internal"
      },
      "observability": {
          "enable_cloudwatch_logs_export": true,
          "enhanced_monitoring_interval": 60,
          "performance_insights_retention_period": 372
      }
  }
  ```

<!-- PARAMS:END -->

</details>

### Connections

Connections from other bundles that this bundle depends on.

<details>
<summary>View</summary>

<!-- CONNECTIONS:START -->
## Properties

- **`aws_authentication`** *(object)*: . Cannot contain additional properties.
  - **`data`** *(object)*
    - **`arn`** *(string)*: Amazon Resource Name.

      Examples:
      ```json
      "arn:aws:rds::ACCOUNT_NUMBER:db/prod"
      ```

      ```json
      "arn:aws:ec2::ACCOUNT_NUMBER:vpc/vpc-foo"
      ```

    - **`external_id`** *(string)*: An external ID is a piece of data that can be passed to the AssumeRole API of the Security Token Service (STS). You can then use the external ID in the condition element in a role's trust policy, allowing the role to be assumed only when a certain value is present in the external ID.
  - **`specs`** *(object)*
    - **`aws`** *(object)*: .
      - **`region`** *(string)*: AWS Region to provision in.

        Examples:
        ```json
        "us-west-2"
        ```

- **`vpc`** *(object)*: . Cannot contain additional properties.
  - **`data`** *(object)*
    - **`infrastructure`** *(object)*
      - **`arn`** *(string)*: Amazon Resource Name.

        Examples:
        ```json
        "arn:aws:rds::ACCOUNT_NUMBER:db/prod"
        ```

        ```json
        "arn:aws:ec2::ACCOUNT_NUMBER:vpc/vpc-foo"
        ```

      - **`cidr`** *(string)*

        Examples:
        ```json
        "10.100.0.0/16"
        ```

        ```json
        "192.24.12.0/22"
        ```

      - **`internal_subnets`** *(array)*
        - **Items** *(object)*: AWS VCP Subnet.
          - **`arn`** *(string)*: Amazon Resource Name.

            Examples:
            ```json
            "arn:aws:rds::ACCOUNT_NUMBER:db/prod"
            ```

            ```json
            "arn:aws:ec2::ACCOUNT_NUMBER:vpc/vpc-foo"
            ```

          - **`aws_zone`** *(string)*: AWS Availability Zone.

            Examples:
          - **`cidr`** *(string)*

            Examples:
            ```json
            "10.100.0.0/16"
            ```

            ```json
            "192.24.12.0/22"
            ```


          Examples:
      - **`private_subnets`** *(array)*
        - **Items** *(object)*: AWS VCP Subnet.
          - **`arn`** *(string)*: Amazon Resource Name.

            Examples:
            ```json
            "arn:aws:rds::ACCOUNT_NUMBER:db/prod"
            ```

            ```json
            "arn:aws:ec2::ACCOUNT_NUMBER:vpc/vpc-foo"
            ```

          - **`aws_zone`** *(string)*: AWS Availability Zone.

            Examples:
          - **`cidr`** *(string)*

            Examples:
            ```json
            "10.100.0.0/16"
            ```

            ```json
            "192.24.12.0/22"
            ```


          Examples:
      - **`public_subnets`** *(array)*
        - **Items** *(object)*: AWS VCP Subnet.
          - **`arn`** *(string)*: Amazon Resource Name.

            Examples:
            ```json
            "arn:aws:rds::ACCOUNT_NUMBER:db/prod"
            ```

            ```json
            "arn:aws:ec2::ACCOUNT_NUMBER:vpc/vpc-foo"
            ```

          - **`aws_zone`** *(string)*: AWS Availability Zone.

            Examples:
          - **`cidr`** *(string)*

            Examples:
            ```json
            "10.100.0.0/16"
            ```

            ```json
            "192.24.12.0/22"
            ```


          Examples:
  - **`specs`** *(object)*
    - **`aws`** *(object)*: .
      - **`region`** *(string)*: AWS Region to provision in.

        Examples:
        ```json
        "us-west-2"
        ```

<!-- CONNECTIONS:END -->

</details>

### Artifacts

Resources created by this bundle that can be connected to other bundles.

<details>
<summary>View</summary>

<!-- ARTIFACTS:START -->
## Properties

- **`readers`** *(object)*: Authentication parameters for a PostgreSQL database. Cannot contain additional properties.
  - **`data`** *(object)*: Cannot contain additional properties.
    - **`authentication`** *(object)*
      - **`hostname`** *(string)*
      - **`password`** *(string)*
      - **`port`** *(integer)*: Port number. Minimum: `0`. Maximum: `65535`.
      - **`username`** *(string)*
    - **`infrastructure`** *(object)*: Cloud specific PostgreSQL configuration data.
      - **One of**
        - AWS Infrastructure ARN*object*: Minimal AWS Infrastructure Config. Cannot contain additional properties.
          - **`arn`** *(string)*: Amazon Resource Name.

            Examples:
            ```json
            "arn:aws:rds::ACCOUNT_NUMBER:db/prod"
            ```

            ```json
            "arn:aws:ec2::ACCOUNT_NUMBER:vpc/vpc-foo"
            ```

        - GCP Infrastructure Name*object*: GCP Infrastructure Config For Resources With A Name Not A GRN. Cannot contain additional properties.
          - **`name`** *(string)*: Name Of GCP Resource.

            Examples:
            ```json
            "my-cloud-function"
            ```

            ```json
            "my-sql-instance"
            ```

        - Azure Infrastructure Resource ID*object*: Minimal Azure Infrastructure Config. Cannot contain additional properties.
          - **`ari`** *(string)*: Azure Resource ID.

            Examples:
            ```json
            "/subscriptions/12345678-1234-1234-abcd-1234567890ab/resourceGroups/resource-group-name/providers/Microsoft.Network/virtualNetworks/network-name"
            ```

        - Kuberenetes infrastructure config*object*: . Cannot contain additional properties.
          - **`kubernetes_namespace`** *(string)*
          - **`kubernetes_service`** *(string)*
    - **`security`** *(object)*: TBD.
      - **Any of**
        - AWS Security information*object*: Informs downstream services of network and/or IAM policies. Cannot contain additional properties.
          - **`iam`** *(object)*: IAM Policies. Cannot contain additional properties.
            - **`^[a-z-/]+$`** *(object)*
              - **`policy_arn`** *(string)*: AWS IAM policy ARN.

                Examples:
                ```json
                "arn:aws:rds::ACCOUNT_NUMBER:db/prod"
                ```

                ```json
                "arn:aws:ec2::ACCOUNT_NUMBER:vpc/vpc-foo"
                ```

          - **`identity`** *(object)*: For instances where IAM policies must be attached to a role attached to an AWS resource, for instance AWS Eventbridge to Firehose, this attribute should be used to allow the downstream to attach it's policies (Firehose) directly to the IAM role created by the upstream (Eventbridge). It is important to remember that connections in massdriver are one way, this scheme perserves the dependency relationship while allowing bundles to control the lifecycles of resources under it's management. Cannot contain additional properties.
            - **`role_arn`** *(string)*: ARN for this resources IAM Role.

              Examples:
              ```json
              "arn:aws:rds::ACCOUNT_NUMBER:db/prod"
              ```

              ```json
              "arn:aws:ec2::ACCOUNT_NUMBER:vpc/vpc-foo"
              ```

          - **`network`** *(object)*: AWS security group rules to inform downstream services of ports to open for communication. Cannot contain additional properties.
            - **`^[a-z-]+$`** *(object)*
              - **`arn`** *(string)*: Amazon Resource Name.

                Examples:
                ```json
                "arn:aws:rds::ACCOUNT_NUMBER:db/prod"
                ```

                ```json
                "arn:aws:ec2::ACCOUNT_NUMBER:vpc/vpc-foo"
                ```

              - **`port`** *(integer)*: Port number. Minimum: `0`. Maximum: `65535`.
              - **`protocol`** *(string)*: Must be one of: `['tcp', 'udp']`.
        - Security*object*: Azure Security Configuration. Cannot contain additional properties.
          - **`iam`** *(object)*: IAM Roles And Scopes. Cannot contain additional properties.
            - **`^[a-z]+[a-z_]*[a-z]$`** *(object)*
              - **`role`**: Azure Role.

                Examples:
                ```json
                "Storage Blob Data Reader"
                ```

              - **`scope`** *(string)*: Azure IAM Scope.
        - Security*object*: GCP Security Configuration. Cannot contain additional properties.
          - **`iam`** *(object)*: IAM Roles And Conditions. Cannot contain additional properties.
            - **`^[a-z-/]+$`** *(object)*
              - **`condition`** *(string)*: GCP IAM Condition.
              - **`role`**: GCP Role.

                Examples:
                ```json
                "roles/owner"
                ```

                ```json
                "roles/redis.editor"
                ```

                ```json
                "roles/storage.objectCreator"
                ```

                ```json
                "roles/storage.legacyObjectReader"
                ```

  - **`specs`** *(object)*: Cannot contain additional properties.
    - **`rdbms`** *(object)*: Common metadata for relational databases.
      - **`engine`** *(string)*: The type of database server.

        Examples:
        ```json
        "postgresql"
        ```

        ```json
        "mysql"
        ```

      - **`engine_version`** *(string)*: The cloud provider's database version.

        Examples:
        ```json
        "5.7.mysql_aurora.2.03.2"
        ```

      - **`version`** *(string)*: The database version. Default: ``.

        Examples:
        ```json
        "12.2"
        ```

        ```json
        "5.7"
        ```


      Examples:
      ```json
      {
          "engine": "postgresql",
          "engine_version": "10.14",
          "version": "10.14"
      }
      ```

      ```json
      {
          "engine": "mysql",
          "engine_version": "5.7.mysql_aurora.2.03.2",
          "version": "5.7"
      }
      ```

- **`writer`** *(object)*: Authentication parameters for a PostgreSQL database. Cannot contain additional properties.
  - **`data`** *(object)*: Cannot contain additional properties.
    - **`authentication`** *(object)*
      - **`hostname`** *(string)*
      - **`password`** *(string)*
      - **`port`** *(integer)*: Port number. Minimum: `0`. Maximum: `65535`.
      - **`username`** *(string)*
    - **`infrastructure`** *(object)*: Cloud specific PostgreSQL configuration data.
      - **One of**
        - AWS Infrastructure ARN*object*: Minimal AWS Infrastructure Config. Cannot contain additional properties.
          - **`arn`** *(string)*: Amazon Resource Name.

            Examples:
            ```json
            "arn:aws:rds::ACCOUNT_NUMBER:db/prod"
            ```

            ```json
            "arn:aws:ec2::ACCOUNT_NUMBER:vpc/vpc-foo"
            ```

        - GCP Infrastructure Name*object*: GCP Infrastructure Config For Resources With A Name Not A GRN. Cannot contain additional properties.
          - **`name`** *(string)*: Name Of GCP Resource.

            Examples:
            ```json
            "my-cloud-function"
            ```

            ```json
            "my-sql-instance"
            ```

        - Azure Infrastructure Resource ID*object*: Minimal Azure Infrastructure Config. Cannot contain additional properties.
          - **`ari`** *(string)*: Azure Resource ID.

            Examples:
            ```json
            "/subscriptions/12345678-1234-1234-abcd-1234567890ab/resourceGroups/resource-group-name/providers/Microsoft.Network/virtualNetworks/network-name"
            ```

        - Kuberenetes infrastructure config*object*: . Cannot contain additional properties.
          - **`kubernetes_namespace`** *(string)*
          - **`kubernetes_service`** *(string)*
    - **`security`** *(object)*: TBD.
      - **Any of**
        - AWS Security information*object*: Informs downstream services of network and/or IAM policies. Cannot contain additional properties.
          - **`iam`** *(object)*: IAM Policies. Cannot contain additional properties.
            - **`^[a-z-/]+$`** *(object)*
              - **`policy_arn`** *(string)*: AWS IAM policy ARN.

                Examples:
                ```json
                "arn:aws:rds::ACCOUNT_NUMBER:db/prod"
                ```

                ```json
                "arn:aws:ec2::ACCOUNT_NUMBER:vpc/vpc-foo"
                ```

          - **`identity`** *(object)*: For instances where IAM policies must be attached to a role attached to an AWS resource, for instance AWS Eventbridge to Firehose, this attribute should be used to allow the downstream to attach it's policies (Firehose) directly to the IAM role created by the upstream (Eventbridge). It is important to remember that connections in massdriver are one way, this scheme perserves the dependency relationship while allowing bundles to control the lifecycles of resources under it's management. Cannot contain additional properties.
            - **`role_arn`** *(string)*: ARN for this resources IAM Role.

              Examples:
              ```json
              "arn:aws:rds::ACCOUNT_NUMBER:db/prod"
              ```

              ```json
              "arn:aws:ec2::ACCOUNT_NUMBER:vpc/vpc-foo"
              ```

          - **`network`** *(object)*: AWS security group rules to inform downstream services of ports to open for communication. Cannot contain additional properties.
            - **`^[a-z-]+$`** *(object)*
              - **`arn`** *(string)*: Amazon Resource Name.

                Examples:
                ```json
                "arn:aws:rds::ACCOUNT_NUMBER:db/prod"
                ```

                ```json
                "arn:aws:ec2::ACCOUNT_NUMBER:vpc/vpc-foo"
                ```

              - **`port`** *(integer)*: Port number. Minimum: `0`. Maximum: `65535`.
              - **`protocol`** *(string)*: Must be one of: `['tcp', 'udp']`.
        - Security*object*: Azure Security Configuration. Cannot contain additional properties.
          - **`iam`** *(object)*: IAM Roles And Scopes. Cannot contain additional properties.
            - **`^[a-z]+[a-z_]*[a-z]$`** *(object)*
              - **`role`**: Azure Role.

                Examples:
                ```json
                "Storage Blob Data Reader"
                ```

              - **`scope`** *(string)*: Azure IAM Scope.
        - Security*object*: GCP Security Configuration. Cannot contain additional properties.
          - **`iam`** *(object)*: IAM Roles And Conditions. Cannot contain additional properties.
            - **`^[a-z-/]+$`** *(object)*
              - **`condition`** *(string)*: GCP IAM Condition.
              - **`role`**: GCP Role.

                Examples:
                ```json
                "roles/owner"
                ```

                ```json
                "roles/redis.editor"
                ```

                ```json
                "roles/storage.objectCreator"
                ```

                ```json
                "roles/storage.legacyObjectReader"
                ```

  - **`specs`** *(object)*: Cannot contain additional properties.
    - **`rdbms`** *(object)*: Common metadata for relational databases.
      - **`engine`** *(string)*: The type of database server.

        Examples:
        ```json
        "postgresql"
        ```

        ```json
        "mysql"
        ```

      - **`engine_version`** *(string)*: The cloud provider's database version.

        Examples:
        ```json
        "5.7.mysql_aurora.2.03.2"
        ```

      - **`version`** *(string)*: The database version. Default: ``.

        Examples:
        ```json
        "12.2"
        ```

        ```json
        "5.7"
        ```


      Examples:
      ```json
      {
          "engine": "postgresql",
          "engine_version": "10.14",
          "version": "10.14"
      }
      ```

      ```json
      {
          "engine": "mysql",
          "engine_version": "5.7.mysql_aurora.2.03.2",
          "version": "5.7"
      }
      ```

<!-- ARTIFACTS:END -->

</details>

## Contributing

<!-- CONTRIBUTING:START -->

### Bug Reports & Feature Requests

Did we miss something? Please [submit an issue](https://github.com/massdriver-cloud/aws-aurora-postgres/issues) to report any bugs or request additional features.

### Developing

**Note**: Massdriver bundles are intended to be tightly use-case scoped, intention-based, reusable pieces of IaC for use in the [Massdriver][website] platform. For this reason, major feature additions that broaden the scope of an existing bundle are likely to be rejected by the community.

Still want to get involved? First check out our [contribution guidelines](https://docs.massdriver.cloud/bundles/contributing).

### Fix or Fork

If your use-case isn't covered by this bundle, you can still get involved! Massdriver is designed to be an extensible platform. Fork this bundle, or [create your own bundle from scratch](https://docs.massdriver.cloud/bundles/development)!

<!-- CONTRIBUTING:END -->

## Connect

<!-- CONNECT:START -->

Questions? Concerns? Adulations? We'd love to hear from you!

Please connect with us!

[![Email][email_shield]][email_url]
[![GitHub][github_shield]][github_url]
[![LinkedIn][linkedin_shield]][linkedin_url]
[![Twitter][twitter_shield]][twitter_url]
[![YouTube][youtube_shield]][youtube_url]
[![Reddit][reddit_shield]][reddit_url]

<!-- markdownlint-disable -->

[logo]: https://raw.githubusercontent.com/massdriver-cloud/docs/main/static/img/logo-with-logotype-horizontal-400x110.svg

[docs]: https://docs.massdriver.cloud/?utm_source=github&utm_medium=readme&utm_campaign=aws-aurora-postgres&utm_content=docs
[website]: https://www.massdriver.cloud/?utm_source=github&utm_medium=readme&utm_campaign=aws-aurora-postgres&utm_content=website
[github]: https://github.com/massdriver-cloud?utm_source=github&utm_medium=readme&utm_campaign=aws-aurora-postgres&utm_content=github
[slack]: https://massdriverworkspace.slack.com/?utm_source=github&utm_medium=readme&utm_campaign=aws-aurora-postgres&utm_content=slack
[linkedin]: https://www.linkedin.com/company/massdriver/?utm_source=github&utm_medium=readme&utm_campaign=aws-aurora-postgres&utm_content=linkedin

[contributors_shield]: https://img.shields.io/github/contributors/massdriver-cloud/aws-aurora-postgres.svg?style=for-the-badge
[contributors_url]: https://github.com/massdriver-cloud/aws-aurora-postgres/graphs/contributors
[forks_shield]: https://img.shields.io/github/forks/massdriver-cloud/aws-aurora-postgres.svg?style=for-the-badge
[forks_url]: https://github.com/massdriver-cloud/aws-aurora-postgres/network/members
[stars_shield]: https://img.shields.io/github/stars/massdriver-cloud/aws-aurora-postgres.svg?style=for-the-badge
[stars_url]: https://github.com/massdriver-cloud/aws-aurora-postgres/stargazers
[issues_shield]: https://img.shields.io/github/issues/massdriver-cloud/aws-aurora-postgres.svg?style=for-the-badge
[issues_url]: https://github.com/massdriver-cloud/aws-aurora-postgres/issues
[release_url]: https://github.com/massdriver-cloud/aws-aurora-postgres/releases/latest
[release_shield]: https://img.shields.io/github/release/massdriver-cloud/aws-aurora-postgres.svg?style=for-the-badge
[license_shield]: https://img.shields.io/github/license/massdriver-cloud/aws-aurora-postgres.svg?style=for-the-badge
[license_url]: https://github.com/massdriver-cloud/aws-aurora-postgres/blob/main/LICENSE

[email_url]: mailto:support@massdriver.cloud
[email_shield]: https://img.shields.io/badge/email-Massdriver-black.svg?style=for-the-badge&logo=mail.ru&color=000000
[github_url]: mailto:support@massdriver.cloud
[github_shield]: https://img.shields.io/badge/follow-Github-black.svg?style=for-the-badge&logo=github&color=181717
[linkedin_url]: https://linkedin.com/in/massdriver-cloud
[linkedin_shield]: https://img.shields.io/badge/follow-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&color=0A66C2

[twitter_url]: https://twitter.com/massdriver?utm_source=github&utm_medium=readme&utm_campaign=aws-aurora-postgres&utm_content=twitter
[twitter_shield]: https://img.shields.io/badge/follow-Twitter-black.svg?style=for-the-badge&logo=twitter&color=1DA1F2
[discourse_url]: https://community.massdriver.cloud?utm_source=github&utm_medium=readme&utm_campaign=aws-aurora-postgres&utm_content=discourse
[discourse_shield]: https://img.shields.io/badge/join-Discourse-black.svg?style=for-the-badge&logo=discourse&color=000000
[youtube_url]: https://www.youtube.com/channel/UCfj8P7MJcdlem2DJpvymtaQ
[youtube_shield]: https://img.shields.io/badge/subscribe-Youtube-black.svg?style=for-the-badge&logo=youtube&color=FF0000
[reddit_url]: https://www.reddit.com/r/massdriver
[reddit_shield]: https://img.shields.io/badge/subscribe-Reddit-black.svg?style=for-the-badge&logo=reddit&color=FF4500

<!-- markdownlint-restore -->

<!-- CONNECT:END -->
