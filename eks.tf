module "eks" {

  # Import the Module Template
  source = "terraform-aws-modules/eks/aws"
  version = "20.17.0"


  # Cluster Information
  cluster_name    = local.name
  cluster_version = "1.31"
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_addons = {
        vpc-cni = {
            most-recent = true
        }
        kube-proxy = {
            most-recent = true 
        }
        coredns = {
            most-recent = true
        }
    }

  # Control Plane Network
  control_plane_subnet_ids = module.vpc.intra_subnets
  
  # Managing Nodes in the Cluster
  eks_managed_node_group_defaults = {
  instance_types = ["t3.small", "t3a.small", "t2.small"]
  attach_cluster_primary_security_group = true
}

  eks_managed_node_groups = {
    aws-eks-cluster-1-ng = {

      instance_types = ["t3.small", "t3a.small", "t2.small"]

      min_size     = 1
      max_size     = 1
      desired_size = 1

      capacity_type = "ON_DEMAND"
    }
  }


  tags = {
    Environment = local.env
    Terraform   = "true"
  }
}