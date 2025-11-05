locals {
  region = "us-east-1"
  name = "aws-eks-cluster-1"
  vpc_cidr = "10.0.0.0/16"
  azs = ["us-east-1b" , "us-east-1c"]
  private_subnets = ["10.0.20.0/24", "10.0.21.0/24"]
  public_subnets = ["10.0.101.0/24" , "10.0.102.0/24"]
  intra_subnets = ["10.0.30.0/24", "10.0.31.0/24"]
  env = "dev"
}
