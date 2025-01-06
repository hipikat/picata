node_version      = "22.12.0"
region            = "syd1"
image             = "ubuntu-24-04-x64"
droplet_size      = "s-1vcpu-2gb"
tags              = []
cloud_init_config = "../config/cloud-init.yml"
gunicorn_config   = "gunicorn.service.ini"
