format:
    #!/usr/bin/env bash
    terraform fmt --recursive

validate:
    #!/usr/bin/env bash
    for dir in tf/*; do
        if [ -d "$dir" ]; then
            echo "Validating $dir"
            cd "$dir"
            terraform init
            terraform validate
            cd - > /dev/null
        fi
    done

tf dir op:
    #!/usr/bin/env bash
    cd tf/{{dir}}
    terraform init
    terraform {{op}} -var-file="{{justfile_directory()}}/variables.tfvars"

detach-function function_name:
    #!/bin/bash
    aws lambda update-function-configuration --function-name {{function_name}} --vpc-config "SubnetIds=[],SecurityGroupIds=[]" --region $AWS_REGION
    aws lambda get-function-configuration --function-name {{function_name}} --query "VpcConfig" --region $AWS_REGION


