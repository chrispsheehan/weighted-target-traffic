[
    {
        "name": "${container_name}",
        "image": "${image_uri}",
        "cpu": ${cpu},
        "memory": ${memory},
        "portMappings": [
            {
                "name": "${container_name}-${container_port}-tcp",
                "containerPort": ${container_port},
                "hostPort": ${container_port},
                "protocol": "tcp",
                "appProtocol": "http"
            }
        ],
        "healthcheck": {
            "command": [
                "CMD-SHELL", 
                "wget --quiet --spider --tries=1 http://localhost:${container_port}/${stage}/${backend}/health || exit 1"
            ],
            "interval": 5,
            "retries": 1,
            "start_period": 5,
            "timeout": 5
        },
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${cloudwatch_log_name}",
                "awslogs-region": "${aws_region}",
                "awslogs-stream-prefix": "ecs"
            }
        },
        "essential": true,
        "environment": [
            {
                "name": "STAGE",
                "value": "${stage}"
            },
            {
                "name": "BACKEND",
                "value": "${backend}"
            },
            {
                "name": "IMAGE",
                "value": "${image_uri}"
            }
        ],
        "environmentFiles": [],
        "mountPoints": [],
        "volumesFrom": [],
        "ulimits": []
    }
]