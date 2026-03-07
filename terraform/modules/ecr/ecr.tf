resource "aws_ecr_repository" "gitops" {
  name = "gitops-app"

  image_scanning_configuration {
    scan_on_push = true
  }
}