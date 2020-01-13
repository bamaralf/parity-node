1) Link this repository to your CircleCI project.

2) Add these vars to the CircleCI project and replace '{}' with the proper values:
2.1)  export AWS_ACCESS_KEY_ID={ access_key }
2.2)  export AWS_SECRET_ACCESS_KEY={ secret _access_key }
2.3)  export TF_VAR_PUBLIC_KEY={ public_key }

(Alternatively, run the steps on the ./circleci/README.md to add the environment variables to the CircleCI project.)

3) Every push to the master branch will trigger the deploy.
