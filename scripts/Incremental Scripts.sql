create table customer_table
(
    PersonID int,
    Name varchar(255),
    LastModifytime datetime
);

create table project_table
(
    Project varchar(255),
    Creationtime datetime
);


-- STEP 5: CREATE A WATERMARK TABLE : TO TRACK TABLE NAMES, THEIR TIMESTAMPS FOR DATA CHANGES
create table watermarktable
(
    TableName varchar(255),
    WatermarkValue datetime			-- to track the old timestamp value @ ADF Pipelines
);

INSERT INTO watermarktable VALUES ('customer_table', '1/1/2010 12:00:00 AM')
INSERT INTO watermarktable VALUES ('project_table', '1/1/2010 12:00:00 AM')

select * from watermarktable


CREATE PROCEDURE usp_write_watermark ( @LastModifiedtime datetime, @TableName sysname )
AS
BEGIN
    UPDATE watermarktable
    SET WatermarkValue = @LastModifiedtime WHERE TableName = @TableName
END


/*
ASSUME  A TABLE "customer_table"  
BY 12 AM	:		10 ROWS AT THE SOURCE
					PIPELINE IS TRIGGERED. THEN ALL 10 ROWS ARE LOADED TO SINK

BY 2 AM		:		5 NEW ROW INSERTS  ++  3 EXISTING ROW UPDATES
					NO OTHER CHANGES THEREAFTER

					PIPELINE IS TRIGGERED. IT HAS TO TRACK ALL CHANGES SINCE 12 AM
					THIS 12 AM IS ACTUALLY TAKEN FROM WATERMARK TABLE 
					THE LATEST DML TIMESTAMP IS TAKEN FROM TIMESTAMP COLUMN OF SOURCE TABLE (2 AM)
*/



-- STEP 7: FOR EACH SOURCE TABLE: CREATE A STORED PROCEDURE TO PERFORM INCREMENTAL LOADS USING MERGE
CREATE TYPE DataTypeforCustomerTable 
AS TABLE
	(
    PersonID int,
    Name varchar(255),
    LastModifytime datetime
	)

CREATE PROCEDURE usp_upsert_customer_table   @customer_table    DataTypeforCustomerTable   READONLY
AS
BEGIN
  MERGE customer_table AS target
  USING @customer_table AS source
  ON target.PersonID = source.PersonID
  WHEN MATCHED THEN      UPDATE SET Name = source.Name,	LastModifytime = source.LastModifytime
  WHEN NOT MATCHED THEN  INSERT  VALUES (source.PersonID, source.Name, source.LastModifytime);
END
GO




-- FOR 2ND TABLE:
CREATE TYPE DataTypeforProjectTable AS TABLE
(
    Project varchar(255),
    Creationtime datetime
);
GO


CREATE PROCEDURE usp_upsert_project_table ( @project_table DataTypeforProjectTable READONLY)
AS
BEGIN
  MERGE project_table AS target
  USING @project_table AS source
  ON target.Project = source.Project  
  WHEN MATCHED THEN      UPDATE SET Creationtime = source.Creationtime
  WHEN NOT MATCHED THEN  INSERT VALUES (source.Project, source.Creationtime);
END


-- 2 source tables

-- 2 destination tables
-- 2 SPs for Merge (2 UDT @ Table)

-- 1 Watermark Table
-- 1 SP for Watermark Updates


-- IMPLEMENTATION STEPS:
SELF HOSTED IR
ADF RESOURCE, GENERATE KEY & AUTHENTICATE
SOURCE LINKED SERVICE
SINK LINKED SERVICE

SOURCE DATASET
SINK DATASET : DEFINE PARAMETER, LINK TO TABLE NAME


[
    {
        "TABLE_NAME": "customer_table",
        "WaterMark_Column": "LastModifytime",
        "TableType": "DataTypeforCustomerTable",
        "SPForMergeOpr": "usp_upsert_customer_table"
    },
    {
        "TABLE_NAME": "project_table",
        "WaterMark_Column": "Creationtime",
        "TableType": "DataTypeforProjectTable",
        "SPForMergeOpr": "usp_upsert_project_table"
    }
]



