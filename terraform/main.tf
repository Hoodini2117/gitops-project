module "vpc" {
  source = "./modules/vpc"

  vpc_cidr      = var.vpc_cidr
  subnet_1_cidr = var.subnet_1_cidr
  subnet_2_cidr = var.subnet_2_cidr
}

module "iam" {
  source = "./modules/iam"
}

module "ecr" {
  source = "./modules/ecr"
}

module "eks" {
  source       = "./modules/eks"
  cluster_name = var.cluster_name

  subnet_ids = [
    module.vpc.subnet_1_id,
    module.vpc.subnet_2_id
  ]

  cluster_role = module.iam.cluster_role
  node_role    = module.iam.node_role
}