##Para ver los roles que tienes en el proyecto actual:

gcloud projects get-iam-policy $(gcloud config get-value project) --format=json

##Para listar todos los servicios (APIs) habilitados en tu proyecto actual:

gcloud services list --enabled
