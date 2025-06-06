# GCP Cloud Shell Cheat Sheet: Facturación (Billing)

Este cheat sheet proporciona una referencia rápida a los comandos más útiles de `gcloud` y `bq` (para consultas de facturación en BigQuery) dentro de Google Cloud Shell, específicamente orientados a la gestión y consulta de la facturación de tu proyecto en GCP.

**Tabla de Contenidos:**

1.  [Configuración Inicial](#1-configuración-inicial)
2.  [Gestión de Cuentas de Facturación](#2-gestión-de-cuentas-de-facturación)
3.  [Consulta de Facturación (Costos y Uso)](#3-consulta-de-facturación-costos-y-uso)
    * [Desde Cloud Shell (`gcloud`)](#desde-cloud-shell-gcloud)
    * [Consultas Avanzadas en BigQuery](#consultas-avanzadas-en-bigquery)
4.  [Gestión de Presupuestos y Alertas](#4-gestión-de-presupuestos-y-alertas)
5.  [Créditos y Promociones](#5-créditos-y-promociones)

---

## 1. Configuración Inicial

Antes de empezar, asegúrate de que tu `gcloud` CLI esté configurado para el proyecto correcto.

* **Verificar el proyecto actual:**
    ```bash
    gcloud config get-value project
    ```

* **Cambiar al proyecto deseado (si es necesario):**
    ```bash
    gcloud config set project [YOUR_PROJECT_ID]
    ```
    *Reemplaza `[YOUR_PROJECT_ID]` con el ID de tu proyecto.*

---

## 2. Gestión de Cuentas de Facturación

Comandos para listar y gestionar la cuenta de facturación asociada a un proyecto.

* **Listar todas las cuentas de facturación accesibles:**
    ```bash
    gcloud billing accounts list
    ```
    *Esto mostrará el ID de la cuenta de facturación y su estado.*

* **Verificar la cuenta de facturación asociada a tu proyecto actual:**
    ```bash
    gcloud beta billing projects describe [YOUR_PROJECT_ID]
    ```
    *Reemplaza `[YOUR_PROJECT_ID]` con el ID de tu proyecto.*
    *La salida incluirá `billingAccountName`.*

* **Asociar un proyecto a una cuenta de facturación específica:**
    ```bash
    gcloud beta billing projects link [YOUR_PROJECT_ID] --billing-account=[BILLING_ACCOUNT_ID]
    ```
    *Reemplaza `[YOUR_PROJECT_ID]` con el ID de tu proyecto y `[BILLING_ACCOUNT_ID]` con el ID de la cuenta de facturación (ej. `01A1B1-ABCDED-FGH123`).*

* **Desvincular un proyecto de su cuenta de facturación:**
    ```bash
    gcloud beta billing projects unlink [YOUR_PROJECT_ID]
    ```
    *Un proyecto sin cuenta de facturación detendrá sus recursos de pago.*

---

## 3. Consulta de Facturación (Costos y Uso)

### Desde Cloud Shell (`gcloud`)

La CLI de `gcloud` tiene capacidades limitadas para desglosar costos directamente, pero es útil para verificar el estado de facturación.

* **Habilitar la exportación de datos de facturación a BigQuery (requiere la API de Facturación):**
    ```bash
    gcloud services enable billing.googleapis.com
    # Este comando habilitará la API de facturación, si aún no lo está.
    # Para verificar el estado, usa 'gcloud beta billing projects describe' como se mencionó antes.
    ```

### Consultas Avanzadas en BigQuery

La forma más potente y detallada de analizar tus costos es exportar tus datos de facturación a BigQuery y luego consultarlos usando SQL.

1.  **Habilitar la exportación de datos de facturación a BigQuery:**
    * Esto se configura una sola vez en la consola de GCP (Facturación > Exportación de facturación > Exportación a BigQuery).
    * Necesitarás un `[BILLING_DATASET_ID]` (ej. `my_billing_data`) en tu `[BILLING_PROJECT_ID]` (puede ser diferente a tu proyecto de trabajo).
    * Asegúrate de que la exportación de "Standard usage cost data" (datos de costo de uso estándar) esté activada.

2.  **Consultar datos de facturación en BigQuery desde Cloud Shell:**
    * Usa el comando `bq query`.
    * **Consulta básica del costo total por día:**
        ```bash
        bq query --use_legacy_sql=false \
        "SELECT
            DATE(usage_start_time) AS usage_date,
            SUM(cost) AS total_cost
        FROM
            `[BILLING_PROJECT_ID].[BILLING_DATASET_ID].gcp_billing_export_v1_[BILLING_ACCOUNT_ID_NO_HYPHENS]`
        WHERE
            _PARTITIONTIME BETWEEN TIMESTAMP('YYYY-MM-01') AND TIMESTAMP('YYYY-MM-DD')
        GROUP BY
            usage_date
        ORDER BY
            usage_date"
        ```
        *Reemplaza:*
        * `[BILLING_PROJECT_ID]`
        * `[BILLING_DATASET_ID]`
        * `[BILLING_ACCOUNT_ID_NO_HYPHENS]` (tu ID de cuenta de facturación sin guiones, ej. `01A1B1ABCDEDFGH123`)
        * `YYYY-MM-01` y `YYYY-MM-DD` con el rango de fechas deseado.

    * **Consulta del costo por servicio por día:**
        ```bash
        bq query --use_legacy_sql=false \
        "SELECT
            DATE(usage_start_time) AS usage_date,
            service.description AS service_name,
            SUM(cost) AS total_cost
        FROM
            `[BILLING_PROJECT_ID].[BILLING_DATASET_ID].gcp_billing_export_v1_[BILLING_ACCOUNT_ID_NO_HYPHENS]`
        WHERE
            _PARTITIONTIME BETWEEN TIMESTAMP('YYYY-MM-01') AND TIMESTAMP('YYYY-MM-DD')
        GROUP BY
            usage_date, service_name
        ORDER BY
            usage_date, total_cost DESC"
        ```

    * **Consulta del costo por SKU (producto específico) por día:**
        ```bash
        bq query --use_legacy_sql=false \
        "SELECT
            DATE(usage_start_time) AS usage_date,
            sku.description AS sku_description,
            SUM(cost) AS total_cost
        FROM
            `[BILLING_PROJECT_ID].[BILLING_DATASET_ID].gcp_billing_export_v1_[BILLING_ACCOUNT_ID_NO_HYPHENS]`
        WHERE
            _PARTITIONTIME BETWEEN TIMESTAMP('YYYY-MM-01') AND TIMESTAMP('YYYY-MM-DD')
        GROUP BY
            usage_date, sku_description
        ORDER BY
            usage_date, total_cost DESC"
        ```

    * **Consulta de créditos aplicados:**
        ```bash
        bq query --use_legacy_sql=false \
        "SELECT
            DATE(usage_start_time) AS usage_date,
            credit.name AS credit_name,
            SUM(credit.amount) AS total_credit_amount
        FROM
            `[BILLING_PROJECT_ID].[BILLING_DATASET_ID].gcp_billing_export_v1_[BILLING_ACCOUNT_ID_NO_HYPHENS]`
        WHERE
            _PARTITIONTIME BETWEEN TIMESTAMP('YYYY-MM-01') AND TIMESTAMP('YYYY-MM-DD') AND credit.amount IS NOT NULL
        GROUP BY
            usage_date, credit_name
        ORDER BY
            usage_date"
        ```

---

## 4. Gestión de Presupuestos y Alertas

Los presupuestos y las alertas se gestionan principalmente a través de la consola de GCP y las APIs, pero puedes consultar la API para ver los presupuestos.

* **Listar presupuestos (requiere API de Cloud Billing Budget habilitada):**
    ```bash
    gcloud alpha billing budgets list --billing-account=[BILLING_ACCOUNT_ID]
    ```
    *La funcionalidad de `alpha` puede cambiar. La gestión completa es mejor en la consola.*

---

## 5. Créditos y Promociones

Actualmente, no hay comandos `gcloud` directos para listar tus créditos y promociones de la misma manera que se ven en la interfaz de usuario de facturación (ej. "Valor restante", "Valor original"). Esta información se obtiene principalmente a través de la Consola de GCP o consultando los datos de exportación de facturación a BigQuery (como se muestra en la sección 3).

---

**Notas Importantes:**

* **Permisos:** Necesitarás los roles de IAM adecuados (ej. `roles/billing.viewer` o `roles/billing.admin`) en la cuenta de facturación y/o el proyecto para ejecutar estos comandos. Para consultar datos en BigQuery, también necesitarás permisos para leer el conjunto de datos de facturación.
* **Actualizaciones:** Google Cloud se actualiza constantemente. Siempre consulta la [documentación oficial de Google Cloud](https://cloud.google.com/docs/gcloud/) para la información más reciente sobre comandos y funcionalidades.
* **Regiones:** Siempre ten en cuenta la región o multi-región de tus recursos, ya que los precios pueden variar.

---
