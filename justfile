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

ci-tf dir op:
    #!/usr/bin/env bash
    cd tf/{{dir}}
    terraform init
    terraform {{op}} -auto-approve -var-file="{{justfile_directory()}}/variables.tfvars"