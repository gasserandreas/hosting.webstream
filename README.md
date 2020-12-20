# hosting.webstream

This repo contains the hosting configuration for the webstream web page. The web page is fully hosted `serverless` on the AWS cloud environment. Terraform is used to document and reproducible a consistent environment configuration.

**Used frameworks / libraries:**
- Terraform
- Git

**Used AWS services**
- S3 Bucket with static hosting
- CloudFront configuration
- Route53 DNS hosting
- AWS ACM certification

## Getting started

### Installation
Following packages are used in development environment:
- git
- terraform

Beside package installation, no additional setup steps are required.

### Deployment
Run `terraform apply --profile my-custom-account` to deploy to terraform
