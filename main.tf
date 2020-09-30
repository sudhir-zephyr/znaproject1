#******************AWS Provider Definition******************
provider "aws" {
  region = var.AWS_DEFAULT_REGION
}

module "Network" {
  source        =  "./Modules/Network"
  vpc_cidr      = var.vpc_cidr
  public_cidrs  = var.public_cidrs
  private_cidrs = var.private_cidrs
  accessip      = var.accessip
}