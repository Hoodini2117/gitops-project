
resource "aws_kms_key" "eks" {
  description         = "EKS secrets encryption"
  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "EnableRootPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}
data "aws_caller_identity" "current" {}

#checkov:skip=CKV_AWS_38 Public endpoint required for CI/CD
#checkov:skip=CKV_AWS_39 Public endpoint required for GitHub Actions
resource "aws_eks_cluster" "gitops_cluster" {
  name     = var.cluster_name
  role_arn = var.cluster_role

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  encryption_config {
    resources = ["secrets"]

    provider {
      key_arn = aws_kms_key.eks.arn
    }
  }

  vpc_config {
    subnet_ids = var.subnet_ids

    endpoint_public_access  = true
    endpoint_private_access = true
  }
}

resource "aws_eks_node_group" "gitops_nodes" {
  cluster_name    = aws_eks_cluster.gitops_cluster.name
  node_group_name = "gitops-nodes"
  node_role_arn   = var.node_role
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 1
  }

  instance_types = ["t3.medium"]
}