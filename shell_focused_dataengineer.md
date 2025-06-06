# Google Cloud Shell Script Cheat Sheet: Data Engineering

This cheat sheet provides a quick reference for common `gcloud` and other commands frequently used by data engineers within Google Cloud Shell. Cloud Shell comes pre-configured with `gcloud` CLI, Python, Java, Node.js, and other essential tools.

## Table of Contents
1.  [General `gcloud` Commands](#1-general-gcloud-commands)
2.  [Google Cloud Storage (GCS)](#2-google-cloud-storage-gcs)
3.  [BigQuery](#3-bigquery)
4.  [Dataflow (Apache Beam)](#4-dataflow-apache-beam)
5.  [Dataproc (Apache Spark/Hadoop)](#5-dataproc-apache-sparkhadoop)
6.  [Cloud SQL](#6-cloud-sql)
7.  [Pub/Sub](#7-pubsub)
8.  [Cloud Composer (Apache Airflow)](#8-cloud-composer-apache-airflow)
9.  [Looker / Looker Studio](#9-looker--looker-studio)
10. [Monitoring & Logging](#10-monitoring--logging)
11. [IAM & Permissions](#11-iam--permissions)
12. [Networking (Basic)](#12-networking-basic)
13. [Utilities & Troubleshooting](#13-utilities--troubleshooting)

---

## 1. General `gcloud` Commands

* **Initialize & Configure:**
    ```bash
    gcloud init # Initialize, authorize, and configure gcloud CLI for the first time
    gcloud config list # List current gcloud configuration
    gcloud config set project [PROJECT_ID] # Set default project
    gcloud config set compute/region [REGION] # Set default region (e.g., us-central1)
    gcloud config set compute/zone [ZONE] # Set default zone (e.g., us-central1-a)
    gcloud auth list # List all credentialed accounts
    gcloud auth login # Authorize gcloud to access GCP (if needed, usually done by init)
    gcloud components update # Update gcloud CLI components
    ```

* **Project & Service Listing:**
    ```bash
    gcloud projects list # List all projects
    gcloud services list --enabled # List enabled services in the current project
    ```

* **Help:**
    ```bash
    gcloud help [COMMAND] # Get help for a specific command (e.g., gcloud help storage)
    gcloud [SERVICE] help # Get help for a service (e.g., gcloud dataproc help)
    ```

---

## 2. Google Cloud Storage (GCS)

Use `gsutil` for GCS operations.

* **Bucket Operations:**
    ```bash
    gsutil ls # List buckets
    gsutil ls -L gs://[BUCKET_NAME] # List bucket details
    gsutil mb -p [PROJECT_ID] -l [LOCATION] gs://[BUCKET_NAME] # Make a new bucket
    gsutil rb gs://[BUCKET_NAME] # Remove an empty bucket
    ```

* **Object Operations:**
    ```bash
    gsutil ls gs://[BUCKET_NAME] # List objects in a bucket
    gsutil cp [LOCAL_PATH] gs://[BUCKET_NAME]/[OBJECT_PATH] # Copy local file to GCS
    gsutil cp gs://[BUCKET_NAME]/[OBJECT_PATH] [LOCAL_PATH] # Copy GCS object to local
    gsutil -m cp -r [LOCAL_DIR] gs://[BUCKET_NAME]/[GCS_PATH] # Recursively copy directory to GCS
    gsutil mv gs://[BUCKET_NAME]/[OLD_PATH] gs://[BUCKET_NAME]/[NEW_PATH] # Move/rename object
    gsutil rm gs://[BUCKET_NAME]/[OBJECT_PATH] # Remove an object
    gsutil -m rm -r gs://[BUCKET_NAME]/[GCS_DIR] # Recursively remove objects/directory
    gsutil cat gs://[BUCKET_NAME]/[OBJECT_PATH] # View content of an object
    gsutil du -sh gs://[BUCKET_NAME] # Disk usage summary for a bucket
    ```

* **Permissions:**
    ```bash
    gsutil iam get gs://[BUCKET_NAME] # Get IAM policy for a bucket
    gsutil iam set [POLICY_FILE.json] gs://[BUCKET_NAME] # Set IAM policy for a bucket
    gsutil acl get gs://[BUCKET_NAME]/[OBJECT_PATH] # Get ACL for an object (legacy)
    ```

---

## 3. BigQuery

* **Dataset Operations:**
    ```bash
    bq ls # List datasets in current project
    bq ls -d [PROJECT_ID]:[REGION] # List datasets in a specific project and region
    bq mk --dataset [DATASET_ID] # Make a new dataset
    bq rm -r [DATASET_ID] # Remove a dataset and all its tables (recursive)
    ```

* **Table Operations:**
    ```bash
    bq ls [DATASET_ID] # List tables in a dataset
    bq show [DATASET_ID].[TABLE_ID] # Show table schema and details
    bq mk --table --schema [SCHEMA_FILE.json] [DATASET_ID].[TABLE_ID] # Make a new table from schema
    bq load --source_format=CSV --autodetect [DATASET_ID].[TABLE_ID] gs://[BUCKET_NAME]/[FILE.csv] # Load data from GCS
    bq extract --destination_format=CSV [DATASET_ID].[TABLE_ID] gs://[BUCKET_NAME]/[EXPORT_PREFIX] # Extract table to GCS
    bq rm [DATASET_ID].[TABLE_ID] # Remove a table
    ```

* **Querying:**
    ```bash
    bq query --use_legacy_sql=false '[YOUR_SQL_QUERY]' # Run a standard SQL query
    bq query --use_legacy_sql=false --destination_table [DATASET_ID].[NEW_TABLE] '[YOUR_SQL_QUERY]' # Run query and save results
    bq query --use_legacy_sql=false --dry_run '[YOUR_SQL_QUERY]' # Dry run query to estimate costs
    ```

* **Jobs:**
    ```bash
    bq ls -j # List BigQuery jobs
    bq show -j [JOB_ID] # Show details of a BigQuery job
    ```

---

## 4. Dataflow (Apache Beam)

* **Templates:**
    ```bash
    gcloud dataflow jobs run [JOB_NAME] \
        --gcs-location gs://dataflow-templates/[TEMPLATE_TYPE]/[TEMPLATE_NAME] \
        --parameters inputSubscription=[PUBSUB_SUBSCRIPTION],outputTableSpec=[PROJECT_ID]:[DATASET].[TABLE] \
        --region [REGION] # Run a Google-provided template
    ```

* **Custom Jobs (Python/Java):**
    ```bash
    # Python (assuming you have your Beam pipeline code in a Python file)
    python [YOUR_BEAM_PIPELINE.py] \
        --runner DataflowRunner \
        --project [PROJECT_ID] \
        --region [REGION] \
        --temp_location gs://[BUCKET_NAME]/tmp/ \
        --staging_location gs://[BUCKET_NAME]/staging/ \
        --setup_file ./setup.py # If your project has dependencies

    # Java (assuming you have your compiled JAR)
    java -jar [YOUR_BEAM_PIPELINE.jar] \
        --runner=DataflowRunner \
        --project=[PROJECT_ID] \
        --region=[REGION] \
        --tempLocation=gs://[BUCKET_NAME]/tmp/ \
        --stagingLocation=gs://[BUCKET_NAME]/staging/
    ```

* **Job Management:**
    ```bash
    gcloud dataflow jobs list --region [REGION] # List Dataflow jobs
    gcloud dataflow jobs describe [JOB_ID] --region [REGION] # Describe a job
    gcloud dataflow jobs cancel [JOB_ID] --region [REGION] # Cancel a job
    gcloud dataflow jobs drain [JOB_ID] --region [REGION] # Drain a streaming job
    ```

---

## 5. Dataproc (Apache Spark/Hadoop)

* **Cluster Management:**
    ```bash
    gcloud dataproc clusters create [CLUSTER_NAME] \
        --region [REGION] \
        --zone [ZONE] \
        --num-workers [NUMBER] \
        --worker-machine-type [MACHINE_TYPE] \
        --master-machine-type [MACHINE_TYPE] \
        --image-version [IMAGE_VERSION] \
        --bucket [STAGING_BUCKET] \
        --metadata 'gcp-enable-private-ip-access=true' # Example: private IP (optional)
        # --enable-component-gateway # If you need component UIs (Jupyter, Spark History, etc.)
    gcloud dataproc clusters list --region [REGION] # List clusters
    gcloud dataproc clusters describe [CLUSTER_NAME] --region [REGION] # Describe cluster
    gcloud dataproc clusters update [CLUSTER_NAME] --num-workers [NEW_NUMBER] --region [REGION] # Scale cluster
    gcloud dataproc clusters delete [CLUSTER_NAME] --region [REGION] # Delete cluster
    ```

* **Submitting Jobs:**
    ```bash
    # Spark (Python)
    gcloud dataproc jobs submit pyspark gs://[BUCKET_NAME]/[YOUR_SCRIPT.py] \
        --cluster=[CLUSTER_NAME] \
        --region=[REGION] \
        --jars gs://[BUCKET_NAME]/[DEPENDENCY.jar] \
        -- [SCRIPT_ARGS]

    # Spark (JAR)
    gcloud dataproc jobs submit spark --class [MAIN_CLASS] gs://[BUCKET_NAME]/[YOUR_APP.jar] \
        --cluster=[CLUSTER_NAME] \
        --region=[REGION] \
        -- [APP_ARGS]

    # Hadoop MapReduce
    gcloud dataproc jobs submit hadoop --jar gs://[BUCKET_NAME]/[YOUR_MAPREDUCE_JOB.jar] \
        --cluster=[CLUSTER_NAME] \
        --region=[REGION] \
        -- [JOB_ARGS]

    # Hive
    gcloud dataproc jobs submit hive --file gs://[BUCKET_NAME]/[YOUR_HIVE_SCRIPT.q] \
        --cluster=[CLUSTER_NAME] \
        --region=[REGION]

    # Presto (if enabled on cluster)
    gcloud dataproc jobs submit presto --execute "SELECT * FROM my_table;" \
        --cluster=[CLUSTER_NAME] \
        --region=[REGION]
    ```

* **Job Management:**
    ```bash
    gcloud dataproc jobs list --cluster=[CLUSTER_NAME] --region=[REGION] # List jobs on a cluster
    gcloud dataproc jobs describe [JOB_ID] --region=[REGION] # Describe a job
    gcloud dataproc jobs wait [JOB_ID] --region=[REGION] # Wait for a job to complete
    gcloud dataproc jobs cancel [JOB_ID] --region=[REGION] # Cancel a running job
    gcloud dataproc jobs delete [JOB_ID] --region=[REGION] # Delete a job (history)
    ```

---

## 6. Cloud SQL

* **Instance Management:**
    ```bash
    gcloud sql instances list # List Cloud SQL instances
    gcloud sql instances describe [INSTANCE_NAME] # Describe an instance
    gcloud sql instances create [INSTANCE_NAME] \
        --database-version=MYSQL_8_0 \
        --region=[REGION] \
        --cpu=1 --memory=4GB # Example: MySQL 8.0, 1 CPU, 4GB RAM
    gcloud sql instances patch [INSTANCE_NAME] --cpu=2 --memory=8GB # Update instance
    gcloud sql instances delete [INSTANCE_NAME] # Delete instance
    ```

* **Database & User Management:**
    ```bash
    gcloud sql databases list --instance=[INSTANCE_NAME] # List databases
    gcloud sql databases create [DATABASE_NAME] --instance=[INSTANCE_NAME] # Create a database
    gcloud sql users list --instance=[INSTANCE_NAME] # List users
    gcloud sql users create [USERNAME] --host=% --instance=[INSTANCE_NAME] --password=[PASSWORD] # Create a user
    ```

* **Connect to Database (via Cloud Shell proxy):**
    ```bash
    gcloud sql connect [INSTANCE_NAME] --user=[USERNAME] # Connect to MySQL/PostgreSQL
    # Follow prompts for password. You'll be connected directly.
    ```

* **Export/Import:**
    ```bash
    # Export to GCS (CSV or SQL dump)
    gcloud sql export csv [INSTANCE_NAME] gs://[BUCKET_NAME]/[PATH]/[FILE.csv] --database=[DATABASE_NAME] --query='SELECT * FROM my_table;'
    gcloud sql export sql [INSTANCE_NAME] gs://[BUCKET_NAME]/[PATH]/[DUMP.sql] --database=[DATABASE_NAME]

    # Import from GCS (CSV or SQL dump)
    gcloud sql import csv [INSTANCE_NAME] gs://[BUCKET_NAME]/[PATH]/[FILE.csv] --database=[DATABASE_NAME] --table=[TABLE_NAME]
    gcloud sql import sql [INSTANCE_NAME] gs://[BUCKET_NAME]/[PATH]/[DUMP.sql] --database=[DATABASE_NAME]
    ```

---

## 7. Pub/Sub

* **Topic Management:**
    ```bash
    gcloud pubsub topics list # List topics
    gcloud pubsub topics create [TOPIC_ID] # Create a topic
    gcloud pubsub topics delete [TOPIC_ID] # Delete a topic
    ```

* **Subscription Management:**
    ```bash
    gcloud pubsub subscriptions list # List subscriptions
    gcloud pubsub subscriptions create [SUBSCRIPTION_ID] --topic=[TOPIC_ID] # Create a subscription
    gcloud pubsub subscriptions delete [SUBSCRIPTION_ID] # Delete a subscription
    ```

* **Publish/Pull Messages (for testing):**
    ```bash
    gcloud pubsub topics publish [TOPIC_ID] --message="Hello from Cloud Shell!" # Publish a message
    gcloud pubsub subscriptions pull [SUBSCRIPTION_ID] --auto-ack --limit=1 # Pull a message and acknowledge
    ```

---

## 8. Cloud Composer (Apache Airflow)

Cloud Composer instances provide an Apache Airflow environment. `gcloud composer` commands manage the environment itself, while Airflow DAGs are typically deployed to the GCS bucket associated with the environment.

* **Environment Management:**
    ```bash
    gcloud composer environments list --region [REGION] # List Composer environments
    gcloud composer environments describe [ENVIRONMENT_NAME] --region [REGION] # Describe an environment
    gcloud composer environments create [ENVIRONMENT_NAME] \
        --location [REGION] \
        --image-version [COMPOSER_VERSION] \ # e.g., composer-2.8.2-airflow-2.7.2
        --machine-type [MACHINE_TYPE] \ # e.g., n1-standard-1
        --node-count [NODE_COUNT] \
        --disk-size [GB] \
        --scheduler-count [COUNT] \
        --web-server-machine-type [MACHINE_TYPE] \
        --zone [ZONE] # Create a new environment
    gcloud composer environments stop [ENVIRONMENT_NAME] --region [REGION] # Stop (pause) an environment
    gcloud composer environments start [ENVIRONMENT_NAME] --region [REGION] # Start (resume) an environment
    gcloud composer environments delete [ENVIRONMENT_NAME] --region [REGION] # Delete an environment
    ```

* **DAG Deployment:**
    * **Get DAGs bucket:**
        ```bash
        gcloud composer environments describe [ENVIRONMENT_NAME] \
            --region [REGION] \
            --format="value(config.dagGcsPrefix)"
        # Output will be something like: gs://[BUCKET_NAME]/dags
        ```
    * **Upload DAG file to bucket:**
        ```bash
        gsutil cp [LOCAL_DAG_FILE.py] gs://[COMPOSER_DAGS_BUCKET]/
        ```

* **Airflow CLI Commands (via Cloud Shell):**
    You can run Airflow CLI commands directly on your Composer environment's master VM.
    ```bash
    # List DAGs
    gcloud composer environments run [ENVIRONMENT_NAME] \
        --location [REGION] dags list

    # Trigger a DAG (useful for testing)
    gcloud composer environments run [ENVIRONMENT_NAME] \
        --location [REGION] dags trigger [DAG_ID] --conf '{"key": "value"}'

    # Get task logs (replace DAG_ID, TASK_ID, DAG_RUN_ID)
    gcloud composer environments run [ENVIRONMENT_NAME] \
        --location [REGION] tasks logs [DAG_ID] [TASK_ID] [DAG_RUN_ID]

    # Clear task instance (useful for re-running failed tasks)
    gcloud composer environments run [ENVIRONMENT_NAME] \
        --location [REGION] tasks clear --yes [DAG_ID] --task-regex '[TASK_ID_REGEX]' --start-date [YYYY-MM-DD] --end-date [YYYY-MM-DD]
    ```

* **Update Environment Configuration:**
    ```bash
    gcloud composer environments update [ENVIRONMENT_NAME] \
        --location [REGION] \
        --update-env-variables=KEY=VALUE,ANOTHER_KEY=ANOTHER_VALUE # Update Airflow environment variables
    gcloud composer environments update [ENVIRONMENT_NAME] \
        --location [REGION] \
        --update-pypi-packages-from-file=requirements.txt # Install Python packages
    ```

---

## 9. Looker / Looker Studio

These tools are primarily web-based, but you might use `gcloud` to manage data sources or permissions that they rely on.

* **Looker Studio (formerly Google Data Studio):**
    * **No direct `gcloud` CLI commands for Looker Studio dashboards.** Management is entirely through the web UI (`datastudio.google.com`).
    * **Indirect interaction:** Ensure BigQuery datasets/tables, Cloud SQL instances, or GCS buckets that Looker Studio connects to have appropriate IAM permissions for the service accounts or users Looker Studio uses.
        * Example: Granting BigQuery Data Viewer role to a service account for Looker Studio.
            ```bash
            gcloud projects add-iam-policy-binding [PROJECT_ID] \
                --member='serviceAccount:[LOOKER_STUDIO_SA_EMAIL]' \
                --role='roles/bigquery.dataViewer'
            ```

* **Looker (Enterprise BI Platform):**
    * **No direct `gcloud` CLI commands for Looker instance configuration or content management.** Looker instances are managed through the Looker Admin UI or specific API calls to the Looker API (not `gcloud`).
    * **Deployment of Looker (if self-hosted):** If you're managing a self-hosted Looker instance on GCE, you'd use `gcloud compute` commands as above.
    * **Database Connections:** Data engineers configure database connections within Looker. Ensure the underlying database (e.g., BigQuery, Cloud SQL) has correct network access and IAM permissions for the Looker service account or IP whitelist.
        * Example: For Cloud SQL private IP connection from Looker:
            * Ensure Looker's VPC is peered with Cloud SQL's VPC.
            * Manage firewall rules (`gcloud compute firewall-rules`).

**Key takeaway for Looker/Looker Studio:** Your `gcloud` commands will focus on the *data sources* (BigQuery, Cloud SQL, GCS) and *IAM permissions* that Looker/Looker Studio needs to access them, rather than managing Looker/Looker Studio directly.

---

## 10. Monitoring & Logging

* **Logging (Cloud Logging):**
    ```bash
    gcloud logging logs list # List available logs
    gcloud logging read "resource.type=\"cloud_dataproc_cluster\" AND severity>=ERROR" # Read logs with a filter
    gcloud logging read "resource.type=\"dataflow_step\" AND textPayload:\"ERROR\"" --limit 10 # Read Dataflow errors
    gcloud logging read "resource.type=\"cloud_composer_environment\" AND severity=WARNING" # Read Composer environment logs
    ```

* **Monitoring (Cloud Monitoring):**
    (Primarily via Console, but can use `gcloud monitoring` for advanced APIs if needed, less common for quick shell tasks.)

---

## 11. IAM & Permissions

* **List Policy/Permissions:**
    ```bash
    gcloud projects get-iam-policy [PROJECT_ID] # Get IAM policy for a project
    gcloud storage buckets get-iam-policy gs://[BUCKET_NAME] # Get IAM policy for a GCS bucket
    gcloud bigquery datasets get-iam-policy [DATASET_ID] # Get IAM policy for a BigQuery dataset
    gcloud iam service-accounts list # List service accounts
    ```

* **Grant/Revoke Roles (Example for Storage):**
    ```bash
    gcloud projects add-iam-policy-binding [PROJECT_ID] \
        --member='user:[EMAIL]' --role='roles/storage.objectViewer' # Grant a user viewer access to storage objects
    gcloud projects remove-iam-policy-binding [PROJECT_ID] \
        --member='serviceAccount:[SERVICE_ACCOUNT_EMAIL]' --role='roles/editor' # Revoke editor role from a service account
    ```

---

## 12. Networking (Basic)

* **VPC Networks:**
    ```bash
    gcloud compute networks list # List VPC networks
    gcloud compute networks describe [NETWORK_NAME] # Describe a network
    ```

* **Firewall Rules:**
    ```bash
    gcloud compute firewall-rules list # List firewall rules
    gcloud compute firewall-rules describe [RULE_NAME] # Describe a rule
    ```

---

## 13. Utilities & Troubleshooting

* **SSH to VM (e.g., Dataproc Master):**
    ```bash
    gcloud compute ssh [VM_NAME] --zone=[ZONE] # SSH into a VM instance
    ```

* **File Transfer to VM:**
    ```bash
    gcloud compute scp [LOCAL_FILE] [VM_NAME]:[REMOTE_PATH] --zone=[ZONE] # Copy local file to VM
    gcloud compute scp [VM_NAME]:[REMOTE_FILE] [LOCAL_PATH] --zone=[ZONE] # Copy VM file to local
    ```

* **Check Quotas:**
    ```bash
    gcloud compute regions describe [REGION] # Check available quotas for a region (less granular, but helpful)
    # For more detailed quotas, use the GCP Console (IAM & Admin -> Quotas)
    ```

* **Command History:**
    ```bash
    history # Show shell command history
    ```

* **Environment Variables:**
    ```bash
    echo $PROJECT_ID # Cloud Shell automatically sets this
    echo $DEVSHELL_PROJECT_ID # Alias for PROJECT_ID
    echo $CLOUDSDK_CORE_PROJECT # Another way to get project ID
    ```

---

**Remember:**
* Replace bracketed placeholders (e.g., `[PROJECT_ID]`, `[BUCKET_NAME]`, `[REGION]`) with your actual values.
* Many commands have `--help` for more options.
* Cloud Shell sessions are temporary. Use GCS or Git for persistent storage of scripts and data.
* For complex tasks, consider using `gcloud` with `jq` for JSON parsing, or writing full Python/Bash scripts.
