# metadata-driven-adf-pipeline

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
- A control table stores metadata about source and destination tables.
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
