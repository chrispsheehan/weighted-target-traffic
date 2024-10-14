format:
    #!/usr/bin/env bash
    terraform fmt --recursive

check:
    #!/usr/bin/env bash
    cd tf
    terraform validate -var-file="{{justfile_directory()}}/variables.tfvars"

tf op:
    #!/usr/bin/env bash
    cd tf
    terraform {{op}} -var-file="{{justfile_directory()}}/variables.tfvars"