format:
    #!/usr/bin/env bash
    terraform fmt --recursive

check:
    #!/usr/bin/env bash
    cd tf
    terraform validate

tf op:
    #!/usr/bin/env bash
    cd tf
    terraform init
    terraform {{op}} -var-file="{{justfile_directory()}}/variables.tfvars"

tf-ecr op:
    #!/usr/bin/env bash
    cd tf-ecr
    terraform init
    terraform {{op}} -var-file="{{justfile_directory()}}/variables.tfvars"