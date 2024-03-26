resource "aws_eks_cluster" "eks_master_cequence" {
  name     = "cequence-${local.vpc_shortname}"
  role_arn = "arn:aws:iam::${local.account_id}:role/eks-master-role"
  version  = "1.19"

  vpc_config {
    subnet_ids         = flatten([split(",", var.private_subnets), split(",", var.public_subnets)])
    security_group_ids = [aws_security_group.eks_master_cequence.id]
  }
}

resource "aws_security_group" "eks_master_cequence" {
  name        = "eks_master_cequence-${local.vpc_name}"
  description = "Cequence EKS Master Security Group"
  vpc_id      = var.vpc_id

  tags = {
    "Name"                                             = "eks_master_cequence-${local.vpc_name}"
    "kubernetes.io/cluster/eks-${local.vpc_shortname}" = "owned"
  }
}

resource "aws_security_group_rule" "eks_master_cequence_ingress_rule" {
  security_group_id        = aws_security_group.eks_master_cequence.id
  source_security_group_id = aws_security_group.eks_worker_cequence.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_master_cequence_egress_rule" {
  security_group_id        = aws_security_group.eks_master_cequence.id
  source_security_group_id = aws_security_group.eks_worker_cequence.id
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  type                     = "egress"
}

resource "aws_security_group" "eks_worker_cequence" {
  name        = "eks_worker_cequence-${local.vpc_name}"
  description = "Cequence EKS Worker Security Group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                                                  = "eks_worker_cequence-${local.vpc_name}"
    "kubernetes.io/cluster/cequence-${local.vpc_shortname}" = "owned"
  }
}

resource "aws_security_group_rule" "eks_worker_cequence_ingress_self" {
  security_group_id        = aws_security_group.eks_worker_cequence.id
  source_security_group_id = aws_security_group.eks_worker_cequence.id
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_worker_cequence_ingress_master" {
  security_group_id        = aws_security_group.eks_worker_cequence.id
  source_security_group_id = aws_security_group.eks_master_cequence.id
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_worker_cequence_ingress_cidr" {
  security_group_id = aws_security_group.eks_worker_cequence.id
  cidr_blocks       = [local.vpc_cidr]
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  type              = "ingress"
}
