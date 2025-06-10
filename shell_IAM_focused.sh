##Para ver los roles que tienes en el proyecto actual:

gcloud projects get-iam-policy $(gcloud config get-value project) --format=json

##Para listar todos los servicios (APIs) habilitados en tu proyecto actual:

gcloud services list --enabled

## HABILITAR APIS
PROJECT=$(gcloud config list --format 'get(core.project)')

gcloud --project $PROJECT services enable aiplatform.googleapis.com            # Vertex AI API
gcloud --project $PROJECT services enable artifactregistry.googleapis.com      # Artifact Registry API
gcloud --project $PROJECT services enable cloudbilling.googleapis.com          # Cloud Billing API
gcloud --project $PROJECT services enable cloudbuild.googleapis.com            # Cloud Build API
gcloud --project $PROJECT services enable cloudresourcemanager.googleapis.com  # Cloud Resource Manager API
gcloud --project $PROJECT services enable containerregistry.googleapis.com     # Container Registry API
gcloud --project $PROJECT services enable compute.googleapis.com               # Compute Engine API
gcloud --project $PROJECT services enable iam.googleapis.com                   # Identity and Access Management (IAM) API
gcloud --project $PROJECT services enable iamcredentials.googleapis.com        # IAM Service Account Credentials API
gcloud --project $PROJECT services enable ml.googleapis.com                    # AI Platform Training & Prediction API
gcloud --project $PROJECT services enable notebooks.googleapis.com             # Notebooks API
gcloud --project $PROJECT services enable run.googleapis.com                   # Cloud Run API
gcloud --project $PROJECT services enable secretmanager.googleapis.com         # Secret Manager API
gcloud --project $PROJECT services enable serviceusage.googleapis.com          # Service Usage API
