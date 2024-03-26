resource "aws_db_instance" "component_platform_qa02" {
    allocated_storage                       = 20
    allow_major_version_upgrade             = null
    apply_immediately                       = null
    auto_minor_version_upgrade              = true
    availability_zone                       = "us-west-2b"
    backup_retention_period                 = 0
    backup_window                           = "10:37-11:07"
    ca_cert_identifier                      = "rds-ca-2019"
    character_set_name                      = null
    copy_tags_to_snapshot                   = true
    db_subnet_group_name                    = "db-subnet-group-qa02"
    delete_automated_backups                = true
    deletion_protection                     = false
    domain                                  = ""
    domain_iam_role_name                    = ""
    enabled_cloudwatch_logs_exports         = [ "postgresql" ]
    engine                                  = "postgres"
    engine_version                          = "12.8"
    final_snapshot_identifier               = null
    iam_database_authentication_enabled     = false
    identifier                              = "component-platform-qa02"
    identifier_prefix                       = null
    instance_class                          = "db.t2.micro"
    iops                                    = 0
    kms_key_id                              = ""
    license_model                           = "postgresql-license"
    maintenance_window                      = "sun:07:30-sun:08:00"
    max_allocated_storage                   = 50
    monitoring_interval                     = 0
    monitoring_role_arn                     = ""
    multi_az                                = false
    name                                    = "componentplatform"
    option_group_name                       = "default:postgres-12"
    parameter_group_name                    = "default.postgres12"
    performance_insights_enabled            = false
    performance_insights_kms_key_id         = ""
    performance_insights_retention_period   = 0
    port                                    = 5432
    publicly_accessible                     = false
    replicate_source_db                     = ""

    security_group_names                    = []

    skip_final_snapshot                     = true
    snapshot_identifier                     = null
    storage_encrypted                       = false
    storage_type                            = "gp2"

    tags = {
        backup_plan_enabled = true
    }

    username = "component_platform_qa02"
    password = var.component_platform_db_password

    vpc_security_group_ids = [
        aws_security_group.component_platform_db_qa02_uswest2.id,
    ]
}

resource "aws_route53_record" "rds_component_platform_narvar_internal" {
    zone_id = "Z1WXLHHOPQDEWR"
    name    = "rds-component-platform.narvar.internal"
    type    = "CNAME"
    ttl     = 60
    records = [aws_db_instance.component_platform_qa02.address]
}

resource "aws_security_group" "component_platform_db_qa02_uswest2" {

    description = "component-platform database Security Group"

    egress= [
        {
            cidr_blocks= [
                "0.0.0.0/0"
            ]

            description       = ""
            from_port         = 0
            ipv6_cidr_blocks  = []
            prefix_list_ids   = []
            protocol          = -1
            security_groups   = []
            self              = false
            to_port           = 0
        }
    ]

    ingress= [
        {
            cidr_blocks         = []
            description         = ""
            from_port           = 5432
            ipv6_cidr_blocks    = []
            prefix_list_ids     = []
            protocol            = "tcp"
            security_groups     = [
                "sg-0ffe41b2707d596a5",
                "sg-65d6f51a"
            ]
            self                = false
            to_port             = 5432
        }
    ]

    name                    = "component_platform_db-qa02_uswest2"
    name_prefix             = null
    revoke_rules_on_delete  = null

    tags = {
        Name = "component_platform_db-qa02_uswest2"
    }

    vpc_id = "vpc-f5b9db8c"
}
