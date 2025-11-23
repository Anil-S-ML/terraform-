module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.8.0"

  name               = "myapp-vpc-cluster"
  kubernetes_version = "1.30"

  vpc_id     = module.myapp-vpc.vpc_id
  subnet_ids = module.myapp-vpc.private_subnets

  endpoint_public_access  = true
  endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true


  tags = {
    environment = "development"
    application = "myapp"
  }
  eks_managed_node_groups = {
    worker1 = {
      instance_types = ["t3.micro"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }
}