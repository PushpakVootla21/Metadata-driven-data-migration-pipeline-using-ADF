# Metadata-driven-adf-pipeline

## 🚀 Project Overview

This project implements a **metadata-driven data migration pipeline** using **Azure Data Factory (ADF)** to move data from an **on-premises SQL Server** to **Azure SQL Database**. The pipeline is designed for **scalability**, **performance**, and **flexibility**, supporting **incremental loading** and dynamic table configuration through metadata. While DevOps integration is planned, it is not yet implemented in this version.

---

## 🧩 Use Case

- **Organization**: RetailNova
- **Objective**: Seamlessly migrate operational data from on-prem SQL Server to Azure SQL Database.
- **Scope**: Initial migration of 8 tables with the ability to scale.
- **Key Features**:
  - Incremental data loading using watermark columns.
  - Metadata-driven configuration for dynamic table processing.
  - Performance optimization through parallelism and batching.
  - Data consistency validation between source and destination.
  - CI/CD deployment via Azure DevOps (planned).

---

- [🚀 Project Overview](#project-overview)
- [🧩 Use Case](#use-case)
- [🛠️ Solution Architecture](#solution-architecture)
- [🚦 Getting Started](#getting-started)
- [🏗️ Prerequisites](#prerequisites)
- [📁 Folder Structure](#folder-structure)
- [📝 Step-by-Step Setup Guide](#step-by-step-setup-guide)
- [Understanding Integration Runtimes (IR)](#8-understanding-integration-runtimes-ir-in-azure-data-factory)
- [Configure Linked Services](#9-configure-linked-services-for-on-premises-and-cloud-sql-servers)
- [Create Parameterized Datasets](#12-create-parameterized-datasets-for-on-premises-and-cloud-sql-servers)
- [Metadata JSON Structure](#11-metadata-json-structure)
- [Watermark Table and Stored Procedure](#14-watermark-table-and-stored-procedure)
- [Pipeline Activities for Incremental Load](#15-pipeline-activities-for-incremental-load)
- [Pipeline Flow Summary](#16-pipeline-flow-summary)

## 🛠️ Solution Architecture

### 1. Metadata-Driven Pipeline Design
- A JSON file in ADLS Gen2 object store holds metadata about source and destination tables.
- The pipeline reads this metadata to dynamically process each table.
- New tables can be added or removed without modifying the pipeline logic.

### 2. Incremental Load Strategy
- Uses a watermark column (e.g., `LastModifiedDate`) to identify new or updated records.
- Ensures efficient and minimal data transfer during each pipeline run.

### 3. Performance Optimization
- Parallel processing of tables where applicable.
- Efficient use of staging tables and batch sizes.
- Monitoring and tuning of ADF activities for optimal throughput.

### 4. Data Consistency Checks
- Post-load validation using row counts and checksums.
- Logging and alerting for mismatches or failures.

---

## 🚦 Getting Started

1. Clone this repository.
2. Upload the metadata JSON file to your ADLS Gen2 container.
3. Configure linked services in Azure Data Factory for source and destination.
4. Import the pipeline template and set parameters as needed.
5. Trigger the pipeline and monitor execution.

---


## 🏗️ Prerequisites

- **Microsoft SQL Server**: Installed locally to serve as the on-premises source database.
- **SQL Server Management Studio (SSMS)**: Installed for managing and querying the SQL Server instance.
- **Azure Data Studio**: Installed for connecting to and managing your Azure SQL Database.

> These tools are required to simulate the on-premises environment and to connect/manage your Azure SQL Database for data migration.


## 📁 Folder Structure

```
/
├── README.md
├── metadata/
│   └── metafile.json
└── scripts/
    ├── Table Scripts.sql
    ├── Insert Scripts.sql
    └── Incremental Scripts.sql
```

## 📝 Step-by-Step Setup Guide

### 1. Create a Resource Group

A **Resource Group** in Azure is a container that holds related resources for an Azure solution.

**How to create:**
1. Go to the [Azure Portal](https://portal.azure.com/).
2. In the left menu, click **Resource groups**.
3. Click **+ Create**.
4. Enter a name, e.g., `adf-migration-rg`.
5. Select your preferred region.
6. Click **Review + Create**, then **Create**.

---

### 2. Create an Azure Data Factory (ADF) Instance

Azure Data Factory is the service that will orchestrate your data migration.

**How to create:**
1. In the Azure Portal, search for **Data factories**.
2. Click **+ Create**.
3. Select your resource group (`adf-migration-rg`).
4. Enter a name, e.g., `adf-metadata-migration`.
5. Choose a region (same as your resource group).
6. Click **Review + Create**, then **Create**.

---

### 3. Create an Azure SQL Server & Connect with Azure Data Studio

Azure SQL Server is the logical server that will host your Azure SQL Database.

**How to create:**
1. In the Azure Portal, search for **SQL servers**.
2. Click **+ Create**.
3. Select your resource group.
4. Enter a server name, e.g., `adf-sqlserver-demo`.
5. Set an admin login and password (save these!).
6. Choose a region.
7. Click **Review + Create**, then **Create**.

**To connect using Azure Data Studio:**
1. Open Azure Data Studio.
2. Click **New Connection**.
3. Enter your server name (e.g., `adf-sqlserver-demo.database.windows.net`), admin username, and password.
4. Click **Connect**.

### 3.1. Create Tables in Azure SQL Database

After connecting to your Azure SQL Server using Azure Data Studio:

1. Open Azure Data Studio and connect to your Azure SQL Server.
2. Select or create a database (e.g., `CloudDemoDB`).
3. Open the `scripts/Table Scripts.sql` file from this repository.
4. Run the script to create the required tables in your Azure SQL Database.

> **Tip:** Ensure the table structure matches your on-premises SQL Server for seamless data migration.

---

### 4. Set Up Database in On-Prem SQL Server & Connect with SSMS

You’ll simulate an on-premises environment using your local SQL Server.

**How to set up:**
1. Open **SQL Server Management Studio (SSMS)**.
2. Connect to your local SQL Server instance (usually `localhost` or `.\SQLEXPRESS`).
3. Right-click **Databases** > **New Database...**.
4. Name it, e.g., `OnPremDemoDB`, and click **OK**.
5. Use the provided scripts in the `scripts/Table Scripts.sql` folder to create tables and insert sample data.

---

### 5. Create Azure Data Lake Storage (ADLS) Gen2 & Upload Metadata JSON

ADLS Gen2 will store your metadata file for the pipeline.

**How to create:**
1. In the Azure Portal, search for **Storage accounts**.
2. Click **+ Create**.
3. Select your resource group.
4. Enter a name, e.g., `adfmetadatastorage`.
5. Choose a region and enable **Hierarchical namespace** (for Gen2).
6. Click **Review + Create**, then **Create**.

**To upload the JSON file:**
1. Go to your storage account in the portal.
2. Under **Data Lake Gen2**, click **Containers**.
3. Create a new container, e.g., `metadata`.
4. Click into the container and upload your `metafile.json` from the `metadata/` folder.

---

### 6. Configure Lookup Activity for Metadata JSON in ADLS Gen2

This step sets up your pipeline to read the metadata JSON file from Azure Data Lake Storage Gen2 using a Lookup activity.

### 6.1 Create a Service Principal and Assign Blob Access Role for ADF

To allow Azure Data Factory to access your ADLS Gen2 storage, you need to create a Service Principal (an Azure AD App Registration) and assign it the necessary role.

#### 6.1.1 Create a Service Principal (App Registration)

1. Go to the [Azure Portal](https://portal.azure.com/).
2. Search for **Azure Active Directory** in the top search bar and select it.
3. In the left menu, click **App registrations** > **+ New registration**.
4. Enter a name, e.g., `adf-access-sp`.
5. Leave the default settings and click **Register**.
6. After registration, note down the **Application (client) ID** and **Directory (tenant) ID**.

#### 6.1.2 Generate a Client Secret

1. In your App Registration, go to **Certificates & secrets**.
2. Click **+ New client secret**.
3. Add a description (e.g., `adf-secret`) and choose an expiry period.
4. Click **Add**.
5. Copy the **Value** immediately and save it securely (you’ll need it for ADF).

#### 6.1.3 Assign Blob Storage Role to the Service Principal

1. Go to your **Storage account** (ADLS Gen2) in the Azure Portal.
2. In the left menu, click **Access control (IAM)**.
3. Click **+ Add** > **Add role assignment**.
4. For **Role**, select **Storage Blob Data Contributor** (or **Storage Blob Data Owner** if full access is needed).
5. In **Assign access to**, select **User, group, or service principal**.
6. Click **Select members**, search for your app registration name (e.g., `adf-access-sp`), and select it.
7. Click **Review + assign**.

---

Now, you can use the **Tenant ID**, **Client ID**, and **Client Secret** in your ADF linked service to authenticate and access ADLS Gen2 securely.

#### 6.2. Create a Linked Service to ADLS Gen2

You’ll need a linked service in Azure Data Factory to connect to your ADLS Gen2 account using a service principal.

**How to create:**
1. In your Azure Data Factory, go to **Manage** (the wrench icon).
2. Click **Linked services** > **+ New**.
3. Select **Azure Data Lake Storage Gen2**.
4. For **Authentication method**, choose **Service principal**.
5. Enter your **ADLS Gen2 account name**, **Tenant ID**, **Service principal client ID**, and **Client secret**.
6. Test the connection and click **Create**.

#### 6.3. Create a Dataset for the Metadata JSON

You need a dataset that points to your metadata JSON file in ADLS Gen2.

**How to create:**
1. In ADF, go to the **Author** tab.
2. Under **Datasets**, click **+ New dataset**.
3. Choose **Azure Data Lake Storage Gen2** > **JSON**.
4. Select the linked service you created above.
5. Browse and select your `metafile.json` file in the `metadata` container.
6. Name your dataset (e.g., `ds_metadata_json`) and click **OK**.

#### 6.4. Add a Lookup Activity in Your Pipeline

The Lookup activity will read the metadata JSON file.

**How to configure:**
1. In your pipeline, drag a **Lookup** activity onto the canvas.
2. Set the **Source dataset** to the dataset you just created (`ds_metadata_json`).
3. In the **Settings** tab:
    - **First row only**: Enable this option (since your JSON is an array with one row per table, this will return the array itself).
    - **Recursively**: Disable this option (to avoid searching all folders).
4. (Optional) Rename the activity to `Lookup_Metadata`.

**Summary of options:**
- **First row only**: ✔️ (Enabled)
- **Recursively**: ❌ (Disabled)

---

You can now use the output of the Lookup activity to drive further activities in your pipeline, such as ForEach to iterate over tables.

### 7. Add a ForEach Activity to Iterate Over Tables in Metadata

The ForEach activity will loop through each table defined in your metadata JSON, allowing you to perform actions (like copy) for each table dynamically.

#### 7.1. Add the ForEach Activity

1. In your pipeline, drag a **ForEach** activity onto the canvas.
2. Connect the output of the **Lookup** activity to the **ForEach** activity.

#### 7.2. Configure ForEach Settings

- Go to the **Settings** tab of the ForEach activity.
- **Items**: Enter the following expression to reference the array of tables from the Lookup activity output:
  ```
  @activity('Lookup_Metadata').output.value
  ```
  > Replace `Lookup_Metadata` with the actual name of your Lookup activity if different.

- **Sequential**: Uncheck this option to allow parallel execution (recommended for performance).

#### 7.3. Summary of Settings

- **Items**:  
  ```
  @activity('Lookup_Metadata').output.value
  ```
- **Sequential**: ❌ (Unchecked)

---

Now, inside the ForEach activity, you can add activities (like Copy Data) that will execute for each table defined in your metadata JSON.

### 8. Understanding Integration Runtimes (IR) in Azure Data Factory

Integration Runtime (IR) is the compute infrastructure used by Azure Data Factory to provide data integration capabilities across different network environments.

#### 8.1. Types of Integration Runtimes

- **Azure Integration Runtime**  
  - Fully managed by Microsoft.
  - Used for data movement and transformation between cloud data stores (e.g., Azure SQL Database, Azure Blob Storage).
  - No installation required.

- **Self-Hosted Integration Runtime (SHIR)**  
  - Installed on your own on-premises or virtual machine.
  - Required for accessing data sources that are behind a firewall or within a private network (e.g., on-premises SQL Server).
  - Acts as a secure gateway between your local environment and Azure Data Factory.

#### 8.2. When to Use Each IR

- Use **Azure IR** for connecting to cloud resources such as Azure SQL Database or Azure Data Lake Storage.
- Use **Self-Hosted IR** when you need to connect to on-premises data sources, such as your local SQL Server instance.

#### 8.3. Installing Self-Hosted Integration Runtime

To connect Azure Data Factory to your on-premises SQL Server, you must install the Self-Hosted IR on a machine that can access your SQL Server.

**Installation Steps:**
1. In Azure Data Factory, go to **Manage** (wrench icon) > **Integration runtimes**.
2. Click **+ New** and select **Self-Hosted**.
3. Enter a name (e.g., `OnPrem-SHIR`) and create the IR.
4. Download the installer provided by Azure.
5. Run the installer on your local machine (the one with access to your SQL Server).
6. During installation, provide the authentication key from the Azure portal.
7. After installation, ensure the IR status is **Running** in the Azure portal.

> **Note:** The Self-Hosted IR must always be running on your local machine for Azure Data Factory to access your on-premises data.

---

In the next step, you will configure your linked services and datasets to use the appropriate Integration Runtime for each data source.

### 9. Configure Linked Services for On-Premises and Cloud SQL Servers

Linked services in Azure Data Factory define the connection information needed for ADF to connect to your data sources. You will need two linked services: one for your on-premises SQL Server and one for your Azure SQL Database.

#### 9.1. Linked Service for On-Premises SQL Server (Self-Hosted IR)

This linked service connects ADF to your local SQL Server using the Self-Hosted Integration Runtime.

**How to create:**
1. In Azure Data Factory, go to **Manage** (wrench icon) > **Linked services**.
2. Click **+ New**.
3. Search for and select **SQL Server**.
4. Fill in the following details:
   - **Name**: e.g., `LS_OnPrem_SQLServer`
   - **Server name**: The name or IP address of your local SQL Server (e.g., `localhost` or `.\SQLEXPRESS`)
   - **Database name**: The name of your on-premises database (e.g., `OnPremDemoDB`)
   - **Authentication type**: Choose `SQL authentication` or `Windows authentication` based on your setup.
   - **Username/Password**: Enter your SQL Server credentials.
   - **Connect via Integration Runtime**: Select your **Self-Hosted IR** (e.g., `OnPrem-SHIR`)
5. Click **Test connection** to ensure it works, then click **Create**.

> **Key Option:**  
> - **Connect via Integration Runtime**: Must be set to your Self-Hosted IR for on-premises access.

---

#### 9.2. Linked Service for Azure SQL Database (Azure IR)

This linked service connects ADF to your Azure SQL Database using the default Azure Integration Runtime.

**How to create:**
1. In Azure Data Factory, go to **Manage** > **Linked services**.
2. Click **+ New**.
3. Search for and select **Azure SQL Database**.
4. Fill in the following details:
   - **Name**: e.g., `LS_Azure_SQLDB`
   - **Server name**: Your Azure SQL Server name (e.g., `adf-sqlserver-demo.database.windows.net`)
   - **Database name**: The name of your Azure SQL Database (e.g., `CloudDemoDB`)
   - **Authentication type**: Usually `SQL authentication`
   - **Username/Password**: Enter your Azure SQL admin credentials.
   - **Connect via Integration Runtime**: Leave as **AutoResolveIntegrationRuntime** (default Azure IR)
5. Click **Test connection** to ensure it works, then click **Create**.

> **Key Option:**  
> - **Connect via Integration Runtime**: Leave as default (Azure IR) for cloud resources.

---

**Summary Table:**

| Linked Service         | Data Source           | Integration Runtime         | Authentication         |
|-----------------------|-----------------------|----------------------------|------------------------|
| LS_OnPrem_SQLServer   | On-prem SQL Server    | Self-Hosted IR (OnPrem-SHIR) | SQL/Windows Auth       |
| LS_Azure_SQLDB        | Azure SQL Database    | Azure IR (default)         | SQL Auth               |

---

**Tip:**  
Always test your connections before proceeding. If you encounter issues, check firewall settings, credentials, and that your Self-Hosted IR is running and reachable.

---

Next, you will create datasets that use these linked services for your pipeline activities.

### 10. Create Parameterized Datasets for On-Premises and Cloud SQL Servers

Datasets in Azure Data Factory define the structure and location of your data. For a metadata-driven pipeline, you should **parameterize the table name** so the same dataset can be reused for different tables.

#### 10.1. Dataset for On-Premises SQL Server (Source)

**How to create:**
1. In ADF, go to the **Author** tab.
2. Under **Datasets**, click **+ New dataset**.
3. Select **SQL Server**.
4. Choose your linked service (`LS_OnPrem_SQLServer`).
5. In the **Table name** field, click **Add dynamic content**.
6. Click **+ New** next to Parameters and add a parameter, e.g., `TableName`.
7. Set the **Table name** value to:
   ```
   @{dataset().TableName}
   ```
8. Name your dataset, e.g., `ds_OnPrem_SQLTable`, and click **OK**.

**Summary:**
- **Linked service**: LS_OnPrem_SQLServer
- **Parameter**: TableName (string)
- **Table name**: `@dataset().TableName`

---

#### 10.2. Dataset for Azure SQL Database (Sink)

**How to create:**
1. In ADF, go to the **Author** tab.
2. Under **Datasets**, click **+ New dataset**.
3. Select **Azure SQL Database**.
4. Choose your linked service (`LS_Azure_SQLDB`).
5. In the **Table name** field, click **Add dynamic content**.
6. Click **+ New** next to Parameters and add a parameter, e.g., `TableName`.
7. Set the **Table name** value to:
   ```
   @{dataset().TableName}
   ```
8. Name your dataset, e.g., `ds_Azure_SQLTable`, and click **OK**.

**Summary:**
- **Linked service**: LS_Azure_SQLDB
- **Parameter**: TableName (string)
- **Table name**: `@dataset().TableName`

---

#### 10.3. Using Parameterized Datasets in Activities

When configuring your **Copy Data** activity inside the ForEach loop:

- Set the **TableName** parameter for both source and sink datasets to:
  ```
  @{item().TABLE_NAME}
  ```
- Set the **MergeKey** parameter to:
  ```
  @{item().MERGE_KEY}
  ```
- Set the **WaterMark_Column** parameter to:
  ```
  @{item().WaterMark_Column}
  ```

This ensures the correct table name and keys are used for each iteration, enabling dynamic and scalable data movement.

### 11. 📄 Metadata JSON Structure

Your metadata JSON should look like this:

```json
[
  {
    "TABLE_NAME": "categories",
    "WaterMark_Column": "updated_at",
    "MERGE_KEY": ["category_id"]
  },
  {
    "TABLE_NAME": "customers",
    "WaterMark_Column": "updated_at",
    "MERGE_KEY": ["customer_id"]
  }
]
```

- **TABLE_NAME**: Name of the table to migrate.
- **WaterMark_Column**: The column used for incremental loading (watermark).
- **MERGE_KEY**: Array of key columns used for upsert/merge operations.

---

### 12. Create Parameterized Datasets for On-Premises and Cloud SQL Servers

Datasets in Azure Data Factory define the structure and location of your data. For a metadata-driven pipeline, you should **parameterize the table name, watermark column, and merge key** so the same dataset can be reused for different tables.

#### 12.1. Dataset for On-Premises SQL Server (Source)

- **Linked service**: `LS_OnPrem_SQLServer`
- **Parameters**:  
  - `TableName` (string)
  - `WaterMark_Column` (string)
  - `MergeKey` (array or string)
- **Table name**: `@dataset().TableName`

#### 12.2. Dataset for Azure SQL Database (Sink)

- **Linked service**: `LS_Azure_SQLDB`
- **Parameters**:  
  - `TableName` (string)
  - `MergeKey` (array or string)
- **Table name**: `@dataset().TableName`

---

### 13. Using Parameterized Datasets in Activities

When configuring your **Copy Data** activity inside the ForEach loop:
- Set the **TableName** parameter for both source and sink datasets to:
  ```
  @{item().TABLE_NAME}
  ```
- Set the **MergeKey** parameter (if you add it to your dataset) to:
  ```
  @{item().MERGE_KEY}
  ```
- Set the **WaterMark_Column** parameter (if needed) to:
  ```
  @{item().WaterMark_Column}
  ```

---

### 14. Watermark Table and Stored Procedure

Create a watermark table and stored procedure in your **Azure SQL Database** to track and update the last processed watermark value for each table.

**Watermark Table:**
```sql
CREATE TABLE watermarktable (
    TableName sysname PRIMARY KEY,
    WatermarkValue datetime
)
```
- For initial setup, insert a row for each table with a very old date (e.g., `'1900-01-01'`).

**Initial Watermark Setup Example:**
```sql
INSERT INTO watermarktable (TableName, WatermarkValue) VALUES ('categories', '1900-01-01');
INSERT INTO watermarktable (TableName, WatermarkValue) VALUES ('customers', '1900-01-01');
```

**Stored Procedure:**
```sql
CREATE PROCEDURE usp_write_watermark (@LastModifiedtime datetime, @TableName sysname )
AS
BEGIN
    UPDATE watermarktable
    SET WatermarkValue = @LastModifiedtime WHERE TableName = @TableName
END
```

---

### 15. Pipeline Activities for Incremental Load

#### 15.1. Lookup Old Watermark

- **Purpose:** Get the last processed watermark value for the current table from Azure SQL Database.
- **Query:**
  ```sql
  SELECT WatermarkValue AS WM FROM watermarktable WHERE TableName = '@{item().TABLE_NAME}'
  ```
- **Output:** Used as the lower bound in the source query.

#### 15.2. Lookup New Watermark (from Source)

- **Purpose:** Get the latest watermark value from the source (on-premises) table.
- **Query:**
  ```sql
  SELECT MAX(@{item().WaterMark_Column}) as NEWWM FROM @{item().TABLE_NAME}
  ```
- **Output:** Used as the upper bound in the source query and to update the watermark table after the copy.

#### 15.3. Copy Data Activity

- **Purpose:** Copy only new or updated records from source to destination.
- **Source dataset parameters:**
  - **TableName**: `@{item().TABLE_NAME}`
  - **WaterMark_Column**: `@{item().WaterMark_Column}`
  - **MergeKey**: `@{item().MERGE_KEY}`
- **Sink dataset parameters:**
  - **TableName**: `@{item().TABLE_NAME}`
  - **MergeKey**: `@{item().MERGE_KEY}`

- **Source Query:**
  ```sql
  SELECT * FROM @{item().TABLE_NAME}
  WHERE @{item().WaterMark_Column} > '@{activity('Lookup_oldwm').output.firstRow.WM}'
    AND @{item().WaterMark_Column} <= '@{activity('Lookup_onprem_newwm').output.firstRow.NEWWM}'
  ```

    ## ✅ Data Consistency Verification in Copy Activity
  
  Azure Data Factory's **Copy Data** activity includes a built-in option for basic data consistency verification:
  
  - In the **Settings** tab of the Copy Data activity, enable **"Data consistency verification"** (sometimes labeled as "Enable data consistency verification").
  - When enabled, ADF will automatically compare the number of rows read from the source with the number of rows written to the sink.
  - If there is a mismatch, the activity will fail and log an error.
  
  > **Note:**  
  > This feature only checks row counts, not the actual data content or checksums. For advanced validation (like checksums or custom queries), add additional activities after the copy step.
  
  **Reference:**  
  - [Copy Activity - Data Consistency Verification](https://learn.microsoft.com/en-us/azure/data-factory/copy-activity-overview#data-consistency-verification)
  
  ---

#### 15.4. Stored Procedure Activity

- **Purpose:** Update the watermark table in Azure SQL Database after a successful copy.
- **Linked service:** `LS_Azure_SQLDB`
- **Stored procedure name:** `usp_write_watermark`
- **Parameters:**
  - **@LastModifiedtime**: `@{activity('Lookup_onprem_newwm').output.firstRow.NEWWM}`
  - **@TableName**: `@{item().TABLE_NAME}`

---

### 16. Pipeline Flow Summary

1. **ForEach** iterates over each table in the metadata JSON.
2. **Lookup_oldwm** gets the last processed watermark value from Azure SQL Database.
3. **Lookup_onprem_newwm** gets the latest watermark value from the source table.
4. **Copy Data** copies only records newer than the old watermark and up to the new watermark.
5. **Stored Procedure** updates the watermark table with the new value for the next run.

---

**Tip:**  
- Set initial watermark values to a very old date for the first run.
- All table names, watermark columns, and keys are passed from the JSON file, making the pipeline flexible and easy to extend.
- Ensure your stored procedure and watermark table exist and are accessible in Azure SQL Database.

---

<!-- Add your real ADF project screenshot here -->
![ADF Project - Real Pipeline Screenshot](images/adf_project.png)
*Figure: Actual Azure Data Factory pipeline as implemented in the project.*

<!-- (Optional) Keep your conceptual pipeline flow image as well -->
![ADF Pipeline Flow: Lookup_Metadata → ForEach → Lookup_oldwm → Lookup_onprem_newwm → Copy Data → Stored Procedure](images/adf-pipeline-flow.png)
*Figure: Conceptual flow of the metadata-driven ADF pipeline.*

## ⏰ Pipeline Triggers

You can execute the metadata-driven pipeline in Azure Data Factory using:

- **Manual Trigger:**  
  Start the pipeline on-demand from the ADF UI by clicking "Add Trigger" > "Trigger Now".

- **Scheduled Trigger:**  
  Automate pipeline runs by creating a schedule (e.g., daily, hourly).
  1. In ADF, go to the pipeline and click "Add Trigger" > "New/Edit".
  2. Choose "Schedule" and set the desired frequency and start time.
  3. Save and activate the trigger.

- **Event-Based Trigger:**  
  Run the pipeline in response to events (e.g., file arrival in ADLS).  
  1. Go to "Manage" > "Triggers" > "New".
  2. Select "Event" and configure the event source and conditions.

> **Tip:**  
> Use scheduled triggers for regular incremental loads, and event-based triggers for near real-time scenarios.

---


## 🛠️ Troubleshooting

- **Self-Hosted IR not running:** Ensure the IR service is running and connected to Azure.
- **Connection errors:** Check firewall, credentials, and network connectivity.
- **Permission issues:** Verify service principal roles on storage and databases.
- **Pipeline failures:** Review activity output and error messages in ADF Monitor.

> **Security Tip:**  
> Store sensitive credentials (like client secrets) in Azure Key Vault and reference them in your linked services.

## 🚧 CI/CD Integration (Coming Soon)
This project will include Azure DevOps pipeline templates for automated deployment in a future release.

## 📚 References

- [Azure Data Factory Documentation](https://learn.microsoft.com/en-us/azure/data-factory/)
- [ADF Triggers](https://learn.microsoft.com/en-us/azure/data-factory/how-to-create-schedule-trigger)
- [ADF Security Best Practices](https://learn.microsoft.com/en-us/azure/data-factory/data-movement-security-considerations)
