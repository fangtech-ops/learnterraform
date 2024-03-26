resource "aws_eks_cluster" "eks_master" {
  name     = "eks-${local.vpc_shortname}"
  role_arn = "arn:aws:iam::${local.account_id}:role/eks-master-role"
  version  = "1.20"

  vpc_config {
    subnet_ids         = flatten([split(",", var.private_subnets), split(",", var.public_subnets)])
    security_group_ids = [aws_security_group.eks_master.id]
  }
}

resource "aws_security_group" "eks_master" {
  name        = "eks_master-${local.vpc_name}"
  description = "EKS Master Security Group"
  vpc_id      = var.vpc_id

  tags = {
    "Name"                                             = "eks_master-${local.vpc_name}"
    "kubernetes.io/cluster/eks-${local.vpc_shortname}" = "owned"
  }
}

resource "aws_security_group" "eks_worker" {
  name        = "eks_worker-${local.vpc_name}"
  description = "EKS Worker Security Group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                                             = "eks_worker-${local.vpc_name}"
    "kubernetes.io/cluster/eks-${local.vpc_shortname}" = "owned"
  }
}

resource "aws_security_group_rule" "eks_master_ingress_rule" {
  security_group_id        = aws_security_group.eks_master.id
  source_security_group_id = aws_security_group.eks_worker.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_master_egress_rule" {
  security_group_id        = aws_security_group.eks_master.id
  source_security_group_id = aws_security_group.eks_worker.id
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  type                     = "egress"
}

resource "aws_security_group" "eks_alb_443" {
  name        = "eks_alb_443-${local.vpc_name}"
  description = "EKS ALB Port 443 Security Group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "eks_alb_443-${local.vpc_name}"
  }
}

resource "aws_security_group" "eks_alb_80" {
  name        = "eks_alb_80-${local.vpc_name}"
  description = "EKS ALB Port 80 Security Group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ingress-rule-1"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]
  }

  ingress {
    description = "ingress-rule-2"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.qa01_vpc_cidr]
  }

  tags = {
    "Name" = "eks_alb_80-${local.vpc_name}"
  }
}

resource "aws_security_group" "eks_alb_8080" {
  name        = "eks_alb_8080-${local.vpc_name}"
  description = "EKS ALB Port 8080 Security Group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ingress-rule-1"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]
  }

  ingress {
    description = "ingress-rule-2"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.qa01_vpc_cidr]
  }

  tags = {
    "Name" = "eks_alb_8080-${local.vpc_name}"
  }
}

resource "aws_security_group" "eks_alb_443_internal" {
  name        = "eks_alb_443-internal-${local.vpc_name}"
  description = "EKS ALB Port 443 Internal Security Group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr, var.qa01_vpc_cidr]
  }

  tags = {
    "Name" = "eks_alb_443-internal-${local.vpc_name}"
  }
}

resource "aws_security_group_rule" "eks_worker_ingress_self" {
  security_group_id        = aws_security_group.eks_worker.id
  source_security_group_id = aws_security_group.eks_worker.id
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_worker_ingress_master" {
  security_group_id        = aws_security_group.eks_worker.id
  source_security_group_id = aws_security_group.eks_master.id
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_worker_ingress_ALB443" {
  security_group_id        = aws_security_group.eks_worker.id
  source_security_group_id = aws_security_group.eks_alb_443.id
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  type                     = "ingress"
}

# Moved to ../70-apps/xx-api.tf
# resource "aws_security_group_rule" "eks_worker_ingress_api" {
#   security_group_id        = aws_security_group.eks_worker.id
#   source_security_group_id = data.aws_security_group.api-alb.id
#   from_port                = 0
#   to_port                  = 65535
#   protocol                 = "tcp"
#   type                     = "ingress"
# }

resource "aws_security_group_rule" "eks_worker_ingress_ALB80" {
  security_group_id        = aws_security_group.eks_worker.id
  source_security_group_id = aws_security_group.eks_alb_80.id
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_worker_ingress_ALB8080" {
  security_group_id        = aws_security_group.eks_worker.id
  source_security_group_id = aws_security_group.eks_alb_8080.id
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_worker_ingress_cidr" {
  security_group_id = aws_security_group.eks_worker.id
  cidr_blocks       = [local.vpc_cidr]
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  type              = "ingress"
}
