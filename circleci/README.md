# These steps will add environment variables to the CircleCI project.
# These steps are optional and you can alternatively add these environment variables
# directly to the CircleCI app.

1) Fork the repo: https://github.com/bamaralf/parity-node
2) cd {repo_root}/circleci/terraform
# build and install terraform-provider-circleci
# https://github.com/mrolla/terraform-provider-circleci#using-the-provider

export AWS_ACCESS_KEY_ID={ access_key }
export AWS_SECRET_ACCESS_KEY={ secret _access_key }
export TF_VAR_PUBLIC_KEY={ public_key }

terraform init
terraform apply -var circleci_org={ github_organization } \ 
-var circleci_token={ token } \
-var aws_access_key=$AWS_ACCESS_KEY_ID \  
-var aws_secret_access_key=$AWS_SECRET_ACCESS_KEY
