# Variables
variable "app_region" {
}

variable "account_id" {
}

variable "app_name" {
}

variable "prod_root_domain_name" {
}

variable "prod_www_domain_name" {
}

variable "test_root_domain_name" {
}

variable "test_www_domain_name" {
}

variable "credentials_file" {
}

variable "profile" {
}

# provider
provider "aws" {
  region                  = var.app_region
  shared_credentials_file = var.credentials_file
  profile                 = var.profile
}

# prod environment
module "prod_certificate" {
  source           = "./acm-certificate"
  root_domain_name = var.prod_root_domain_name
  www_domain_name  = var.prod_www_domain_name
}

module "prod_bucket" {
  source = "./s3-hosting"

  app_region       = var.app_region
  account_id       = var.account_id
  app_name         = var.app_name
  root_domain_name = var.prod_root_domain_name
}

module "prod_cloudfront" {
  source                     = "./cloudfront"
  root_domain_name           = var.prod_root_domain_name
  www_domain_name            = var.prod_www_domain_name
  s3_bucket_website_endpoint = module.prod_bucket.website_endpoint
  acm_certification_arn      = module.prod_certificate.arn_hosting
}

# test environment
module "test_certificate" {
  source           = "./acm-certificate"
  root_domain_name = var.test_root_domain_name
  www_domain_name  = var.test_www_domain_name
}

module "test_bucket" {
  source = "./s3-hosting"

  app_region       = var.app_region
  account_id       = var.account_id
  app_name         = var.app_name
  root_domain_name = var.test_root_domain_name
}

module "test_cloudfront" {
  source                     = "./cloudfront"
  root_domain_name           = var.test_root_domain_name
  www_domain_name            = var.test_www_domain_name
  s3_bucket_website_endpoint = module.test_bucket.website_endpoint
  acm_certification_arn      = module.test_certificate.arn_hosting
}

# static bucket
module "static_bucket" {
  source = "./s3-hosting"

  app_region       = var.app_region
  account_id       = var.account_id
  app_name         = var.app_name
  root_domain_name = "static-trailme.gasserandreas.com"
}

# utils bucket
module "utils" {
  source           = "./s3-bucket"
  app_region       = var.app_region
  account_id       = var.account_id
  app_name         = var.app_name
  root_domain_name = var.prod_root_domain_name
  bucket_name      = "utils"
}

# define code build role

# develop branch
module "codebuild_role_develop" {
  source     = "./codebuild-role"
  app_region = var.app_region
  account_id = var.account_id
  app_name   = var.app_name
  role_name  = "develop"
}

# define access policies
resource "aws_iam_role_policy" "develop" {
  role = module.codebuild_role_develop.role_name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${module.test_bucket.bucket_arn}",
        "${module.test_bucket.bucket_arn}/*",
        "${module.utils.bucket_arn}",
        "${module.utils.bucket_arn}/*"
      ]
    }
  ]
}
POLICY

}

# master branch
module "codebuild_role_master" {
  source     = "./codebuild-role"
  app_region = var.app_region
  account_id = var.account_id
  app_name   = var.app_name
  role_name  = "master"
}

# define access policies
resource "aws_iam_role_policy" "master" {
  role = module.codebuild_role_master.role_name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${module.prod_bucket.bucket_arn}",
        "${module.prod_bucket.bucket_arn}/*",
        "${module.utils.bucket_arn}",
        "${module.utils.bucket_arn}/*"
      ]
    }
  ]
}
POLICY

}

