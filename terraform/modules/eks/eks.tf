resource "aws_eks_cluster" "gitops_cluster" {
  name     = var.cluster_name
  role_arn = var.cluster_role

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}
resource "aws_eks_node_group" "gitops_nodes" {
  cluster_name    = aws_eks_cluster.gitops_cluster.name
  node_group_name = "gitops-nodes"
  node_role_arn   = var.node_role
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.small"]
}