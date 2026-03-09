resource "aws_kms_key" "ecr" {
  description = "ECR encryption key"
  enable_key_rotation = true
  
}
resource "aws_ecr_repository" "gitops" {
  name = "gitops-app"
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
    kms_key = aws_kms_key.ecr.arn
  }
  image_scanning_configuration {
    scan_on_push = true
  }
}