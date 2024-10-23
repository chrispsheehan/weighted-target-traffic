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
    export AWS_PAGER=""
    SECURITY_GROUP_ID=$(aws lambda get-function-configuration --function-name {{function_name}} --query "VpcConfig.SecurityGroupIds" --region $AWS_REGION)
    # dissociate the security group with the lamda
    ENI_IDS=$(aws ec2 describe-network-interfaces --filters "Name=group-id,Values=$SECURITY_GROUP_ID" --query "NetworkInterfaces[*].NetworkInterfaceId" --output text --region $AWS_REGION)
    aws lambda update-function-configuration --function-name {{function_name}} --vpc-config "SubnetIds=[],SecurityGroupIds=[]" --region $AWS_REGION

    while true; do
        ALL_DETACHED=true

        for ENI_ID in $ENI_IDS; do
            STATUS=$(aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID --query "NetworkInterfaces[0].Status" --output text --region $AWS_REGION 2>/dev/null)

            if [[ -z "$STATUS" ]]; then
                echo "ENI $ENI_ID does not exist. Skipping..."
                continue
            fi

            if [[ "$STATUS" != "available" ]]; then
                echo "ENI $ENI_ID is still attached (Status: $STATUS)."
                ALL_DETACHED=false
            else
                echo "ENI $ENI_ID is detached (Status: available)."
            fi
        done

        if [[ "$ALL_DETACHED" == true ]]; then
            echo "All ENIs are detached."
            exit 0
        fi

        TIMEOUT=300  # Timeout after 5 minutes (300 seconds)
        INTERVAL=10  # Check every 10 seconds
        START_TIME=$(date +%s)
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))

        if [[ "$ELAPSED_TIME" -ge "$TIMEOUT" ]]; then
            echo "Timeout reached. ENIs are still attached."
            exit 1
        fi

        echo "Waiting for ENIs to detach..."
        sleep $INTERVAL
    done
