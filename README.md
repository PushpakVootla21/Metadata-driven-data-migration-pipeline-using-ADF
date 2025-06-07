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

## 📄 Metadata JSON Example

```json
[
  {
    "sourceTable": "dbo.Customers",
    "destinationTable": "dbo.Customers",
    "watermarkColumn": "LastModifiedDate"
  },
  {
    "sourceTable": "dbo.Orders",
    "destinationTable": "dbo.Orders",
    "watermarkColumn": "LastModifiedDate"
  }
]
```

---

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
```
