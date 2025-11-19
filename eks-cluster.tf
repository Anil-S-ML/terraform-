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

   addons = {
    coredns = {}
    kube-proxy = {}
    "vpc-cni" = {
      before_compute = false
    }
  }
  eks_managed_node_groups = {
    dev = {
      instance_types = ["t3.small"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2

        iam_role_additional_policies = {
        AmazonEKSWorkerNodePolicy            = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        AmazonEKS_CNI_Policy                 = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
        AmazonEC2ContainerRegistryReadOnly   = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }
    }
  }

  tags = {
    environment = "development"
    application = "myapp"
  }
}
