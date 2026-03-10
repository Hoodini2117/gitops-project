
resource "aws_kms_key" "ecr" {
  description         = "ECR encryption key"
  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      }
      Action   = "kms:*"
      Resource = "*"
    }]
  })
}
data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "gitops" {
  name                 = "gitops-app"
  image_tag_mutability = "IMMUTABLE"
  force_delete = true

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr.arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}