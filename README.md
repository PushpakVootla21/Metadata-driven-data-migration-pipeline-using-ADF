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
5. Use the provided scripts in the `scripts/` folder to create tables and insert sample data.

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