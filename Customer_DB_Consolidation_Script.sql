/*******************************************************************************
 MERGED DATABASE UPDATE SCRIPT
 Generated: 2026-06-25
 Merged from:
   1. 1FIRST_DB_Update_Script.sql  (~3192 lines)
   2. 2Second_DB_Consolidation_Script.sql (~1808 lines)

 PURPOSE:
   Single idempotent run-twice-safe script that unifies schema changes,
   UDT recreations, and stored procedure deployments from both source files.
   For duplicate SPs, File 1 version (CREATE OR ALTER) is preferred.

 SECTIONS:
   A - Settings data inserts
   B - Table schema changes (column adds / renames), grouped by table
   C - Create missing tables (IF NOT EXISTS)
   D - Drop ALL stored procedures that reference UDTs (before UDT recreation)
   E - Drop and recreate all UDTs
   F - All stored procedures (CREATE OR ALTER)
   G - Drop obsolete/unused objects

 USAGE:
   Replace [YourDatabaseName] below with your actual database name.
*******************************************************************************/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Replace [YourDatabaseName] with your actual database name
USE [YourDatabaseName];
GO

PRINT 'Starting unified database update script...';
GO

-- ============================================================
-- SECTION A: SETTINGS DATA INSERTS
-- ============================================================
PRINT 'Section A: Settings data inserts...';
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[R_Settings] WHERE [Key] = 'DCPendingBillAutoMove')
BEGIN
    INSERT INTO [dbo].[R_Settings] ([Key], [Value])
    VALUES ('DCPendingBillAutoMove', 'FALSE');
    PRINT 'Inserted setting DCPendingBillAutoMove successfully.';
END
ELSE
BEGIN
    PRINT 'Setting DCPendingBillAutoMove already exists.';
END
GO

-- ============================================================
-- SECTION A2: STANDARD ACCOUNTING GROUPS SEEDING
-- ============================================================
PRINT 'Section A2: Seeding standard accounting groups...';
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[R_Group]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '43707ECE-6CBE-45BA-A454-DC536AA89CB2') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('PRIMARY', 'F18E9156-77E9-483B-A0F5-681439CF73CE', 1, '43707ECE-6CBE-45BA-A454-DC536AA89CB2');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '2393F249-CE41-4D0A-A2B7-CD10B4FEDA6C') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('ASSETS', '43707ECE-6CBE-45BA-A454-DC536AA89CB2', 1, '2393F249-CE41-4D0A-A2B7-CD10B4FEDA6C');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = 'F9B3A932-0432-4A00-9B6A-7BE575B6C725') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('CURRENT ASSETS', '2393F249-CE41-4D0A-A2B7-CD10B4FEDA6C', 1, 'F9B3A932-0432-4A00-9B6A-7BE575B6C725');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '793C8067-4051-4D10-9661-8395BBF2E2EB') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('SUNDRY DEBTORS', 'F9B3A932-0432-4A00-9B6A-7BE575B6C725', 1, '793C8067-4051-4D10-9661-8395BBF2E2EB');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = 'CDC569D0-0CDA-4A54-A2D2-349255FE2F4E') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('LIABILITIES', '43707ECE-6CBE-45BA-A454-DC536AA89CB2', 1, 'CDC569D0-0CDA-4A54-A2D2-349255FE2F4E');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = 'B46E6A23-1F9F-41B0-8C08-6DCFFFE2B95C') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('CURRENT LIABILITIES & PROVISIONS', 'CDC569D0-0CDA-4A54-A2D2-349255FE2F4E', 1, 'B46E6A23-1F9F-41B0-8C08-6DCFFFE2B95C');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = 'DAF9CBA7-B6DD-44E9-AC47-C13450FF82FC') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('DUTIES & TAXES', 'B46E6A23-1F9F-41B0-8C08-6DCFFFE2B95C', 1, 'DAF9CBA7-B6DD-44E9-AC47-C13450FF82FC');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '95A60409-E708-4FB4-BE18-EA22BA994714') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('EXPENSES', '43707ECE-6CBE-45BA-A454-DC536AA89CB2', 1, '95A60409-E708-4FB4-BE18-EA22BA994714');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '9D6F8469-CC18-482F-BCB3-DAEA32E200CE') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('INDIRECT EXPENSE', '95A60409-E708-4FB4-BE18-EA22BA994714', 1, '9D6F8469-CC18-482F-BCB3-DAEA32E200CE');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '8554BC74-6EE3-445C-973B-014768CD5E52') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('under demo', '02118490-3771-4705-9B5E-B0B133EADB56', 0, '8554BC74-6EE3-445C-973B-014768CD5E52');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = 'FDAA2ABA-50CF-43C8-8929-02BED75002E4') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('DIRECT EXPENSE', '95A60409-E708-4FB4-BE18-EA22BA994714', 1, 'FDAA2ABA-50CF-43C8-8929-02BED75002E4');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = 'AFFD379D-DF90-4F63-B39F-0F4580423356') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('SALARY', '9D6F8469-CC18-482F-BCB3-DAEA32E200CE', 1, 'AFFD379D-DF90-4F63-B39F-0F4580423356');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '73F194DC-5C6D-4FA0-91C0-141199854612') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('DIRECT INCOME', '0E0B7E4E-D2B3-4F66-99FC-FA05E25F7A85', 1, '73F194DC-5C6D-4FA0-91C0-141199854612');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '3035A667-E781-4EDB-AA9D-1906444DFA10') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('INDIRECT INCOME', '0E0B7E4E-D2B3-4F66-99FC-FA05E25F7A85', 1, '3035A667-E781-4EDB-AA9D-1906444DFA10');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = 'FBBDFAC7-FC06-4E43-A424-1B1F1B3D8036') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('asdgroup', 'FDAA2ABA-50CF-43C8-8929-02BED75002E4', 0, 'FBBDFAC7-FC06-4E43-A424-1B1F1B3D8036');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '2333FF79-F688-4A47-B25F-2EF6EAE6A7A2') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('Akshay', '8554BC74-6EE3-445C-973B-014768CD5E52', 0, '2333FF79-F688-4A47-B25F-2EF6EAE6A7A2');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '87886AB9-6BAC-4F4B-999A-395A657C9655') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('New Grp', '73F194DC-5C6D-4FA0-91C0-141199854612', 0, '87886AB9-6BAC-4F4B-999A-395A657C9655');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '922B4D50-8720-42A5-8F71-443BB3706666') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('INVESTMENTS', '2393F249-CE41-4D0A-A2B7-CD10B4FEDA6C', 1, '922B4D50-8720-42A5-8F71-443BB3706666');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '13BFF0A6-B58B-47C1-9FD7-4DB8E3070250') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('LOANS & ADVANCES', '2393F249-CE41-4D0A-A2B7-CD10B4FEDA6C', 1, '13BFF0A6-B58B-47C1-9FD7-4DB8E3070250');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '2E59E6CC-321E-42AE-B29E-738A67342884') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('SALES ACCOUNTS', '73F194DC-5C6D-4FA0-91C0-141199854612', 1, '2E59E6CC-321E-42AE-B29E-738A67342884');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = 'F730F004-A001-4C8B-BBE0-81E597934670') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('Sreee', 'FD440082-3415-47D6-B198-E3E5C7C1BA14', 0, 'F730F004-A001-4C8B-BBE0-81E597934670');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '3DBDB20E-A150-4975-B806-890D1EA60E25') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('BANK ACCOUNTS', 'F9B3A932-0432-4A00-9B6A-7BE575B6C725', 1, '3DBDB20E-A150-4975-B806-890D1EA60E25');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = 'CB5CE900-7DDD-4B34-9610-9361913938BE') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('SECURED LOAN', 'CDC569D0-0CDA-4A54-A2D2-349255FE2F4E', 1, 'CB5CE900-7DDD-4B34-9610-9361913938BE');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '085C8995-7243-4926-AB24-A3A38159AC4F') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('New Group', 'AFFD379D-DF90-4F63-B39F-0F4580423356', 0, '085C8995-7243-4926-AB24-A3A38159AC4F');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '02118490-3771-4705-9B5E-B0B133EADB56') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('demo123', 'CDC569D0-0CDA-4A54-A2D2-349255FE2F4E', 0, '02118490-3771-4705-9B5E-B0B133EADB56');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '1CE218B9-17C7-4551-AD5F-B0B5CD0DCE88') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('Operation Expense', '9D6F8469-CC18-482F-BCB3-DAEA32E200CE', 0, '1CE218B9-17C7-4551-AD5F-B0B5CD0DCE88');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '70D21ECF-092C-4242-B26D-BC45E5E83FE4') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('SUNDRY CREDITORS', 'B46E6A23-1F9F-41B0-8C08-6DCFFFE2B95C', 1, '70D21ECF-092C-4242-B26D-BC45E5E83FE4');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = 'EAA17D57-5DB8-4043-A4A2-C2844083591E') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('CASH-IN-HAND', 'F9B3A932-0432-4A00-9B6A-7BE575B6C725', 1, 'EAA17D57-5DB8-4043-A4A2-C2844083591E');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '0447FC0F-35A6-4C44-8CBC-C300F64BB717') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('FIXED ASSETS', '2393F249-CE41-4D0A-A2B7-CD10B4FEDA6C', 1, '0447FC0F-35A6-4C44-8CBC-C300F64BB717');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '766BC257-11FD-40CC-B2C7-DB32ECD10987') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('PURCHASE ACCOUNTS', 'FDAA2ABA-50CF-43C8-8929-02BED75002E4', 1, '766BC257-11FD-40CC-B2C7-DB32ECD10987');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '7ED6D5F6-B1DB-47F5-B005-DD27491474E5') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('Teapot', '73F194DC-5C6D-4FA0-91C0-141199854612', 0, '7ED6D5F6-B1DB-47F5-B005-DD27491474E5');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = 'FDA5D6F7-0019-4D21-8E06-E229E4D9C110') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('CAPITAL ACCOUNT', 'CDC569D0-0CDA-4A54-A2D2-349255FE2F4E', 1, 'FDA5D6F7-0019-4D21-8E06-E229E4D9C110');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = 'FD440082-3415-47D6-B198-E3E5C7C1BA14') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('NNNNN', '922B4D50-8720-42A5-8F71-443BB3706666', 0, 'FD440082-3415-47D6-B198-E3E5C7C1BA14');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = 'FA444A64-0219-4EC2-B5DA-F8BF8B6261A4') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('New', '922B4D50-8720-42A5-8F71-443BB3706666', 0, 'FA444A64-0219-4EC2-B5DA-F8BF8B6261A4');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '6F50B1C4-E652-4ADC-9F18-F91E223D81A6') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('new Group', 'AFFD379D-DF90-4F63-B39F-0F4580423356', 0, '6F50B1C4-E652-4ADC-9F18-F91E223D81A6');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = 'C94333E9-3983-448D-9044-F935D5F871B5') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('Petty Cash', 'EAA17D57-5DB8-4043-A4A2-C2844083591E', 0, 'C94333E9-3983-448D-9044-F935D5F871B5');
    IF NOT EXISTS (SELECT 1 FROM dbo.R_Group WHERE GuID = '0E0B7E4E-D2B3-4F66-99FC-FA05E25F7A85') INSERT INTO dbo.R_Group (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID) VALUES ('INCOME', '43707ECE-6CBE-45BA-A454-DC536AA89CB2', 1, '0E0B7E4E-D2B3-4F66-99FC-FA05E25F7A85');
    PRINT 'Inserted standard accounting groups successfully.';
END
ELSE
BEGIN
    PRINT 'Setting DCPendingBillAutoMove already exists.';
END
GO

-- ============================================================
-- SECTION B: TABLE SCHEMA CHANGES
-- ============================================================
PRINT 'Section B: Table schema changes...';
GO

-- Ensure dbo.InvoicePrintSetup exists first before we attempt to alter it
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InvoicePrintSetup]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[InvoicePrintSetup](
        [ID] [int] IDENTITY(1,1) NOT NULL,
        [CompanyID] [uniqueidentifier] NULL,
        [TemplateName] [varchar](100) NULL,
        [CompanyName] [varchar](200) NULL,
        [Address1] [varchar](200) NULL,
        [Address2] [varchar](200) NULL,
        [Phone] [varchar](50) NULL,
        [Email] [varchar](100) NULL,
        [GSTNo] [varchar](50) NULL,
        [Logo] [varbinary](max) NULL,
        [PaperSize] [varchar](20) NULL,
        [FontName] [varchar](50) NULL,
        [FontSize] [int] NULL,
        [IsBold] [bit] NULL,
        [Alignment] [varchar](10) NULL,
        [FooterText] [varchar](500) NULL,
        [ShowThankYou] [bit] NULL,
        [ShowQRCode] [bit] NULL,
        [CreatedOn] [datetime] NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
          ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
    PRINT 'Created Table dbo.InvoicePrintSetup successfully.';
END
ELSE
    PRINT 'Table dbo.InvoicePrintSetup already exists.';
GO

-- dbo.InvoicePrintSetup columns
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicePrintSetup') AND name = 'Address1')
    ALTER TABLE dbo.InvoicePrintSetup ADD Address1 varchar(200) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicePrintSetup') AND name = 'Address2')
    ALTER TABLE dbo.InvoicePrintSetup ADD Address2 varchar(200) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicePrintSetup') AND name = 'Phone')
    ALTER TABLE dbo.InvoicePrintSetup ADD Phone varchar(50) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicePrintSetup') AND name = 'Email')
    ALTER TABLE dbo.InvoicePrintSetup ADD Email varchar(100) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicePrintSetup') AND name = 'GSTNo')
    ALTER TABLE dbo.InvoicePrintSetup ADD GSTNo varchar(50) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicePrintSetup') AND name = 'FooterText')
    ALTER TABLE dbo.InvoicePrintSetup ADD FooterText varchar(500) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicePrintSetup') AND name = 'OtherLanguage')
    ALTER TABLE dbo.InvoicePrintSetup ADD OtherLanguage nvarchar(200) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicePrintSetup') AND name = 'Header1')
    ALTER TABLE dbo.InvoicePrintSetup ADD Header1 varchar(200) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicePrintSetup') AND name = 'Header2')
    ALTER TABLE dbo.InvoicePrintSetup ADD Header2 varchar(200) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicePrintSetup') AND name = 'Header3')
    ALTER TABLE dbo.InvoicePrintSetup ADD Header3 varchar(200) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicePrintSetup') AND name = 'Header4')
    ALTER TABLE dbo.InvoicePrintSetup ADD Header4 varchar(200) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicePrintSetup') AND name = 'Header5')
    ALTER TABLE dbo.InvoicePrintSetup ADD Header5 varchar(200) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicePrintSetup') AND name = 'FooterText1')
    ALTER TABLE dbo.InvoicePrintSetup ADD FooterText1 varchar(500) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.InvoicePrintSetup') AND name = 'FooterText2')
    ALTER TABLE dbo.InvoicePrintSetup ADD FooterText2 varchar(500) NULL;
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InvoicePrintSetup]') AND type = 'U')
    ALTER TABLE dbo.InvoicePrintSetup ALTER COLUMN CompanyName nvarchar(200) NULL;
GO

-- dbo.R_Client
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[R_Client]') AND type = 'U')
    ALTER TABLE dbo.R_Client ALTER COLUMN FullName nvarchar(max) NOT NULL;
GO

-- dbo.R_Customer
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[R_Customer]') AND type = 'U')
BEGIN
    ALTER TABLE dbo.R_Customer ALTER COLUMN CreditDays int NULL;
    ALTER TABLE dbo.R_Customer ALTER COLUMN CreditLimit decimal(18, 2) NULL;
    ALTER TABLE dbo.R_Customer ALTER COLUMN Deleted bit NULL;
    ALTER TABLE dbo.R_Customer ALTER COLUMN Mobile varchar(50) NULL;
    ALTER TABLE dbo.R_Customer ALTER COLUMN PIN varchar(50) NULL;
END
GO

-- dbo.R_CustomerLoyalty
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_CustomerLoyalty') AND name = 'PointsRemaining')
    ALTER TABLE dbo.R_CustomerLoyalty ADD PointsRemaining int NOT NULL DEFAULT 0;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_CustomerLoyalty') AND name = 'EntryDate')
    ALTER TABLE dbo.R_CustomerLoyalty ADD EntryDate datetime NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_CustomerLoyalty') AND name = 'ExpiryDate')
    ALTER TABLE dbo.R_CustomerLoyalty ADD ExpiryDate datetime NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_CustomerLoyalty') AND name = 'Used')
    ALTER TABLE dbo.R_CustomerLoyalty ADD Used bit NOT NULL DEFAULT 0;
GO

-- dbo.R_EinvoiceStatus
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_EinvoiceStatus') AND name = 'Version')
    ALTER TABLE dbo.R_EinvoiceStatus ADD Version bigint NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_EinvoiceStatus') AND name = 'CreatedDate')
    ALTER TABLE dbo.R_EinvoiceStatus ADD CreatedDate datetime NULL DEFAULT (getdate());
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[R_EinvoiceStatus]') AND type = 'U')
BEGIN
    ALTER TABLE dbo.R_EinvoiceStatus ALTER COLUMN GuID varchar(50) NOT NULL;
    ALTER TABLE dbo.R_EinvoiceStatus ALTER COLUMN xmlFileName varchar(250) NULL;
    ALTER TABLE dbo.R_EinvoiceStatus ALTER COLUMN ResponseStatus varchar(250) NULL;
    ALTER TABLE dbo.R_EinvoiceStatus ALTER COLUMN ResponseMsg varchar(max) NULL;
    ALTER TABLE dbo.R_EinvoiceStatus ALTER COLUMN InvoiceType varchar(50) NULL;
    ALTER TABLE dbo.R_EinvoiceStatus ALTER COLUMN InvoiceHash varchar(250) NULL;
END
GO

-- dbo.R_ProductDetail
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_ProductDetail') AND name = 'ZoneGuid')
    ALTER TABLE dbo.R_ProductDetail ADD ZoneGuid uniqueidentifier NULL;
GO

-- dbo.R_SalesDetail
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_SalesDetail') AND name = 'IsServed')
    ALTER TABLE dbo.R_SalesDetail ADD IsServed bit NULL;
GO

-- dbo.R_SalesED
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_SalesED') AND name = 'UUserGuid')
BEGIN
    ALTER TABLE [dbo].[R_SalesED] ADD [UUserGuid] UNIQUEIDENTIFIER NULL;
    PRINT 'Added column UUserGuid to table dbo.R_SalesED successfully.';
END
ELSE
    PRINT 'Column UUserGuid already exists in table dbo.R_SalesED.';
GO

-- dbo.R_SalesTempED
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_SalesTempED') AND name = 'UUserGuid')
BEGIN
    ALTER TABLE [dbo].[R_SalesTempED] ADD [UUserGuid] UNIQUEIDENTIFIER NULL;
    PRINT 'Added column UUserGuid to table dbo.R_SalesTempED successfully.';
END
ELSE
    PRINT 'Column UUserGuid already exists in table dbo.R_SalesTempED.';
GO

-- dbo.R_SalesMaster
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'R_SalesMaster' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'IsKotPrinted' AND Object_ID = Object_ID('dbo.R_SalesMaster'))
    BEGIN
        ALTER TABLE [dbo].[R_SalesMaster] ADD [IsKotPrinted] BIT NOT NULL DEFAULT 0;
        PRINT 'Added column IsKotPrinted to table dbo.R_SalesMaster successfully.';
    END
    ELSE
        PRINT 'Column IsKotPrinted already exists in table dbo.R_SalesMaster.';
END
GO

-- dbo.R_SalesTempMaster
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_SalesTempMaster') AND name = 'OrderType')
    ALTER TABLE dbo.R_SalesTempMaster ALTER COLUMN OrderType nvarchar(50) NULL;
GO

-- dbo.R_Section — all new columns (in canonical order per requirements)
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'R_Section' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_Section') AND name = 'IsMultiOrderEnabled')
    BEGIN
        ALTER TABLE [dbo].[R_Section] ADD [IsMultiOrderEnabled] BIT NOT NULL DEFAULT 0;
        PRINT 'Added column IsMultiOrderEnabled to dbo.R_Section.';
    END
    ELSE
        PRINT 'Column IsMultiOrderEnabled already exists in dbo.R_Section.';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_Section') AND name = 'ZoneGuid')
    BEGIN
        ALTER TABLE [dbo].[R_Section] ADD [ZoneGuid] NVARCHAR(50) NULL;
        PRINT 'Added column ZoneGuid to dbo.R_Section.';
    END
    ELSE
        PRINT 'Column ZoneGuid already exists in dbo.R_Section.';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_Section') AND name = 'IsChairEnabled')
    BEGIN
        ALTER TABLE [dbo].[R_Section] ADD [IsChairEnabled] BIT NOT NULL DEFAULT 0;
        PRINT 'Added column IsChairEnabled to dbo.R_Section.';
    END
    ELSE
        PRINT 'Column IsChairEnabled already exists in dbo.R_Section.';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_Section') AND name = 'IsPaxEnabled')
    BEGIN
        ALTER TABLE [dbo].[R_Section] ADD [IsPaxEnabled] BIT NOT NULL DEFAULT 0;
        PRINT 'Added column IsPaxEnabled to dbo.R_Section.';
    END
    ELSE
        PRINT 'Column IsPaxEnabled already exists in dbo.R_Section.';

    -- IsDeliveryInvoicePrint: rename IsKOTSalesPrint if it exists, else add fresh
    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_Section') AND name = 'IsKOTSalesPrint')
    BEGIN
        EXEC sp_rename 'dbo.R_Section.IsKOTSalesPrint', 'IsDeliveryInvoicePrint', 'COLUMN';
        PRINT 'Renamed column IsKOTSalesPrint to IsDeliveryInvoicePrint in dbo.R_Section.';
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_Section') AND name = 'IsDeliveryInvoicePrint')
    BEGIN
        ALTER TABLE [dbo].[R_Section] ADD [IsDeliveryInvoicePrint] BIT NOT NULL DEFAULT 0;
        PRINT 'Added column IsDeliveryInvoicePrint to dbo.R_Section.';
    END
    ELSE
        PRINT 'Column IsDeliveryInvoicePrint already exists in dbo.R_Section.';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_Section') AND name = 'IsCashButtonPrint')
    BEGIN
        ALTER TABLE [dbo].[R_Section] ADD [IsCashButtonPrint] BIT NOT NULL DEFAULT 1;
        PRINT 'Added column IsCashButtonPrint to dbo.R_Section.';
    END
    ELSE
        PRINT 'Column IsCashButtonPrint already exists in dbo.R_Section.';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_Section') AND name = 'IsPayScreenPrintOnSettle')
    BEGIN
        ALTER TABLE [dbo].[R_Section] ADD [IsPayScreenPrintOnSettle] BIT NOT NULL DEFAULT 0;
        PRINT 'Added column IsPayScreenPrintOnSettle to dbo.R_Section.';
    END
    ELSE
        PRINT 'Column IsPayScreenPrintOnSettle already exists in dbo.R_Section.';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_Section') AND name = 'IsKitchenManagerPrintEnabled')
    BEGIN
        ALTER TABLE [dbo].[R_Section] ADD [IsKitchenManagerPrintEnabled] BIT NOT NULL DEFAULT 0;
        PRINT 'Added column IsKitchenManagerPrintEnabled to dbo.R_Section.';
    END
    ELSE
        PRINT 'Column IsKitchenManagerPrintEnabled already exists in dbo.R_Section.';

    -- KitchenManagerPrinterID: add KitchenManagerPrinter first if neither exists, then rename
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_Section') AND name = 'KitchenManagerPrinter')
       AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_Section') AND name = 'KitchenManagerPrinterID')
    BEGIN
        ALTER TABLE [dbo].[R_Section] ADD [KitchenManagerPrinter] NVARCHAR(255) NULL;
        PRINT 'Added column KitchenManagerPrinter to dbo.R_Section (will rename next).';
    END

    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_Section') AND name = 'KitchenManagerPrinter')
    BEGIN
        EXEC sp_rename 'dbo.R_Section.KitchenManagerPrinter', 'KitchenManagerPrinterID', 'COLUMN';
        EXEC('UPDATE dbo.R_Section SET KitchenManagerPrinterID = NULL');
        PRINT 'Renamed KitchenManagerPrinter to KitchenManagerPrinterID and cleared old values.';
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_Section') AND name = 'KitchenManagerPrinterID')
    BEGIN
        ALTER TABLE [dbo].[R_Section] ADD [KitchenManagerPrinterID] NVARCHAR(255) NULL;
        PRINT 'Added column KitchenManagerPrinterID to dbo.R_Section.';
    END
    ELSE
        PRINT 'Column KitchenManagerPrinterID already exists in dbo.R_Section.';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_Section') AND name = 'IsKOTPayPrint')
    BEGIN
        ALTER TABLE [dbo].[R_Section] ADD [IsKOTPayPrint] BIT NOT NULL DEFAULT 0;
        PRINT 'Added column IsKOTPayPrint to dbo.R_Section.';
    END
    ELSE
        PRINT 'Column IsKOTPayPrint already exists in dbo.R_Section.';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'InvoicePrinterID' AND Object_ID = Object_ID('dbo.R_Section'))
    BEGIN
        ALTER TABLE [dbo].[R_Section] ADD [InvoicePrinterID] UNIQUEIDENTIFIER NULL;
        PRINT 'Added column InvoicePrinterID to dbo.R_Section.';
    END
    ELSE
        PRINT 'Column InvoicePrinterID already exists in dbo.R_Section.';
END
ELSE
    PRINT 'Table dbo.R_Section does not exist. Skipping alters.';
GO

-- dbo.R_stockProduct
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_stockProduct') AND name = 'EntryType')
    ALTER TABLE dbo.R_stockProduct ADD EntryType varchar(20) NULL;
GO

-- restaurant.CategoryLocationMapping
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'CategoryLocationMapping' AND schema_id = SCHEMA_ID('restaurant'))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'CategoryMasterGuID' AND Object_ID = Object_ID('restaurant.CategoryLocationMapping'))
    BEGIN
        ALTER TABLE [restaurant].[CategoryLocationMapping] ADD [CategoryMasterGuID] UNIQUEIDENTIFIER NULL;
        PRINT 'Added column CategoryMasterGuID to restaurant.CategoryLocationMapping.';
    END
    ELSE
        PRINT 'Column CategoryMasterGuID already exists in restaurant.CategoryLocationMapping.';
END
GO

-- restaurant.Product
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[Product]') AND type = 'U')
BEGIN
    ALTER TABLE restaurant.Product ALTER COLUMN Name nvarchar(200) NOT NULL;
    ALTER TABLE restaurant.Product ALTER COLUMN ShortName nvarchar(200) NOT NULL;
END
GO

-- restaurant.Section
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[Section]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('restaurant.Section') AND name = 'IsPaxEnabled')
        ALTER TABLE restaurant.Section ADD IsPaxEnabled bit NOT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('restaurant.Section') AND name = 'ZoneGuid')
        ALTER TABLE restaurant.Section ADD ZoneGuid uniqueidentifier NULL;
END
GO

-- restaurant.SectionSettings — all new columns
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'SectionSettings' AND schema_id = SCHEMA_ID('restaurant'))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'IsMultiOrderEnabled' AND Object_ID = Object_ID('restaurant.SectionSettings'))
    BEGIN
        ALTER TABLE [restaurant].[SectionSettings] ADD [IsMultiOrderEnabled] BIT NOT NULL DEFAULT(0);
        PRINT 'Added column IsMultiOrderEnabled to restaurant.SectionSettings.';
    END
    ELSE
        PRINT 'Column IsMultiOrderEnabled already exists in restaurant.SectionSettings.';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'InvoicePrinterID' AND Object_ID = Object_ID('restaurant.SectionSettings'))
    BEGIN
        ALTER TABLE [restaurant].[SectionSettings] ADD [InvoicePrinterID] NVARCHAR(50) NULL;
        PRINT 'Added column InvoicePrinterID to restaurant.SectionSettings.';
    END
    ELSE
        PRINT 'Column InvoicePrinterID already exists in restaurant.SectionSettings.';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'IsPaxEnabled' AND Object_ID = Object_ID('restaurant.SectionSettings'))
    BEGIN
        ALTER TABLE [restaurant].[SectionSettings] ADD [IsPaxEnabled] BIT NOT NULL DEFAULT(0);
        PRINT 'Added column IsPaxEnabled to restaurant.SectionSettings.';
    END
    ELSE
        PRINT 'Column IsPaxEnabled already exists in restaurant.SectionSettings.';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'IsChairEnabled' AND Object_ID = Object_ID('restaurant.SectionSettings'))
    BEGIN
        ALTER TABLE [restaurant].[SectionSettings] ADD [IsChairEnabled] BIT NOT NULL DEFAULT(1);
        PRINT 'Added column IsChairEnabled to restaurant.SectionSettings.';
    END
    ELSE
        PRINT 'Column IsChairEnabled already exists in restaurant.SectionSettings.';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'IsCashButtonPrint' AND Object_ID = Object_ID('restaurant.SectionSettings'))
    BEGIN
        ALTER TABLE [restaurant].[SectionSettings] ADD [IsCashButtonPrint] BIT NOT NULL DEFAULT 1;
        PRINT 'Added column IsCashButtonPrint to restaurant.SectionSettings.';
    END
    ELSE
        PRINT 'Column IsCashButtonPrint already exists in restaurant.SectionSettings.';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'IsPayScreenPrintOnSettle' AND Object_ID = Object_ID('restaurant.SectionSettings'))
    BEGIN
        ALTER TABLE [restaurant].[SectionSettings] ADD [IsPayScreenPrintOnSettle] BIT NOT NULL DEFAULT 0;
        PRINT 'Added column IsPayScreenPrintOnSettle to restaurant.SectionSettings.';
    END
    ELSE
        PRINT 'Column IsPayScreenPrintOnSettle already exists in restaurant.SectionSettings.';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'IsKitchenManagerPrintEnabled' AND Object_ID = Object_ID('restaurant.SectionSettings'))
    BEGIN
        ALTER TABLE [restaurant].[SectionSettings] ADD [IsKitchenManagerPrintEnabled] BIT NOT NULL DEFAULT 0;
        PRINT 'Added column IsKitchenManagerPrintEnabled to restaurant.SectionSettings.';
    END
    ELSE
        PRINT 'Column IsKitchenManagerPrintEnabled already exists in restaurant.SectionSettings.';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'KitchenManagerPrinterID' AND Object_ID = Object_ID('restaurant.SectionSettings'))
    BEGIN
        ALTER TABLE [restaurant].[SectionSettings] ADD [KitchenManagerPrinterID] NVARCHAR(50) NULL;
        PRINT 'Added column KitchenManagerPrinterID to restaurant.SectionSettings.';
    END
    ELSE
        PRINT 'Column KitchenManagerPrinterID already exists in restaurant.SectionSettings.';
END
ELSE
    PRINT 'Table restaurant.SectionSettings does not exist. Skipping alters.';
GO

-- Unified Database check & add missing columns to ensure 100% compatibility:
-- dbo.R_Category
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[R_Category]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_Category') AND name = 'CategoryMasterGuID')
    BEGIN
        ALTER TABLE dbo.R_Category ADD CategoryMasterGuID uniqueidentifier NULL;
        PRINT 'Added column CategoryMasterGuID to dbo.R_Category successfully.';
    END
END
GO

-- dbo.R_SalesMaster
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[R_SalesMaster]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_SalesMaster') AND name = 'OrderType')
    BEGIN
        ALTER TABLE dbo.R_SalesMaster ADD OrderType varchar(20) NULL;
        PRINT 'Added column OrderType to dbo.R_SalesMaster successfully.';
    END
END
GO

-- dbo.R_SalesTempMaster
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[R_SalesTempMaster]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_SalesTempMaster') AND name = 'OrderType')
    BEGIN
        ALTER TABLE dbo.R_SalesTempMaster ADD OrderType nvarchar(50) NULL;
        PRINT 'Added column OrderType to dbo.R_SalesTempMaster successfully.';
    END
END
GO

-- dbo.R_SalesDetail
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[R_SalesDetail]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_SalesDetail') AND name = 'ChairNo')
    BEGIN
        ALTER TABLE dbo.R_SalesDetail ADD ChairNo int NULL;
        PRINT 'Added column ChairNo to dbo.R_SalesDetail successfully.';
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_SalesDetail') AND name = 'CourseNo')
    BEGIN
        ALTER TABLE dbo.R_SalesDetail ADD CourseNo int NULL;
        PRINT 'Added column CourseNo to dbo.R_SalesDetail successfully.';
    END
END
GO

-- dbo.R_SalesTempDetail
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[R_SalesTempDetail]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_SalesTempDetail') AND name = 'ChairNo')
    BEGIN
        ALTER TABLE dbo.R_SalesTempDetail ADD ChairNo int NULL;
        PRINT 'Added column ChairNo to dbo.R_SalesTempDetail successfully.';
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_SalesTempDetail') AND name = 'CourseNo')
    BEGIN
        ALTER TABLE dbo.R_SalesTempDetail ADD CourseNo int NULL;
        PRINT 'Added column CourseNo to dbo.R_SalesTempDetail successfully.';
    END
END
GO

-- restaurant.Product
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[Product]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('restaurant.Product') AND name = 'Calories')
    BEGIN
        ALTER TABLE restaurant.Product ADD Calories decimal(10, 2) NULL;
        PRINT 'Added column Calories to restaurant.Product successfully.';
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('restaurant.Product') AND name = 'imgDescription')
    BEGIN
        ALTER TABLE restaurant.Product ADD imgDescription nvarchar(max) NULL;
        PRINT 'Added column imgDescription to restaurant.Product successfully.';
    END
END
GO

-- dbo.R_Product
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[R_Product]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_Product') AND name = 'Calories')
    BEGIN
        ALTER TABLE dbo.R_Product ADD Calories decimal(10, 2) NULL;
        PRINT 'Added column Calories to dbo.R_Product successfully.';
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_Product') AND name = 'imgDescription')
    BEGIN
        ALTER TABLE dbo.R_Product ADD imgDescription nvarchar(max) NULL;
        PRINT 'Added column imgDescription to dbo.R_Product successfully.';
    END
END
GO

-- restaurant.ProductSectionPriceDetail
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[ProductSectionPriceDetail]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('restaurant.ProductSectionPriceDetail') AND name = 'ZoneGuid')
    BEGIN
        ALTER TABLE restaurant.ProductSectionPriceDetail ADD ZoneGuid uniqueidentifier NULL;
        PRINT 'Added column ZoneGuid to restaurant.ProductSectionPriceDetail successfully.';
    END
END
GO

-- dbo.BillReceiptMaster
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BillReceiptMaster]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.BillReceiptMaster') AND name = 'UpdatedUser')
    BEGIN
        ALTER TABLE dbo.BillReceiptMaster ADD UpdatedUser nvarchar(100) NULL;
        PRINT 'Added column UpdatedUser to dbo.BillReceiptMaster successfully.';
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.BillReceiptMaster') AND name = 'IsDeleted')
    BEGIN
        ALTER TABLE dbo.BillReceiptMaster ADD IsDeleted bit NOT NULL DEFAULT 0;
        PRINT 'Added column IsDeleted to dbo.BillReceiptMaster successfully.';
    END
END
GO

-- restaurant.BillReceiptMaster
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[BillReceiptMaster]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('restaurant.BillReceiptMaster') AND name = 'IsDeleted')
    BEGIN
        ALTER TABLE restaurant.BillReceiptMaster ADD IsDeleted bit NOT NULL DEFAULT 0;
        PRINT 'Added column IsDeleted to restaurant.BillReceiptMaster successfully.';
    END
END
GO

-- ============================================================
-- SECTION C: CREATE MISSING TABLES
-- ============================================================
PRINT 'Section C: Create missing tables...';
GO

-- InvoicePrintSetup table has been moved to the start of Section B to prevent alter errors.

IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[KOTSequence]') AND type in (N'U'))
BEGIN
    CREATE TABLE [restaurant].[KOTSequence](
        [ID] [int] IDENTITY(1,1) NOT NULL,
        [SalesMasterGuid] [uniqueidentifier] NOT NULL,
        [KOTNo] [int] NOT NULL,
        [KOTDate] [date] NOT NULL,
        [CreatedDate] [datetime] NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
          ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
    UNIQUE NONCLUSTERED ([SalesMasterGuid] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
          ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY];
    PRINT 'Created Table restaurant.KOTSequence successfully.';
END
ELSE
    PRINT 'Table restaurant.KOTSequence already exists.';
GO

IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[R_EinvoiceStatus]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[R_EinvoiceStatus](
        [GuID] [varchar](50) NOT NULL,
        [BillNo] [varchar](50) NOT NULL,
        [BillDateTime] [datetime] NOT NULL,
        [xmlFileName] [varchar](250) NULL,
        [ResponseStatus] [varchar](250) NULL,
        [ResponseMsg] [varchar](250) NULL,
        [InvoiceType] [varchar](50) NULL,
        [InvoiceHash] [varchar](250) NULL,
        [ReSubmitStatus] [varchar](50) NULL,
        [Version] [bigint] NULL,
        [CreatedDate] [datetime] NULL,
    PRIMARY KEY CLUSTERED ([GuID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
          ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY];
    PRINT 'Created Table dbo.R_EinvoiceStatus successfully.';
END
ELSE
    PRINT 'Table dbo.R_EinvoiceStatus already exists.';
GO

-- ============================================================
-- SECTION D: DROP ALL UDT-DEPENDENT STORED PROCEDURES
-- ============================================================
PRINT 'Section D: Dropping UDT-dependent stored procedures...';
GO

IF OBJECT_ID('[restaurant].[Sync_EinvoiceStatus_Insert]', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [restaurant].[Sync_EinvoiceStatus_Insert];
    PRINT 'Dropped [restaurant].[Sync_EinvoiceStatus_Insert].';
END
GO
IF OBJECT_ID('[restaurant].[Sync_EinvoiceStatus_GetAll]', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [restaurant].[Sync_EinvoiceStatus_GetAll];
    PRINT 'Dropped [restaurant].[Sync_EinvoiceStatus_GetAll].';
END
GO
IF OBJECT_ID('[restaurant].[ProductImport_Insert]', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [restaurant].[ProductImport_Insert];
    PRINT 'Dropped [restaurant].[ProductImport_Insert].';
END
GO
IF OBJECT_ID('[restaurant].[ProductBulkPrice_Insert]', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [restaurant].[ProductBulkPrice_Insert];
    PRINT 'Dropped [restaurant].[ProductBulkPrice_Insert].';
END
GO
IF OBJECT_ID('[restaurant].[Sync_SalesLog_Insert]', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [restaurant].[Sync_SalesLog_Insert];
    PRINT 'Dropped [restaurant].[Sync_SalesLog_Insert].';
END
GO
IF OBJECT_ID('[restaurant].[Sync_SalesTempLog_Insert]', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [restaurant].[Sync_SalesTempLog_Insert];
    PRINT 'Dropped [restaurant].[Sync_SalesTempLog_Insert].';
END
GO
IF OBJECT_ID('[restaurant].[product_insert]', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [restaurant].[product_insert];
    PRINT 'Dropped [restaurant].[product_insert].';
END
GO
IF OBJECT_ID('[restaurant].[Sync_Product_Insert]', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [restaurant].[Sync_Product_Insert];
    PRINT 'Dropped [restaurant].[Sync_Product_Insert].';
END
GO
IF OBJECT_ID('[restaurant].[Sync_Category_Insert]', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [restaurant].[Sync_Category_Insert];
    PRINT 'Dropped [restaurant].[Sync_Category_Insert].';
END
GO
IF OBJECT_ID('[restaurant].[Sync_Section_Insert]', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [restaurant].[Sync_Section_Insert];
    PRINT 'Dropped [restaurant].[Sync_Section_Insert].';
END
GO

IF EXISTS (SELECT 1 FROM sys.types t INNER JOIN sys.schemas s ON t.schema_id=s.schema_id WHERE t.name='Sync_Product_UDT' AND s.name='restaurant' AND t.is_table_type=1)
BEGIN
    DROP TYPE [restaurant].[Sync_Product_UDT];
    PRINT 'Dropped UDT restaurant.Sync_Product_UDT.';
END
GO

-- ============================================================
-- SECTION E: DROP AND RECREATE ALL USER-DEFINED TYPES (UDTs)
-- ============================================================
PRINT 'Section E: Recreating User-Defined Types (UDTs)...';
GO

-- restaurant.ProductModifierDetail
IF EXISTS (SELECT 1 FROM sys.types WHERE name = 'ProductModifierDetail' AND is_table_type = 1 AND schema_id = SCHEMA_ID('restaurant'))
    DROP TYPE [restaurant].[ProductModifierDetail];
GO
CREATE TYPE [restaurant].[ProductModifierDetail] AS TABLE(
    [MasterProductID] [uniqueidentifier] NULL,
    [ModifierID] [uniqueidentifier] NULL,
    [ExtraCharge] [money] NULL,
    [IsDefault] [bit] NOT NULL
);
GO
PRINT 'Created UDT restaurant.ProductModifierDetail.';
GO

-- restaurant.ProductImageDetail
IF EXISTS (SELECT 1 FROM sys.types WHERE name = 'ProductImageDetail' AND is_table_type = 1 AND schema_id = SCHEMA_ID('restaurant'))
    DROP TYPE [restaurant].[ProductImageDetail];
GO
CREATE TYPE [restaurant].[ProductImageDetail] AS TABLE(
    [ProductGuID] [uniqueidentifier] NOT NULL,
    [ImageURL] [nvarchar](500) NOT NULL,
    [ThumbnailURL] [nvarchar](500) NULL,
    [IsPrimary] [bit] NOT NULL,
    [CreatedDate] [datetime] NULL,
    [CreatedUser] [nvarchar](100) NULL,
    [UpdatedDate] [datetime] NULL,
    [UpdatedUser] [nvarchar](100) NULL
);
GO
PRINT 'Created UDT restaurant.ProductImageDetail.';
GO

-- restaurant.ProductDetail
IF EXISTS (SELECT 1 FROM sys.types WHERE name = 'ProductDetail' AND is_table_type = 1 AND schema_id = SCHEMA_ID('restaurant'))
    DROP TYPE [restaurant].[ProductDetail];
GO
CREATE TYPE [restaurant].[ProductDetail] AS TABLE(
    [SectionID] [uniqueidentifier] NOT NULL,
    [Price] [decimal](18, 8) NOT NULL,
    [TaxID] [uniqueidentifier] NULL,
    [IsTaxIncludedInPrice] [bit] NOT NULL,
    [DiscountID] [uniqueidentifier] NULL,
    [IsActive] [bit] NOT NULL,
    [ZoneGuid] [uniqueidentifier] NULL
);
GO
PRINT 'Created UDT restaurant.ProductDetail.';
GO

-- restaurant.Sync_Product_UDT
CREATE TYPE [restaurant].[Sync_Product_UDT] AS TABLE(
    [GuID] [uniqueidentifier] NOT NULL,
    [Name] [varchar](max) NOT NULL,
    [ShortName] [varchar](max) NOT NULL,
    [Barcode] [varchar](max) NOT NULL,
    [RefCode] [varchar](max) NULL,
    [TypeID] [uniqueidentifier] NULL,
    [UnitID] [uniqueidentifier] NOT NULL,
    [CategoryID] [uniqueidentifier] NOT NULL,
    [BranchID] [uniqueidentifier] NULL,
    [Image] [varchar](max) NULL,
    [IsVariableProduct] [bit] NOT NULL,
    [ArabicDescription] [nvarchar](max) NULL,
    [IsStockItem] [bit] NULL,
    [ERPProductID] [uniqueidentifier] NULL,
    [GroupID] [uniqueidentifier] NULL,
    [ColorID] [varchar](max) NULL,
    [VegTypeNo] [int] NULL,
    [OtherDescription] [nvarchar](max) NULL,
    [Loyalty] [decimal](18,4) NULL,
    [Cost] [decimal](18,4) NULL,
    [CessPercentage] [decimal](18,4) NULL,
    [SCategoryID] [uniqueidentifier] NULL,
    [IsActive] [int] NULL,
    [Deleted] [bit] NOT NULL,
    [IsDailyStockItem] [bit] NOT NULL,
    [BasePrice] [decimal](18,4) NULL,
    [CreatedUser] [uniqueidentifier] NOT NULL,
    [CreatedDate] [datetime] NOT NULL,
    [UpdatedUser] [uniqueidentifier] NOT NULL,
    [UpdatedDate] [datetime] NOT NULL,
    [MenuItem] [bit] NULL,
    [HSNCode] [nvarchar](max) NULL,
    [ProductionQuantity] [decimal](18,4) NULL,
    [Calories] [decimal](10,2) NULL,
    [imgDescription] [nvarchar](max) NULL
);
GO
PRINT 'Created UDT restaurant.Sync_Product_UDT.';
GO

-- restaurant.Sync_Category_UDT
IF EXISTS (SELECT 1 FROM sys.types WHERE name = 'Sync_Category_UDT' AND is_table_type = 1 AND schema_id = SCHEMA_ID('restaurant'))
    DROP TYPE [restaurant].[Sync_Category_UDT];
GO
CREATE TYPE [restaurant].[Sync_Category_UDT] AS TABLE(
    [GuID] [uniqueidentifier] NOT NULL,
    [Name] [varchar](50) NOT NULL,
    [ShortName] [varchar](50) NOT NULL,
    [Deleted] [bit] NOT NULL,
    [Course] [int] NULL,
    [CreatedUser] [uniqueidentifier] NOT NULL,
    [CreatedDate] [datetime] NOT NULL,
    [UpdatedUser] [uniqueidentifier] NOT NULL,
    [UpdatedDate] [datetime] NOT NULL,
    [CategoryMasterGuID] [uniqueidentifier] NULL
);
GO
PRINT 'Created UDT restaurant.Sync_Category_UDT.';
GO

-- restaurant.Sync_SectionWiseProductDetail_UDT
IF EXISTS (SELECT 1 FROM sys.types WHERE name = 'Sync_SectionWiseProductDetail_UDT' AND is_table_type = 1 AND schema_id = SCHEMA_ID('restaurant'))
    DROP TYPE [restaurant].[Sync_SectionWiseProductDetail_UDT];
GO
CREATE TYPE [restaurant].[Sync_SectionWiseProductDetail_UDT] AS TABLE(
    [GuID] [uniqueidentifier] NOT NULL,
    [MasterID] [uniqueidentifier] NOT NULL,
    [SectionID] [uniqueidentifier] NOT NULL,
    [Price] [decimal](18, 4) NULL,
    [TaxID] [uniqueidentifier] NULL,
    [IsTaxIncludedInPrice] [bit] NULL,
    [DiscountID] [uniqueidentifier] NULL,
    [IsActive] [bit] NULL,
    [Deleted] [bit] NULL,
    [CreatedUser] [uniqueidentifier] NOT NULL,
    [CreatedDate] [datetime] NOT NULL,
    [UpdatedUser] [uniqueidentifier] NOT NULL,
    [UpdatedDate] [datetime] NOT NULL,
    [ZoneGuid] [uniqueidentifier] NULL
);
GO
PRINT 'Created UDT restaurant.Sync_SectionWiseProductDetail_UDT.';
GO

-- restaurant.Sync_Section_UDT
IF EXISTS (SELECT 1 FROM sys.types WHERE name = 'Sync_Section_UDT' AND is_table_type = 1 AND schema_id = SCHEMA_ID('restaurant'))
    DROP TYPE [restaurant].[Sync_Section_UDT];
GO
CREATE TYPE [restaurant].[Sync_Section_UDT] AS TABLE(
    [GuID] [uniqueidentifier] NOT NULL,
    [Name] [varchar](max) NOT NULL,
    [ShortName] [varchar](max) NULL,
    [Deleted] [bit] NOT NULL,
    [CreatedUser] [uniqueidentifier] NOT NULL,
    [CreatedDate] [datetime] NOT NULL,
    [UpdatedUser] [uniqueidentifier] NOT NULL,
    [UpdatedDate] [datetime] NOT NULL,
    [ZoneGuid] [uniqueidentifier] NULL
);
GO
PRINT 'Created UDT restaurant.Sync_Section_UDT.';
GO

-- restaurant.Sync_Section_Setting_UDT (26 columns — critical fix)
IF EXISTS (SELECT 1 FROM sys.types WHERE name = 'Sync_Section_Setting_UDT' AND is_table_type = 1 AND schema_id = SCHEMA_ID('restaurant'))
    DROP TYPE [restaurant].[Sync_Section_Setting_UDT];
GO
CREATE TYPE [restaurant].[Sync_Section_Setting_UDT] AS TABLE(
    [SectionGuID]                    [nvarchar](50)  NOT NULL,
    [EnableKOTPrinting]              [bit]           NOT NULL,
    [PrintKOTInSalesBillFormat]      [bit]           NOT NULL,
    [PrintKOTInSalesBillPrinter]     [bit]           NOT NULL,
    [PrintBothSalesAndKOTPrint]      [bit]           NOT NULL,
    [ShowPopupToCaptureCustomerDetail] [bit]         NOT NULL,
    [ShowPopupToSelectWaiter]        [bit]           NOT NULL,
    [ShowPopupToSelectTable]         [bit]           NOT NULL,
    [PrintFileName]                  [nvarchar](255) NULL,
    [NumberOfInvoicePrints]          [int]           NOT NULL,
    [BillStartNumber]                [int]           NOT NULL,
    [InvoicePrefix]                  [nvarchar](50)  NULL,
    [TaxID]                          [nvarchar](50)  NULL,
    [DepartmentID]                   [nvarchar](50)  NULL,
    [CreatedUser]                    [nvarchar](50)  NULL,
    [CreatedDate]                    [datetime]      NULL,
    [UpdatedUser]                    [nvarchar](50)  NULL,
    [UpdatedDate]                    [datetime]      NULL,
    [IsMultiOrderEnabled]            [bit]           NOT NULL,
    [InvoicePrinterID]               [nvarchar](50)  NULL,
    [IsPaxEnabled]                   [bit]           NOT NULL,
    [isChairEnabled]                 [bit]           NOT NULL,
    [IsCashButtonPrint]              [bit]           NOT NULL,
    [IsPayScreenPrintOnSettle]       [bit]           NOT NULL,
    [IsKitchenManagerPrintEnabled]   [bit]           NOT NULL,
    [KitchenManagerPrinterID]        [nvarchar](50)  NULL
);
GO
PRINT 'Created UDT restaurant.Sync_Section_Setting_UDT (26 columns).';
GO

-- restaurant.UDT_R_EinvoiceStatus
IF EXISTS (SELECT 1 FROM sys.types WHERE name = 'UDT_R_EinvoiceStatus' AND is_table_type = 1 AND schema_id = SCHEMA_ID('restaurant'))
BEGIN
    DROP TYPE [restaurant].[UDT_R_EinvoiceStatus];
    PRINT 'Dropped existing UDT restaurant.UDT_R_EinvoiceStatus.';
END
GO
CREATE TYPE [restaurant].[UDT_R_EinvoiceStatus] AS TABLE(
    [GuID] [varchar](50) NOT NULL,
    [BillNo] [varchar](50) NOT NULL,
    [BillDateTime] [datetime] NOT NULL,
    [xmlFileName] [varchar](250) NULL,
    [ResponseStatus] [varchar](250) NULL,
    [ResponseMsg] [varchar](250) NULL,
    [InvoiceType] [varchar](50) NULL,
    [InvoiceHash] [varchar](250) NULL,
    [ReSubmitStatus] [varchar](50) NULL,
    [Version] [bigint] NULL
);
GO
PRINT 'Created UDT restaurant.UDT_R_EinvoiceStatus.';
GO

-- restaurant.SectionWiseProductImportDetail_UDT
IF EXISTS (SELECT 1 FROM sys.types WHERE name = 'SectionWiseProductImportDetail_UDT' AND is_table_type = 1 AND schema_id = SCHEMA_ID('restaurant'))
BEGIN
    DROP TYPE [restaurant].[SectionWiseProductImportDetail_UDT];
    PRINT 'Dropped existing UDT restaurant.SectionWiseProductImportDetail_UDT.';
END
GO
CREATE TYPE [restaurant].[SectionWiseProductImportDetail_UDT] AS TABLE(
    [MasterID] [uniqueidentifier] NOT NULL,
    [SectionName] [varchar](max) NOT NULL,
    [Price] [decimal](18, 14) NULL,
    [IsActive] [bit] NULL
);
GO
PRINT 'Created UDT restaurant.SectionWiseProductImportDetail_UDT.';
GO

-- restaurant.ProductPriceUDT
IF EXISTS (SELECT 1 FROM sys.types WHERE name = 'ProductPriceUDT' AND is_table_type = 1 AND schema_id = SCHEMA_ID('restaurant'))
BEGIN
    DROP TYPE [restaurant].[ProductPriceUDT];
    PRINT 'Dropped existing UDT restaurant.ProductPriceUDT.';
END
GO
CREATE TYPE [restaurant].[ProductPriceUDT] AS TABLE(
    [MasterID] [uniqueidentifier] NOT NULL,
    [BasePrice] [decimal](18, 8) NOT NULL,
    [Cost] [decimal](18, 8) NOT NULL,
    [CategoryID] [uniqueidentifier] NOT NULL,
    [GroupID] [uniqueidentifier] NOT NULL,
    [IsVariableProduct] [bit] NOT NULL,
    [IsStockItem] [bit] NOT NULL,
    [IsDailyStockItem] [bit] NOT NULL,
    [IsActive] [bit] NOT NULL,
    [IsMenuItem] [bit] NOT NULL
);
GO
PRINT 'Created UDT restaurant.ProductPriceUDT.';
GO

-- restaurant.Sync_SalesLog_UDT
IF EXISTS (SELECT 1 FROM sys.types WHERE name = 'Sync_SalesLog_UDT' AND is_table_type = 1 AND schema_id = SCHEMA_ID('restaurant'))
BEGIN
    DROP TYPE [restaurant].[Sync_SalesLog_UDT];
    PRINT 'Dropped existing UDT restaurant.Sync_SalesLog_UDT.';
END
GO
CREATE TYPE [restaurant].[Sync_SalesLog_UDT] AS TABLE(
    [GuID] [uniqueidentifier] NOT NULL,
    [MasterID] [uniqueidentifier] NOT NULL,
    [ProductID] [uniqueidentifier] NOT NULL,
    [Quantity] [decimal](18, 8) NULL,
    [NewQuantity] [decimal](18, 8) NULL,
    [BaseQuantity] [decimal](18, 8) NULL,
    [UnitRate] [decimal](18, 8) NULL,
    [TaxID] [uniqueidentifier] NULL,
    [TaxPercentage] [decimal](18, 8) NULL,
    [Tax] [decimal](18, 4) NULL,
    [DiscPercentage] [decimal](18, 8) NULL,
    [Discount] [decimal](18, 8) NULL,
    [UnitID] [uniqueidentifier] NOT NULL,
    [Deleted] [bit] NULL,
    [IsTaxIncludedInPrice] [bit] NULL,
    [Cancelled] [bit] NULL,
    [Merged] [bit] NULL,
    [IsUD] [bit] NULL,
    [IsDD] [bit] NULL,
    [UDate] [datetime] NULL,
    [UUser] [int] NULL,
    [EditType] [nvarchar](max) NULL,
    [NewUnitRate] [decimal](18, 8) NULL DEFAULT ((0)),
    [UUserGuid] [uniqueidentifier] NULL
);
GO
PRINT 'Created UDT restaurant.Sync_SalesLog_UDT.';
GO

-- restaurant.UDT_ProductImage (Web-only image UDT — ensure it exists on Windows DB too)
IF NOT EXISTS (SELECT 1 FROM sys.types WHERE name = 'UDT_ProductImage' AND is_table_type = 1 AND schema_id = SCHEMA_ID('restaurant'))
BEGIN
    CREATE TYPE [restaurant].[UDT_ProductImage] AS TABLE(
        [ProductGuid] [uniqueidentifier] NOT NULL,
        [ImageURL] [nvarchar](500) NOT NULL,
        [ThumbnailURL] [nvarchar](500) NULL,
        [IsPrimary] [bit] NOT NULL,
        [CreatedDate] [datetime] NULL
    );
    PRINT 'Created UDT restaurant.UDT_ProductImage.';
END
ELSE
    PRINT 'UDT restaurant.UDT_ProductImage already exists.';
GO

-- dbo.UDT_ProductImage
IF NOT EXISTS (SELECT 1 FROM sys.types WHERE name = 'UDT_ProductImage' AND schema_id = SCHEMA_ID('dbo') AND is_table_type = 1)
BEGIN
    CREATE TYPE [dbo].[UDT_ProductImage] AS TABLE(
        [ProductGuid] [uniqueidentifier] NOT NULL,
        [ImageURL] [nvarchar](500) NOT NULL,
        [ThumbnailURL] [nvarchar](500) NULL,
        [IsPrimary] [bit] NOT NULL,
        [CreatedDate] [datetime] NULL
    );
    PRINT 'Created UDT dbo.UDT_ProductImage.';
END
ELSE
    PRINT 'UDT dbo.UDT_ProductImage already exists.';
GO

-- ============================================================
-- SECTION F: ALL STORED PROCEDURES (CREATE OR ALTER)
-- ============================================================
PRINT 'Section F: Creating/altering stored procedures...';
GO

-- Drop and recreate the unified LedgerOB function
IF OBJECT_ID('dbo.LedgerOB', 'FN') IS NOT NULL OR OBJECT_ID('dbo.LedgerOB', 'FS') IS NOT NULL OR OBJECT_ID('dbo.LedgerOB', 'FT') IS NOT NULL
BEGIN
    DROP FUNCTION dbo.LedgerOB;
    PRINT 'Dropped function dbo.LedgerOB.';
END
GO

CREATE FUNCTION [dbo].[LedgerOB] (
    @LedgerID varchar(max),
    @EndDate datetime,
    @IsDebit bit,
    @BranchID varchar(max),
    @userID int = NULL
)
RETURNS money
AS
BEGIN
    DECLARE @OB money;
    DECLARE @M money;
    if(@BranchID!='' and @BranchID!='00000000-0000-0000-0000-000000000000')
    begin
        SELECT @OB = (case when (@IsDebit=1) then ISNULL(SUM(LBO.Debit),0) else ISNULL(sum(LBO.Credit),0) end) 
        from LedgerBranchOpeningDetail LBO 
        inner join R_Ledger L on L.GuID=LBO.LedgerID 
        inner join LedgerBranchOpeningMaster LBM on LBM.GuID=LBO.MasterID 
        where LBO.LedgerID = @LedgerID and LBM.BranchID=@BranchID;   

        SELECT @M = isnull(sum(Amount),0) 
        from restaurant.Voucher 
        where Date < @EndDate and LedgerID = @LedgerID and BranchID=@BranchID and isDebit =@IsDebit;
    end
    else
    begin
        SELECT @OB = (case when (@IsDebit=1) then ISNULL(SUM(LBO.Debit),0) else ISNULL(sum(LBO.Credit),0) end) 
        from LedgerBranchOpeningDetail LBO 
        inner join R_Ledger L on L.GuID=LBO.LedgerID 
        inner join LedgerBranchOpeningMaster LBM on LBM.GuID=LBO.MasterID 
        where LBO.LedgerID = @LedgerID;   

        SELECT @M = isnull(sum(Amount),0) 
        from restaurant.Voucher 
        where Date < @EndDate and LedgerID = @LedgerID and isDebit =@IsDebit;
    end
    SET @M = @M + isnull(@OB,0);    
    RETURN isnull(@M,0)
END
GO
PRINT 'Created unified function dbo.LedgerOB.';
GO

-- SP: GetProductsBySectionAndCategoryMaster
CREATE OR ALTER PROCEDURE [restaurant].[GetProductsBySectionAndCategoryMaster]
    @SectionID UNIQUEIDENTIFIER,
    @CategoryMasterGuID UNIQUEIDENTIFIER = null
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.GuID, P.Name, P.CategoryID, P.ArabicDescription,
        D.SectionID, D.Price,
        ISNULL(D.TaxID, '00000000-0000-0000-0000-000000000000') AS TaxID,
        ISNULL(D.IsTaxIncludedInPrice, 0) AS IsTaxIncludedInPrice,
        ISNULL(T.Percentage, 0) AS TaxPer,
        P.IsDailyStockItem, ISNULL(P.IsVariableProduct, 0) AS IsVariableProduct
    FROM dbo.R_Product P
    LEFT JOIN dbo.R_Category C ON P.CategoryID = C.GuID
    INNER JOIN dbo.R_ProductDetail D ON P.GuID = D.MasterID
    LEFT JOIN [R_Tax] T ON D.TaxID = T.GuID
    WHERE D.SectionID = @SectionID
      AND (C.CategoryMasterGuID = @CategoryMasterGuID OR @CategoryMasterGuID IS NULL)
      AND P.Deleted = 0 AND D.Deleted = 0
      AND (C.Deleted = 0 OR C.GuID IS NULL)
      AND P.IsActive = 1 AND D.IsActive = 1
    ORDER BY P.Name;
END
GO
PRINT 'Created or altered SP GetProductsBySectionAndCategoryMaster.';
GO

-- SP: GetActiveProductsByCategoryAndSection
CREATE OR ALTER PROCEDURE [restaurant].[GetActiveProductsByCategoryAndSection]
    @CategoryID UNIQUEIDENTIFIER,
    @SectionID UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.GuID, P.Name, P.CategoryID, P.ArabicDescription,
        D.SectionID, D.Price,
        ISNULL(D.TaxID, '00000000-0000-0000-0000-000000000000') AS TaxID,
        ISNULL(D.IsTaxIncludedInPrice, 0) AS IsTaxIncludedInPrice,
        ISNULL(T.Percentage, 0) AS TaxPer,
        P.IsDailyStockItem, ISNULL(P.IsVariableProduct, 0) AS IsVariableProduct
    FROM [R_Product] P
    INNER JOIN [R_ProductDetail] D ON D.MasterID = P.GuID AND D.SectionID = @SectionID
    LEFT JOIN [R_Tax] T ON T.GuID = D.TaxID
    WHERE P.CategoryID = @CategoryID
      AND ISNULL(P.IsActive, 0) = 1 AND ISNULL(D.IsActive, 0) = 1
      AND ISNULL(P.Deleted, 0) = 0 AND ISNULL(D.Deleted, 0) = 0
    ORDER BY P.Name;
END
GO
PRINT 'Created or altered SP GetActiveProductsByCategoryAndSection.';
GO

-- SP: Report_SalesPAXCountPaging
CREATE OR ALTER PROCEDURE [restaurant].[Report_SalesPAXCountPaging]
(
    @SectionID     VARCHAR(MAX) = NULL,
    @BranchID      VARCHAR(MAX) = NULL,
    @UserID        VARCHAR(MAX) = NULL,
    @FromDate      DATE        = NULL,
    @ToDate        DATE        = NULL,
    @PageNumber    INT         = 1,
    @PageSize      INT         = 50,
    @SortingColumn VARCHAR(MAX) = NULL,
    @SortingDirection VARCHAR(MAX) = 'ASC'
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @ToDate = DATEADD(DAY, 1, @ToDate);
    IF OBJECT_ID('TempDB..#SalesReport') IS NOT NULL DROP TABLE #SalesReport;
    IF OBJECT_ID('TempDB..#SalesReportCount') IS NOT NULL DROP TABLE #SalesReportCount;
    SELECT *
    INTO #SalesReport
    FROM
    (
        SELECT DISTINCT SM.[No], SM.BillNo, SM.TransactionDate, SM.BillTime AS BillDate,
            S.Name AS Section, B.Name AS Branch, U.Name AS [User], ST.Name AS TableName,
            ZM.Name AS ZoneName, 0 AS ChairNo, SM.Pax, SM.LastUpdate
        FROM R_SalesMaster SM
            LEFT JOIN restaurant.Section S ON S.[GuID] = SM.SectionID
            LEFT JOIN R_Branch B ON B.[GuID] = SM.BranchID
            LEFT JOIN R_User U ON U.[GuID] = SM.WaiterID
            LEFT JOIN R_SectionTables ST ON ST.GUID = SM.TableID
            LEFT JOIN restaurant.ZoneMaster ZM ON ZM.GuID = S.ZoneGuID
            LEFT JOIN R_SalesDetail SD ON SD.MasterID = SM.GuID
        WHERE (@SectionID IS NULL OR S.[GuID] = @SectionID)
          AND (@BranchID IS NULL OR B.[GuID] = @BranchID)
          AND (@UserID IS NULL OR U.[GuID] = @UserID)
          AND (@FromDate IS NULL OR SM.TransactionDate >= @FromDate)
          AND (@ToDate IS NULL OR SM.TransactionDate < @ToDate)
        UNION ALL
        SELECT DISTINCT SM.[No], SM.BillNo, SM.TransactionDate, SM.BillTime AS BillDate,
            S.Name AS Section, B.Name AS Branch, U.Name AS [User], ST.Name AS TableName,
            ZM.Name AS ZoneName, 0 AS ChairNo, SM.Pax, SM.LastUpdate
        FROM R_SalesTempMaster SM
            LEFT JOIN restaurant.Section S ON S.[GuID] = SM.SectionID
            LEFT JOIN R_Branch B ON B.[GuID] = SM.BranchID
            LEFT JOIN R_User U ON U.[GuID] = SM.WaiterID
            LEFT JOIN R_SectionTables ST ON ST.GUID = SM.TableID
            LEFT JOIN restaurant.ZoneMaster ZM ON ZM.GuID = S.ZoneGuID
            LEFT JOIN R_SalesTempDetail SD ON SD.MasterID = SM.GuID
        WHERE (@SectionID IS NULL OR S.[GuID] = @SectionID)
          AND (@BranchID IS NULL OR B.[GuID] = @BranchID)
          AND (@UserID IS NULL OR U.[GuID] = @UserID)
          AND (@FromDate IS NULL OR SM.TransactionDate >= @FromDate)
          AND (@ToDate IS NULL OR SM.TransactionDate < @ToDate)
    ) AS SalesDetail;
    SELECT COUNT(*) AS SalesCount INTO #SalesReportCount FROM #SalesReport;
    DECLARE @R_PageNumber INT = @PageNumber, @R_PageSize INT = @PageSize,
            @R_SortingColumn VARCHAR(MAX) = @SortingColumn, @R_SortingDirection VARCHAR(MAX) = @SortingDirection;
    DECLARE @SortingCmd NVARCHAR(MAX);
    IF @R_SortingColumn IS NULL
    BEGIN
        SET @SortingCmd = 'SELECT *,(SELECT SalesCount FROM #SalesReportCount)[RowCount] FROM #SalesReport;';
        EXEC sp_executesql @SortingCmd;
    END
    IF OBJECT_ID('TempDB..#SalesReport') IS NOT NULL DROP TABLE #SalesReport;
    IF OBJECT_ID('TempDB..#SalesReportCount') IS NOT NULL DROP TABLE #SalesReportCount;
    SET NOCOUNT OFF;
END
GO
PRINT 'Created or altered SP Report_SalesPAXCountPaging.';
GO

-- SP: sectionSettings_insert (File 1 version — includes all new columns)
CREATE OR ALTER PROCEDURE [restaurant].[sectionSettings_insert]
(
    @GuID UNIQUEIDENTIFIER,
    @MasterID UNIQUEIDENTIFIER,
    @BranchID UNIQUEIDENTIFIER,
    @EnableKOTPrint BIT,
    @PrintKOTInSalesBillFormat BIT,
    @PrintKOTInSalesBillPrinter BIT,
    @PrintBothSalesAndKOTPrint BIT,
    @ShowPopupToCaptureCustomerDetail BIT,
    @ShowPopupToSelectWaiter BIT,
    @ShowPopupToSelectTable BIT,
    @PrintFileName VARCHAR(50),
    @NumberOfKOTPrints INT,
    @BillStartNumber INT,
    @InvoicePrefix VARCHAR(10),
    @TaxId UNIQUEIDENTIFIER,
    @UpdatedUser UNIQUEIDENTIFIER = NULL,
    @IsMultiOrderEnabled BIT,
    @InvoicePrinterID UNIQUEIDENTIFIER = NULL,
    @IsPaxEnabled BIT,
    @isChairEnabled BIT,
    @IsCashButtonPrint BIT = 1,
    @IsPayScreenPrintOnSettle BIT = 0,
    @IsKitchenManagerPrintEnabled BIT = 0,
    @KitchenManagerPrinterID NVARCHAR(50) = NULL
)
AS
DECLARE @NewGuid UNIQUEIDENTIFIER = NULL
    IF EXISTS (SELECT 1 FROM restaurant.SectionSettings WHERE [MasterID] = @MasterID AND BranchID = @BranchID)
    BEGIN
        UPDATE restaurant.SectionSettings
        SET
            IsTableEnable = @ShowPopupToSelectTable,
            IsWaiterEnable = @ShowPopupToSelectWaiter,
            IsCustomerEnable = @ShowPopupToCaptureCustomerDetail,
            IsKOTSalesPrint = @PrintKOTInSalesBillFormat,
            IsKOTinReceiptPrinter = @PrintKOTInSalesBillPrinter,
            IsKOTPrint = @EnableKOTPrint,
            IsSalesPrintOnSave = @PrintBothSalesAndKOTPrint,
            PrintTempFile = @PrintFileName,
            NoOfPrints = @NumberOfKOTPrints,
            StartNo = @BillStartNumber,
            InvoicePrefix = @InvoicePrefix,
            TaxId = @TaxId,
            UpdatedUser = @UpdatedUser,
            UpdatedDate = GETDATE(),
            IsMultiOrderEnabled = @IsMultiOrderEnabled,
            InvoicePrinterID = @InvoicePrinterID,
            IsPaxEnabled = @IsPaxEnabled,
            isChairEnabled = @isChairEnabled,
            IsCashButtonPrint = @IsCashButtonPrint,
            IsPayScreenPrintOnSettle = @IsPayScreenPrintOnSettle,
            IsKitchenManagerPrintEnabled = @IsKitchenManagerPrintEnabled,
            KitchenManagerPrinterID = @KitchenManagerPrinterID
        WHERE [MasterID] = @MasterID AND BranchID = @BranchID
    END
    ELSE
    BEGIN
        SET @NewGuid = NEWID()
        INSERT INTO restaurant.SectionSettings
        ([GuID],MasterID,BranchID,IsTableEnable,IsWaiterEnable,IsCustomerEnable,IsKOTSalesPrint,IsKOTinReceiptPrinter,IsKOTPrint,IsSalesPrintOnSave,
         PrintTempFile,NoOfPrints,StartNo,InvoicePrefix,TaxId,CreatedUser,CreatedDate,UpdatedUser,UpdatedDate,
         IsMultiOrderEnabled,InvoicePrinterID,IsPaxEnabled,isChairEnabled,IsCashButtonPrint,
         IsPayScreenPrintOnSettle,IsKitchenManagerPrintEnabled,KitchenManagerPrinterID)
        VALUES
        (@NewGuid,@MasterID,@BranchID,@ShowPopupToSelectTable,@ShowPopupToSelectWaiter,@ShowPopupToCaptureCustomerDetail,@PrintKOTInSalesBillFormat,@PrintKOTInSalesBillPrinter,
         @EnableKOTPrint,@PrintBothSalesAndKOTPrint,@PrintFileName,@NumberOfKOTPrints,@BillStartNumber,@InvoicePrefix,@TaxId,@UpdatedUser,GETDATE(),@UpdatedUser,GETDATE(),
         @IsMultiOrderEnabled,@InvoicePrinterID,@IsPaxEnabled,@isChairEnabled,@IsCashButtonPrint,
         @IsPayScreenPrintOnSettle,@IsKitchenManagerPrintEnabled,@KitchenManagerPrinterID)
    END
GO
PRINT 'Created or altered SP sectionSettings_insert.';
GO

-- SP: SectionSettings_GetAllByBranch (File 1 version — includes all new columns)
CREATE OR ALTER PROCEDURE [restaurant].[SectionSettings_GetAllByBranch]
(
 @MasterID  VARCHAR(500) = NULL,
 @BranchID  VARCHAR(500) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT [ID],[GuID],[MasterID],[BranchID],[PrintTempFile],[InvoicePrefix],[StartNo],[TaxID],[DepartmentID],
           [IsTableEnable],[IsWaiterEnable],[IsCustomerEnable],[IsKOTSalesPrint],[IsKOTPrint],[IsKOTinReceiptPrinter],
           [IsSalesPrintOnSave],[NoOfPrints],IsMultiOrderEnabled,InvoicePrinterID,IsPaxEnabled,isChairEnabled,
           IsCashButtonPrint,IsPayScreenPrintOnSettle,IsKitchenManagerPrintEnabled,KitchenManagerPrinterID
    FROM [restaurant].[SectionSettings]
    WHERE (MasterID = @MasterID OR @MasterID IS NULL) AND (BranchID = @BranchID OR @BranchID IS NULL);
    SET NOCOUNT OFF;
END
GO
PRINT 'Created or altered SP SectionSettings_GetAllByBranch.';
GO

-- SP: GetAllSectionSettings (File 1 version — includes all new columns)
CREATE OR ALTER PROCEDURE [restaurant].[GetAllSectionSettings]
(
    @Version BIGINT = NULL,
    @BranchID UNIQUEIDENTIFIER = NULL
)
AS
BEGIN
    SELECT MasterID AS SectionGuID,PrintTempFile,NoOfPrints,InvoicePrefix,StartNo,TaxID,DepartmentID,
           IsTableEnable,IsWaiterEnable,IsCustomerEnable,IsKOTSalesPrint,IsKOTPrint,
           IsKOTinReceiptPrinter,IsSalesPrintOnSave,CAST(Version AS BIGINT)[Version],
           CreatedUser,CreatedDate,UpdatedUser,UpdatedDate,
           IsMultiOrderEnabled,InvoicePrinterID,IsPaxEnabled,isChairEnabled,
           IsCashButtonPrint,IsPayScreenPrintOnSettle,IsKitchenManagerPrintEnabled,KitchenManagerPrinterID
    FROM restaurant.SectionSettings
    WHERE ([Version] > @Version OR @Version IS NULL)
      AND BranchID = @BranchID
END
GO
PRINT 'Created or altered SP GetAllSectionSettings.';
GO

-- SP: Sync_Product_Insert (File 1 version — CREATE OR ALTER with ProductImageDetail UDT)
CREATE OR ALTER PROCEDURE [restaurant].[Sync_Product_Insert]
    @UDT_R_Product                [restaurant].[Sync_Product_UDT]                  READONLY,
    @UDT_SectionWiseProductDetail [restaurant].[Sync_SectionWiseProductDetail_UDT]  READONLY,
    @UDT_R_ComboProduct           [restaurant].[Sync_ComboProduct_UDT]              READONLY,
    @UDT_R_ProductModifier        [restaurant].[ProductModifierDetail]              READONLY,
    @UDT_R_ProductImage           [restaurant].[ProductImageDetail]                 READONLY
AS
BEGIN TRY
    BEGIN TRANSACTION
        MERGE R_Product AS P USING
        (
            SELECT [GuID],[Name],[ShortName],Barcode,RefCode,TypeID,UnitID,
                CategoryID,BranchID,[Image],IsVariableProduct,ArabicDescription,
                IsStockItem,ERPProductID,GroupID,ColorID,VegTypeNo,OtherDescription,
                Loyalty,Cost,CessPercentage,SCategoryID,IsActive,Deleted,IsDailyStockItem,
                BasePrice,CreatedUser,CreatedDate,UpdatedUser,UpdatedDate,MenuItem,HSNCode,ProductionQuantity,Calories,ImgDescription
            FROM @UDT_R_Product
        )UP ON UP.[GuID] = P.[GuID]
        WHEN MATCHED THEN UPDATE SET
            P.[GuID]=UP.[GuID],P.Name=UP.Name,P.[ShortName]=UP.[ShortName],P.Barcode=UP.Barcode,
            P.RefCode=UP.RefCode,P.TypeID=UP.TypeID,P.UnitID=UP.UnitID,P.CategoryID=UP.CategoryID,
            P.BranchID=UP.BranchID,P.[Image]=UP.[Image],P.IsVariableProduct=UP.IsVariableProduct,
            P.ArabicDescription=UP.ArabicDescription,P.IsStockItem=UP.IsStockItem,
            P.ERPProductID=UP.ERPProductID,P.GroupID=UP.GroupID,P.ColorID=UP.ColorID,
            P.VegTypeNo=UP.VegTypeNo,P.OtherDescription=UP.OtherDescription,P.Loyalty=UP.Loyalty,
            P.Cost=UP.Cost,P.CessPercentage=UP.CessPercentage,P.SCategoryID=UP.SCategoryID,
            P.IsActive=UP.IsActive,P.Deleted=UP.Deleted,P.IsDailyStockItem=UP.IsDailyStockItem,
            P.BasePrice=UP.BasePrice,P.CreatedUser=UP.CreatedUser,P.CreatedDate=UP.CreatedDate,
            P.UpdatedUser=UP.UpdatedUser,P.UpdatedDate=UP.UpdatedDate,P.MenuItem=UP.MenuItem,
            P.HSNCode=UP.HSNCode,P.ProductionQuantity=UP.ProductionQuantity,
            P.Calories=UP.Calories,P.ImgDescription=UP.ImgDescription
        WHEN NOT MATCHED THEN INSERT
        (
            [GuID],[Name],[ShortName],Barcode,RefCode,TypeID,UnitID,CategoryID,BranchID,[Image],
            IsVariableProduct,ArabicDescription,IsStockItem,ERPProductID,GroupID,ColorID,VegTypeNo,
            OtherDescription,Loyalty,Cost,CessPercentage,SCategoryID,IsActive,Deleted,IsDailyStockItem,
            BasePrice,CreatedUser,CreatedDate,UpdatedUser,UpdatedDate,MenuItem,HSNCode,ProductionQuantity,Calories,ImgDescription
        )
        VALUES
        (
            UP.[GuID],UP.[Name],UP.[ShortName],UP.Barcode,UP.RefCode,UP.TypeID,UP.UnitID,UP.CategoryID,UP.BranchID,UP.[Image],
            UP.IsVariableProduct,UP.ArabicDescription,UP.IsStockItem,UP.ERPProductID,UP.GroupID,UP.ColorID,UP.VegTypeNo,
            UP.OtherDescription,UP.Loyalty,UP.Cost,UP.CessPercentage,UP.SCategoryID,UP.IsActive,UP.Deleted,UP.IsDailyStockItem,
            UP.BasePrice,UP.CreatedUser,UP.CreatedDate,UP.UpdatedUser,UP.UpdatedDate,UP.MenuItem,UP.HSNCode,UP.ProductionQuantity,UP.Calories,UP.ImgDescription
        );

        MERGE R_ProductDetail AS PD USING
        (
            SELECT USD.[GuID],[MasterID],[SectionID],
                CASE WHEN USD.IsTaxIncludedInPrice = 1 THEN ISNULL(USD.Price/(100+(Percentage))*100,0) ELSE ISNULL(Price,0) END AS Price,
                [TaxID],[IsTaxIncludedInPrice],[DiscountID],[IsActive],
                USD.Deleted,USD.CreatedUser,USD.CreatedDate,USD.UpdatedUser,USD.UpdatedDate
            FROM @UDT_SectionWiseProductDetail USD
            LEFT OUTER JOIN R_Tax tx ON tx.GuID = USD.[TaxID]
        )UPD ON UPD.[GuID] = PD.[GuID] AND UPD.[MasterID] = PD.[MasterID]
        WHEN MATCHED THEN UPDATE SET
            [SectionID]=UPD.[SectionID],[Price]=UPD.[Price],[TaxID]=UPD.[TaxID],
            [IsTaxIncludedInPrice]=UPD.[IsTaxIncludedInPrice],[IsActive]=UPD.[IsActive],
            [Deleted]=UPD.[Deleted],CreatedUser=UPD.CreatedUser,CreatedDate=UPD.CreatedDate,
            UpdatedUser=UPD.UpdatedUser,UpdatedDate=UPD.UpdatedDate
        WHEN NOT MATCHED THEN INSERT
        ([GuID],[MasterID],[SectionID],[Price],[TaxID],[IsTaxIncludedInPrice],[DiscountID],[IsActive],[Deleted],CreatedUser,CreatedDate,UpdatedUser,UpdatedDate)
        VALUES(UPD.[GuID],UPD.[MasterID],UPD.[SectionID],UPD.[Price],UPD.[TaxID],UPD.[IsTaxIncludedInPrice],UPD.[DiscountID],UPD.[IsActive],UPD.[Deleted],UPD.CreatedUser,UPD.CreatedDate,UPD.UpdatedUser,UPD.UpdatedDate);

        UPDATE R_productdetail SET IsTaxIncludedInPrice=0;

        MERGE R_ComboProducts AS CP USING
        (SELECT [MasterProductID],[ProductID],[Quantity],[TypeID],[Deleted] FROM @UDT_R_ComboProduct)
        UCP ON UCP.[MasterProductID] = CP.[MasterProductID]
        WHEN MATCHED THEN UPDATE SET [ProductID]=UCP.[ProductID],[TypeID]=UCP.[TypeID],[Deleted]=UCP.[Deleted]
        WHEN NOT MATCHED THEN INSERT ([MasterProductID],[ProductID],[Quantity],[TypeID],[Deleted])
        VALUES(UCP.[MasterProductID],UCP.[ProductID],UCP.[Quantity],UCP.[TypeID],UCP.[Deleted]);

        -- Delete old modifiers for the products being synced
        DELETE FROM R_ProductModifiers
        WHERE ProductID IN (SELECT DISTINCT MasterProductID FROM @UDT_R_ProductModifier);

        -- Insert fresh modifiers
        INSERT INTO R_ProductModifiers (ProductID, ModifierID, ExtraCharge, IsDefault)
        SELECT MasterProductID, ModifierID, ExtraCharge, IsDefault FROM @UDT_R_ProductModifier;

        DELETE FROM R_ProductImage;

        INSERT INTO R_ProductImage (ProductGuID, ImageURL, ThumbnailURL, IsPrimary, CreatedDate, CreatedUser, UpdatedDate, UpdatedUser)
        SELECT ProductGuID, ImageURL, ThumbnailURL, IsPrimary, CreatedDate, CreatedUser, UpdatedDate, UpdatedUser
        FROM @UDT_R_ProductImage;

    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    RETURN -1;
END CATCH;
RETURN 1;
GO
PRINT 'Created or altered SP Sync_Product_Insert.';
GO

-- SP: table_getBySectionId
CREATE OR ALTER PROCEDURE [restaurant].[table_getBySectionId]
(
    @SectionId UNIQUEIDENTIFIER,
    @BranchID UNIQUEIDENTIFIER = null
)
AS
SELECT
    T.*,
    CASE WHEN S.TableID IS NULL OR S.IsPending = 0 THEN 0 ELSE 1 END AS TableInUse,
    ISNULL(
        STUFF((
            SELECT DISTINCT ',' + CAST(D1.ChairNo AS VARCHAR(10))
            FROM R_SalesDetail D1
            INNER JOIN R_SalesMaster S1 ON S1.Guid = D1.MasterID
            WHERE S1.TableID = T.Guid AND S1.IsPending = 1
              AND S1.Deleted = 0 AND S1.Cancelled = 0 AND D1.Deleted = 0
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
    , '') AS ChairsInUse,
    S.BillTime, S.OrderType, (S.RTotal + S.Tax) AS Amount
FROM R_SectionTables T
LEFT JOIN R_SalesMaster S ON T.Guid = S.TableID AND S.IsPending = 1 AND S.Deleted = 0 AND S.Cancelled = 0
WHERE T.SectionId = @SectionId AND T.Deleted = 0
GO
PRINT 'Created or altered SP table_getBySectionId.';
GO

-- SP: Category_Insert
CREATE OR ALTER PROCEDURE [restaurant].[Category_Insert]
(
    @Guid UNIQUEIDENTIFIER = NULL,
    @Name VARCHAR(50) = NULL,
    @ShortName VARCHAR(50) = NULL,
    @Course INT = NULL,
    @BranchID UNIQUEIDENTIFIER = NULL,
    @UpdatedUser UNIQUEIDENTIFIER = NULL,
    @CategoryMasterGuID UNIQUEIDENTIFIER = NULL
)
AS
DECLARE @NewGuid UNIQUEIDENTIFIER = NULL
BEGIN
    IF @Guid IS NOT NULL
    BEGIN
        IF NOT EXISTS(SELECT * FROM R_Category WHERE [Name]=@Name AND Deleted = 0 AND [Guid] != @Guid)
        BEGIN
            UPDATE R_Category SET [Name]=@Name,ShortName=@ShortName,Course=@Course,UpdatedUser=@UpdatedUser,
                CategoryMasterGuID=@CategoryMasterGuID,UpdatedDate=GETDATE() WHERE [Guid]=@Guid;
            UPDATE restaurant.CategoryLocationMapping SET UpdatedUser=@UpdatedUser,UpdatedDate=GETDATE(),
                CategoryMasterGuID=@CategoryMasterGuID WHERE BranchID=@BranchID AND CategoryID=@Guid;
        END
        ELSE THROW 51000, 'Same data already exists...', 1
    END
    ELSE
    BEGIN
        SET @NewGuid = NEWID()
        IF NOT EXISTS(SELECT * FROM R_Category WHERE Name=@Name AND Deleted=0)
        BEGIN
            INSERT INTO R_Category([GuID],[Name],ShortName,Course,CreatedUser,CreatedDate,UpdatedUser,CategoryMasterGuID,UpdatedDate)
            VALUES(@NewGuid,@Name,@ShortName,@Course,@UpdatedUser,GETDATE(),@UpdatedUser,@CategoryMasterGuID,GETDATE());
        END
        ELSE THROW 51000, 'Same data already exists...', 1
        INSERT INTO restaurant.CategoryLocationMapping(CategoryID,BranchID,IsActive,CreatedUser,CreatedDate,UpdatedUser,UpdatedDate,CategoryMasterGuID)
        VALUES(@NewGuid,@BranchID,1,@UpdatedUser,GETDATE(),@UpdatedUser,GETDATE(),@CategoryMasterGuID);
    END
END
SET ANSI_NULLS ON
GO
PRINT 'Created or altered SP Category_Insert.';
GO

-- SP: Sync_Category_GetAll
CREATE OR ALTER PROCEDURE [restaurant].[Sync_Category_GetAll]
(
    @Version BIGINT = NULL,
    @BranchID UNIQUEIDENTIFIER = NULL
)
AS
    SET NOCOUNT ON
    SELECT C.ID,C.[Guid],Name,ShortName,Course,Convert(Bigint,CLM.[Version])[Version],
        CASE WHEN CLM.IsActive = 0 THEN 1 ELSE C.Deleted END AS Deleted,
        CLM.CreatedUser,CLM.CreatedDate,CLM.UpdatedUser,CLM.UpdatedDate,CLM.CategoryMasterGuID
    FROM restaurant.CategoryLocationMapping CLM
    INNER JOIN R_Category C ON CLM.CategoryID = C.GuID AND CLM.BranchID = @BranchID
    WHERE CLM.[Version] > @Version
    SET NOCOUNT OFF
    SET ANSI_NULLS ON
GO
PRINT 'Created or altered SP Sync_Category_GetAll.';
GO

-- SP: Category_GetAllByBranch
CREATE OR ALTER PROCEDURE [restaurant].[Category_GetAllByBranch]
(
 @BranchID VARCHAR(500) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT C.ID,C.[GuID],[Name],ShortName,CONVERT(BIGINT,C.[Version])[Version],Deleted,Course,CLM.IsActive,CLM.CategoryMasterGuID
    FROM restaurant.CategoryLocationMapping CLM
    INNER JOIN R_Category C ON CLM.CategoryID = C.[GuID]
    WHERE (BranchID = @BranchID) AND CLM.IsActive = 1
    ORDER BY [Name]
END
GO
PRINT 'Created or altered SP Category_GetAllByBranch.';
GO

-- SP: GET_TableDETAILSBySectionId_MOBAPP
CREATE OR ALTER PROCEDURE [restaurant].[GET_TableDETAILSBySectionId_MOBAPP]
(
    @SectionId UNIQUEIDENTIFIER
)
AS
BEGIN
    DECLARE @IsTableEnable BIT;
    SELECT @IsTableEnable = IsTableEnable FROM R_Section WHERE Guid = @SectionId;
    IF (@IsTableEnable = 1)
    BEGIN
        SELECT T.*,
            CASE WHEN S.TableID IS NULL OR S.IsPending = 0 THEN 0 ELSE 1 END AS TableInUse,
            ISNULL(STUFF((
                SELECT DISTINCT ',' + CAST(D1.ChairNo AS VARCHAR(10))
                FROM R_SalesDetail D1 INNER JOIN R_SalesMaster S1 ON S1.Guid = D1.MasterID
                WHERE S1.TableID = T.Guid AND S1.IsPending = 1 AND S1.Deleted = 0 AND S1.Cancelled = 0 AND D1.Deleted = 0
                FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), '') AS ChairsInUse,
            S.BillTime, S.OrderType, (S.RTotal + S.Tax) AS Amount, S.IsprintedFromPay, IsKotPrinted
        FROM R_SectionTables T
        LEFT JOIN R_SalesMaster S ON T.Guid = S.TableID AND S.IsPending = 1 AND S.Deleted = 0 AND S.Cancelled = 0
        WHERE T.SectionId = @SectionId AND T.Deleted = 0;
    END
    ELSE
    BEGIN
        SELECT '' AS Guid, 'No Table' AS Name, NULL AS SectionID, NULL AS Capacity, NULL AS Version,
            NULL AS Deleted, NULL AS BranchID, NULL AS CreatedUser, NULL AS CreatedDate, NULL AS UpdatedUser,
            NULL AS UpdatedDate, 1 AS TableInUse, '' AS ChairsInUse,
            S.BillTime, S.OrderType, (S.RTotal + S.Tax) AS Amount, S.IsprintedFromPay, IsKotPrinted
        FROM R_SalesMaster S
        WHERE S.SectionID = @SectionId AND (S.TableID IS NULL OR S.TableID = '')
          AND S.IsPending = 1 AND S.Deleted = 0 AND S.Cancelled = 0;
    END
END
GO
PRINT 'Created or altered SP GET_TableDETAILSBySectionId_MOBAPP.';
GO

-- SP: TableOrderIndicator
CREATE OR ALTER PROCEDURE [dbo].[TableOrderIndicator]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ISNULL(T.Name,'Default') as [Table],TableID,S.Name as Section,m.SectionID,M.BillTime,
        M.NoOfChairs,M.ChairPositions,M.ID,
        CASE WHEN IsprintedFromPay = 0 AND IsPending = 1 THEN 'N'
             WHEN IsprintedFromPay = 1 AND IsPending = 1 THEN 'P'
             ELSE 'C' END AS [Status],
        (M.RTotal + M.Tax) as Amount, M.IsKotPrinted, U.Name as WaiterName
    FROM [R_SalesMaster] M
    INNER JOIN R_Section S ON S.GuID = M.SectionID
    INNER JOIN R_User U ON U.GuID = M.WaiterID
    LEFT OUTER JOIN R_SectionTables T ON T.Guid = M.TableID
    WHERE IsPending = 1 AND M.Deleted <> 1 AND Cancelled = 0
    ORDER BY [Status]
    SET NOCOUNT OFF;
END
GO
PRINT 'Created or altered SP TableOrderIndicator.';
GO

-- SP: usp_TransferDataToTempTable
CREATE OR ALTER PROCEDURE [dbo].[usp_TransferDataToTempTable]
    @ClosingDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO R_SalesTempMaster([GuID],[No],[Date],[SectionID],[CounterID],[BillTime],[CustomerID],[Merged],[Total],[RTotal],[Tax],[Cash],[Card],[CardNo],[FxPaid],[FxTypeID],[FxRate],[FxAmount],[CustomerCredit],[Discount],[DiscountPercentage],[ProdDiscount],[RoundOff],[FinancialYearID],[UserID],[CreatedBy],[Remarks],[CompanyID],[LastUpdate],[BranchID],[Deleted],[Refund],[TransactionDate],[IsPending],[Cancelled],[WaiterID],[CustomerGSTNo],[BillNo],[SeriesType],[TableID],[CancelReason],[Pax],[TabBillNo],[Redeem],[RedeemPoints],[NoOfChairs],[TabID],[ShiftNumber],IsShiftClosed,CardID,CessAmount,IsComplementary,ComplementaryTotal,WaiterRemarks,IsSaved,IsTakenForUpload,EditedAfterUpload,UpdatedUser,LevyTotal,OrderType)
        SELECT [GuID],[No],[Date],[SectionID],[CounterID],[BillTime],[CustomerID],[Merged],[Total],[RTotal],[Tax],[Cash],[Card],[CardNo],[FxPaid],[FxTypeID],[FxRate],[FxAmount],[CustomerCredit],[Discount],[DiscountPercentage],[ProdDiscount],[RoundOff],[FinancialYearID],[UserID],[CreatedBy],[Remarks],[CompanyID],[LastUpdate],[BranchID],[Deleted],[Refund],[TransactionDate],[IsPending],[Cancelled],[WaiterID],[CustomerGSTNo],[BillNo],[SeriesType],[TableID],[CancelReason],[Pax],[TabBillNo],[Redeem],[RedeemPoints],[NoOfChairs],[TabID],[ShiftNumber],IsShiftClosed,CardID,CessAmount,IsComplementary,ComplementaryTotal,WaiterRemarks,IsSaved,IsTakenForUpload,EditedAfterUpload,UpdatedUser,LevyTotal,OrderType
        FROM R_SalesMaster WHERE Cancelled = 1 OR (IsPending = 0 AND CAST(TransactionDate AS DATE) = @ClosingDate);
        INSERT INTO R_SalesTempDetail([GuID],[MasterID],[ProductID],[Quantity],[BaseQuantity],[UnitRate],[TaxID],[TaxPercentage],[Tax],[DiscPercentage],[Discount],[Merged],[UnitID],[ItemTypeID],[Deleted],[IsTaxIncludedInPrice],[Cancelled],[CessAmount],[PromoID],[Levy],[LevyPercentage],ChairNo,CourseNo)
        SELECT D.[GuID],D.[MasterID],D.[ProductID],D.[Quantity],D.[BaseQuantity],D.[UnitRate],D.[TaxID],D.[TaxPercentage],D.[Tax],D.[DiscPercentage],D.[Discount],D.[Merged],D.[UnitID],D.[ItemTypeID],D.[Deleted],D.[IsTaxIncludedInPrice],D.[Cancelled],D.[CessAmount],D.[PromoID],D.[Levy],D.[LevyPercentage],D.ChairNo,D.CourseNo
        FROM R_SalesDetail D INNER JOIN R_SalesMaster M ON D.MasterID = M.GUID
        WHERE M.Cancelled = 1 OR (M.IsPending = 0 AND CAST(M.TransactionDate AS DATE) = @ClosingDate);
        INSERT INTO R_SalesTempComboDetail([DetailGuID],[ProductID],[Quantity],[TypeID],[MasterProductID])
        SELECT C.[DetailGuID],C.[ProductID],C.[Quantity],C.[TypeID],C.[MasterProductID]
        FROM R_SalesComboDetail C INNER JOIN R_SalesDetail D ON C.DetailGuID = D.GUID INNER JOIN R_SalesMaster M ON D.MasterID = M.GUID
        WHERE M.Cancelled = 1 OR (M.IsPending = 0 AND CAST(M.TransactionDate AS DATE) = @ClosingDate);
        INSERT INTO R_SalesTempED([GuID],[MasterID],[ProductID],[Quantity],[BaseQuantity],[UnitRate],[TaxID],[TaxPercentage],[Tax],[DiscPercentage],[Discount],[UnitID],[ItemTypeID],[Deleted],[IsTaxIncludedInPrice],[Cancelled],[NewQuantity],[IsUD],[IsDD],[UDate],[UUser],[EditType],[NewUnitRate])
        SELECT E.[GuID],E.[MasterID],E.[ProductID],E.[Quantity],E.[BaseQuantity],E.[UnitRate],E.[TaxID],E.[TaxPercentage],E.[Tax],E.[DiscPercentage],E.[Discount],E.[UnitID],E.[ItemTypeID],E.[Deleted],E.[IsTaxIncludedInPrice],E.[Cancelled],E.[NewQuantity],E.[IsUD],E.[IsDD],E.[UDate],E.[UUser],E.[EditType],E.[NewUnitRate]
        FROM R_SalesED E INNER JOIN R_SalesMaster M ON E.MasterID = M.GUID
        WHERE M.Cancelled = 1 OR (M.IsPending = 0 AND CAST(M.TransactionDate AS DATE) = @ClosingDate);
        INSERT INTO R_SalesTempPaymentDetail([GuID],[MasterID],[Type],[Amount],[CardNo],[CardTypeID],[FxTypeID],[FxPaid],[FxRate],[CustomerID],[deleted],[Cancelled])
        SELECT P.[GuID],P.[MasterID],P.[Type],P.[Amount],P.[CardNo],P.[CardTypeID],P.[FxTypeID],P.[FxPaid],P.[FxRate],P.[CustomerID],P.[deleted],P.[Cancelled]
        FROM R_SalesPaymentDetail P INNER JOIN R_SalesMaster M ON P.MasterID = M.GUID
        WHERE M.Cancelled = 1 OR (M.IsPending = 0 AND CAST(M.TransactionDate AS DATE) = @ClosingDate);
        INSERT INTO R_SalesTempProductModifierDetail([GUID],[MasterID],[ProductID],[IsVoid],[Rate],[Quantity],[Cancelled],[Merged],[ModifierID],[ParentVoid],[VoidReason],[WastedQty])
        SELECT PM.[GUID],PM.[MasterID],PM.[ProductID],PM.[IsVoid],PM.[Rate],PM.[Quantity],PM.[Cancelled],PM.[Merged],PM.[ModifierID],PM.[ParentVoid],PM.[VoidReason],PM.[WastedQty]
        FROM R_SalesProductModifierDetail PM INNER JOIN R_SalesMaster M ON PM.MasterID = M.GUID
        WHERE M.Cancelled = 1 OR (M.IsPending = 0 AND CAST(M.TransactionDate AS DATE) = @ClosingDate);
        DELETE P FROM R_SalesPaymentDetail P INNER JOIN R_SalesMaster M ON P.MasterID = M.GUID
        WHERE M.Cancelled = 1 OR (M.IsPending = 0 AND CAST(M.TransactionDate AS DATE) = @ClosingDate);
        DELETE C FROM R_SalesComboDetail C INNER JOIN R_SalesDetail D ON C.DetailGuID = D.GUID INNER JOIN R_SalesMaster M ON D.MasterID = M.GUID
        WHERE M.Cancelled = 1 OR (M.IsPending = 0 AND CAST(M.TransactionDate AS DATE) = @ClosingDate);
        DELETE PM FROM R_SalesProductModifierDetail PM INNER JOIN R_SalesMaster M ON PM.MasterID = M.GUID
        WHERE M.Cancelled = 1 OR (M.IsPending = 0 AND CAST(M.TransactionDate AS DATE) = @ClosingDate);
        ALTER TABLE R_SalesED DISABLE TRIGGER [Dltblk];
        DELETE E FROM R_SalesED E INNER JOIN R_SalesMaster M ON E.MasterID = M.GUID
        WHERE M.Cancelled = 1 OR (M.IsPending = 0 AND CAST(M.TransactionDate AS DATE) = @ClosingDate);
        ALTER TABLE R_SalesED ENABLE TRIGGER [Dltblk];
        DELETE D FROM R_SalesDetail D INNER JOIN R_SalesMaster M ON D.MasterID = M.GUID
        WHERE M.Cancelled = 1 OR (M.IsPending = 0 AND CAST(M.TransactionDate AS DATE) = @ClosingDate);
        DELETE FROM R_SalesMaster WHERE Cancelled = 1 OR (IsPending = 0 AND CAST(TransactionDate AS DATE) = @ClosingDate);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
        SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY();
        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END
GO
PRINT 'Created or altered SP usp_TransferDataToTempTable.';
GO

-- SP: GenerateKOTNo
CREATE OR ALTER PROCEDURE [restaurant].[GenerateKOTNo]
(
    @SalesMasterGuid UNIQUEIDENTIFIER,
    @TransactionDate DATE
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @KOTNo INT;
    SELECT @KOTNo = KOTNo FROM restaurant.KOTSequence WHERE SalesMasterGuid = @SalesMasterGuid;
    IF @KOTNo IS NOT NULL
    BEGIN
        SELECT @KOTNo AS KOTNo;
        RETURN;
    END
    SELECT @KOTNo = ISNULL(MAX(KOTNo), 0) + 1 FROM restaurant.KOTSequence WHERE KOTDate = @TransactionDate;
    INSERT INTO restaurant.KOTSequence (SalesMasterGuid, KOTNo, KOTDate) VALUES (@SalesMasterGuid, @KOTNo, @TransactionDate);
    SELECT @KOTNo AS KOTNo;
END
GO
PRINT 'Created or altered SP GenerateKOTNo.';
GO

-- SP: ProductBulkPrice_GetAll
CREATE OR ALTER PROCEDURE [restaurant].[ProductBulkPrice_GetAll]
(
 @BranchID UNIQUEIDENTIFIER = NULL
)
AS
BEGIN
    SELECT P.[GuID],P.[Name],RefCode AS Code,PPD.CategoryID,C.[Name]Category,PPD.GroupID,G.[Name] [Group],PLM.BranchID,ISNULL(PPD.BasePrice,0)BasePrice,ISNULL(PPD.Cost,0)Cost,P.MenuItem
    FROM restaurant.Product P
    INNER JOIN restaurant.ProductPriceDetail PPD ON PPD.MasterID = P.[GuID]
    INNER JOIN restaurant.ProductLocationMapping PLM ON PLM.ProductID = P.[GuID] AND PLM.BranchID = PPD.BranchID AND PLM.IsActive = 1
    INNER JOIN R_Category C ON C.[GuID] = PPD.CategoryID
    INNER JOIN R_GroupEntry G ON G.[Guid] = PPD.GroupID
    WHERE PLM.BranchID = @BranchID AND P.Deleted = 0
    GROUP BY P.[GuID],P.[Name],RefCode,PPD.CategoryID,PPD.GroupID,PLM.BranchID,PPD.BasePrice,PPD.Cost,C.[Name],G.[Name],P.MenuItem
    ORDER BY [Name]

    SELECT MasterID,SectionID,BranchID,Section,Price,IsActive
    FROM (
        SELECT PD.MasterID,PD.SectionID,PD.BranchID,S.[Name]Section,
            CASE WHEN PD.IsTaxIncludedInPrice = 1 THEN ROUND(PD.Price+(PD.Price*(T.[Percentage])/100),4) ELSE PD.Price END AS Price,PD.IsActive
        FROM restaurant.ProductSectionPriceDetail PD
        INNER JOIN restaurant.Section S ON S.[GuID] = PD.SectionID
        INNER JOIN restaurant.SectionLocationMapping SLM ON SLM.SectionID = S.[GuID] AND SLM.BranchID = @BranchID AND S.Deleted = 0 AND SLM.IsActive = 1
        LEFT JOIN R_Tax T ON T.[GuID] = PD.TaxID AND PD.TaxID IS NOT NULL
        WHERE PD.BranchID = @BranchID
        UNION ALL
        SELECT PPD.MasterID,S.[GuID]SectionID,PPD.BranchID,S.[Name] AS Section,0 AS Price,PPD.IsActive
        FROM restaurant.ProductPriceDetail PPD
        CROSS JOIN restaurant.Section S
        INNER JOIN restaurant.SectionLocationMapping SLM ON SLM.SectionID = S.[GuID] AND SLM.BranchID = @BranchID AND S.Deleted = 0 AND SLM.IsActive = 1
        WHERE PPD.MasterID NOT IN (SELECT MasterID FROM restaurant.ProductSectionPriceDetail PD WHERE PD.SectionID = S.[GuID] AND PD.BranchID = @BranchID)
          AND PPD.Deleted = 0 AND PPD.BranchID = @BranchID
        GROUP BY PPD.MasterID,S.[GuID],S.Name,PPD.BranchID,PPD.IsActive
    ) AS T
    ORDER BY MasterID,Section
END
GO
PRINT 'Created or altered SP ProductBulkPrice_GetAll.';
GO

-- SP: ProductBulkPrice_Insert
CREATE OR ALTER PROCEDURE [restaurant].[ProductBulkPrice_Insert]
(
 @BranchID UNIQUEIDENTIFIER = NULL,
 @ProductPriceDetail_UDT restaurant.ProductPriceUDT READONLY,
 @SectionPriceDetail_UDT restaurant.SectionPriceUDT READONLY,
 @UpdatedUser UNIQUEIDENTIFIER = NULL
)
AS
BEGIN
    MERGE restaurant.ProductPriceDetail AS PD USING
    (SELECT MasterID,CategoryID,GroupID,BasePrice,Cost,IsVariableProduct,IsStockItem,IsDailyStockItem,IsActive FROM @ProductPriceDetail_UDT)
    PPD ON PD.BranchID = @BranchID AND PD.MasterID = PPD.MasterID
    WHEN MATCHED THEN UPDATE SET
        PD.CategoryID=PPD.CategoryID,PD.GroupID=PPD.GroupID,PD.BasePrice=PPD.BasePrice,PD.Cost=PPD.Cost,
        PD.IsVariableProduct=PPD.IsVariableProduct,PD.IsStockItem=PPD.IsStockItem,
        PD.IsDailyStockItem=PD.IsDailyStockItem,PD.IsActive=PD.IsActive;

    MERGE restaurant.ProductSectionPriceDetail AS PD USING
    (
        SELECT P.MasterID,P.SectionID,P.Price,ISNULL(T.[Percentage],0) AS Perc,U.IsActive
        FROM @SectionPriceDetail_UDT P
        INNER JOIN @ProductPriceDetail_UDT U ON U.MasterID = P.MasterID
        LEFT JOIN restaurant.ProductSectionPriceDetail PPD ON PPD.MasterID = P.MasterID AND PPD.SectionID = P.SectionID AND PPD.BranchID = @BranchID
        LEFT JOIN R_Tax T ON T.GuID = PPD.TaxId
    ) SPD ON PD.SectionID = SPD.SectionID AND PD.MasterID = SPD.MasterID AND PD.BranchID = @BranchID
    WHEN MATCHED THEN UPDATE SET
        PD.Price = CASE WHEN PD.IsTaxIncludedInPrice = 1 THEN SPD.Price/(100+Perc)*100 ELSE SPD.Price END,
        PD.IsActive = SPD.IsActive
    WHEN NOT MATCHED THEN INSERT (BranchID,MasterID,SectionID,Price,IsTaxIncludedInPrice,IsActive,Deleted,CreatedUser,CreatedDate,UpdatedUser,UpdatedDate)
    VALUES (@BranchID,SPD.MasterID,SPD.SectionID,SPD.Price,0,SPD.IsActive,0,@UpdatedUser,GETDATE(),@UpdatedUser,GETDATE());

    UPDATE P SET P.MenuItem = U.IsMenuItem FROM restaurant.Product AS P INNER JOIN @ProductPriceDetail_UDT AS U ON P.GuID = U.MasterID;
    UPDATE P SET P.IsActive = PPD.IsActive FROM restaurant.[ProductPriceDetail] AS P
        INNER JOIN @SectionPriceDetail_UDT U ON U.MasterID = P.MasterID AND P.BranchID = @BranchID
        INNER JOIN @ProductPriceDetail_UDT AS PPD ON P.MasterID = PPD.MasterID;
    UPDATE P SET P.IsActive = PPD.IsActive FROM restaurant.ProductLocationMapping AS P
        INNER JOIN @SectionPriceDetail_UDT U ON U.MasterID = P.ProductID AND P.BranchID = @BranchID
        INNER JOIN @ProductPriceDetail_UDT AS PPD ON P.ProductID = PPD.MasterID;
END
SET ANSI_NULLS ON
GO
PRINT 'Created or altered SP ProductBulkPrice_Insert.';
GO

-- SP: Sync_SalesLog_Insert (File 1 version — INSERT + NOT EXISTS guard)
CREATE OR ALTER PROCEDURE [restaurant].[Sync_SalesLog_Insert]
    @UDT_R_SalesLog [restaurant].Sync_SalesLog_UDT READONLY
AS
BEGIN
    SET NOCOUNT ON;
    ALTER TABLE R_SalesED DISABLE TRIGGER [Dltblk];
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO R_SalesED([GuID],MasterID,ProductID,Quantity,NewQuantity,BaseQuantity,UnitRate,TaxID,TaxPercentage,Tax,DiscPercentage,Discount,UnitID,Deleted,IsTaxIncludedInPrice,Cancelled,Merged,IsUD,IsDD,UDate,UUser,EditType,NewUnitRate,UUserGuid)
        SELECT U.[GuID],U.MasterID,U.ProductID,U.Quantity,U.NewQuantity,U.BaseQuantity,U.UnitRate,
            CASE WHEN U.TaxID = '00000000-0000-0000-0000-000000000000' THEN NULL ELSE U.TaxID END,
            U.TaxPercentage,U.Tax,U.DiscPercentage,U.Discount,U.UnitID,U.Deleted,U.IsTaxIncludedInPrice,U.Cancelled,U.Merged,
            U.IsUD,U.IsDD,U.UDate,U.UUser,U.EditType,U.NewUnitRate,U.UUserGuid
        FROM @UDT_R_SalesLog U
        WHERE NOT EXISTS (SELECT 1 FROM R_SalesED R WHERE R.GuID = U.GuID);
        COMMIT TRANSACTION;
        ALTER TABLE R_SalesED ENABLE TRIGGER [Dltblk];
        RETURN 1;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ALTER TABLE R_SalesED ENABLE TRIGGER [Dltblk];
        THROW;
    END CATCH
END
GO
PRINT 'Created or altered SP Sync_SalesLog_Insert.';
GO

-- SP: Sync_SalesTempLog_Insert
CREATE OR ALTER PROCEDURE [restaurant].[Sync_SalesTempLog_Insert]
    @UDT_R_SalesLog [restaurant].Sync_SalesLog_UDT READONLY
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        MERGE R_SalesTempED AS SD USING
        (
            SELECT [GuID],MasterID,ProductID,Quantity,NewQuantity,BaseQuantity,UnitRate,
                CASE WHEN TaxID = '00000000-0000-0000-0000-000000000000' THEN NULL ELSE TaxID END AS TaxID,
                TaxPercentage,Tax,DiscPercentage,Discount,UnitID,Deleted,IsTaxIncludedInPrice,Cancelled,Merged,
                IsUD,IsDD,UDate,UUser,EditType,NewUnitRate,UUserGuid
            FROM @UDT_R_SalesLog
        ) USD ON USD.[GuID] = SD.[GuID]
        WHEN MATCHED THEN UPDATE SET
            MasterID=USD.MasterID,ProductID=USD.ProductID,Quantity=USD.Quantity,NewQuantity=USD.NewQuantity,
            BaseQuantity=USD.BaseQuantity,UnitRate=USD.UnitRate,TaxID=USD.TaxID,TaxPercentage=USD.TaxPercentage,
            Tax=USD.Tax,DiscPercentage=USD.DiscPercentage,Discount=USD.Discount,UnitID=USD.UnitID,
            Deleted=USD.Deleted,IsTaxIncludedInPrice=USD.IsTaxIncludedInPrice,Cancelled=USD.Cancelled,
            Merged=USD.Merged,IsUD=USD.IsUD,IsDD=USD.IsDD,UDate=USD.UDate,UUser=USD.UUser,
            EditType=USD.EditType,NewUnitRate=USD.NewUnitRate,UUserGuid=USD.UUserGuid
        WHEN NOT MATCHED THEN INSERT
        ([GuID],MasterID,ProductID,Quantity,NewQuantity,BaseQuantity,UnitRate,TaxID,TaxPercentage,Tax,DiscPercentage,Discount,UnitID,Deleted,IsTaxIncludedInPrice,Cancelled,Merged,IsUD,IsDD,UDate,UUser,EditType,NewUnitRate,UUserGuid)
        VALUES(USD.[GuID],USD.MasterID,USD.ProductID,USD.Quantity,USD.NewQuantity,USD.BaseQuantity,USD.UnitRate,USD.TaxID,USD.TaxPercentage,USD.Tax,USD.DiscPercentage,USD.Discount,USD.UnitID,USD.Deleted,USD.IsTaxIncludedInPrice,USD.Cancelled,USD.Merged,USD.IsUD,USD.IsDD,USD.UDate,USD.UUser,USD.EditType,USD.NewUnitRate,USD.UUserGuid);
        COMMIT TRANSACTION;
        RETURN 1;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
PRINT 'Created or altered SP Sync_SalesTempLog_Insert.';
GO

-- SP: Sync_EinvoiceStatus_Insert (File 1 version — CREATE OR ALTER with MERGE)
CREATE OR ALTER PROCEDURE [restaurant].[Sync_EinvoiceStatus_Insert]
    @UDT_R_EinvoiceStatus [restaurant].[UDT_R_EinvoiceStatus] READONLY
AS
BEGIN
    SET NOCOUNT ON;
    MERGE dbo.R_EinvoiceStatus AS target
    USING @UDT_R_EinvoiceStatus AS source ON (target.GuID = source.GuID)
    WHEN MATCHED THEN UPDATE SET
        target.BillNo=source.BillNo,target.BillDateTime=source.BillDateTime,target.xmlFileName=source.xmlFileName,
        target.ResponseStatus=source.ResponseStatus,target.ResponseMsg=source.ResponseMsg,
        target.InvoiceType=source.InvoiceType,target.InvoiceHash=source.InvoiceHash,
        target.ReSubmitStatus=source.ReSubmitStatus,target.Version=source.Version
    WHEN NOT MATCHED THEN INSERT (GuID,BillNo,BillDateTime,xmlFileName,ResponseStatus,ResponseMsg,InvoiceType,InvoiceHash,ReSubmitStatus,Version)
    VALUES (source.GuID,source.BillNo,source.BillDateTime,source.xmlFileName,source.ResponseStatus,source.ResponseMsg,source.InvoiceType,source.InvoiceHash,source.ReSubmitStatus,source.Version);
END;
GO
PRINT 'Created or altered SP Sync_EinvoiceStatus_Insert.';
GO

-- SP: Sync_EinvoiceStatus_GetAll
CREATE OR ALTER PROCEDURE [restaurant].[Sync_EinvoiceStatus_GetAll]
    @Version BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT GuID,BillNo,BillDateTime,xmlFileName,ResponseStatus,ResponseMsg,InvoiceType,InvoiceHash,ReSubmitStatus,Version
    FROM dbo.R_EinvoiceStatus WHERE [Version] > @Version;
END;
GO
PRINT 'Created or altered SP Sync_EinvoiceStatus_GetAll.';
GO

-- SP: Sync_Section_Insert (File 2 version — critical fix with all new columns)
CREATE OR ALTER PROCEDURE [restaurant].[Sync_Section_Insert]
    @UDT_R_Section        [restaurant].[Sync_Section_UDT]         READONLY,
    @UDT_R_SectionSetting [restaurant].[Sync_Section_Setting_UDT] READONLY,
    @UDT_R_Table          [restaurant].[Sync_Table_UDT]           READONLY
AS
BEGIN TRY
    BEGIN TRANSACTION
        -- Step 1: Insert/update basic section identity
        MERGE R_Section AS S USING (
            SELECT [Guid],Name,ShortName,Deleted,ZoneGuid FROM @UDT_R_Section
        )US ON US.[Guid] = S.[GuID]
        WHEN MATCHED THEN UPDATE SET
            S.Name=US.Name,S.ShortName=US.ShortName,S.Deleted=US.Deleted,S.ZoneGuid=US.ZoneGuid
        WHEN NOT MATCHED THEN
            INSERT ([Guid],Name,ShortName,Deleted,ZoneGuid,StartNo,IsTableEnable,IsWaiterEnable,IsCustomerEnable,IsDeliveryInvoicePrint,IsKOTPrint,IsKOTinReceiptPrinter,IsSalesPrintOnSave,NoOfPrints,IsKOTPayPrint,isChairEnabled,IsPaxEnabled)
            VALUES (US.[Guid],US.Name,US.ShortName,US.Deleted,US.ZoneGuid,1,1,1,1,0,1,0,1,1,0,0,0);

        -- Step 2: Update print settings from section settings UDT
        UPDATE rs SET
            rs.IsKOTPrint=uss.EnableKOTPrinting,rs.IsDeliveryInvoicePrint=uss.PrintKOTInSalesBillFormat,
            rs.IsKOTinReceiptPrinter=uss.PrintKOTInSalesBillPrinter,rs.IsSalesPrintOnSave=uss.PrintBothSalesAndKOTPrint,
            rs.IsTableEnable=uss.ShowPopupToSelectTable,rs.IsWaiterEnable=uss.ShowPopupToSelectWaiter,
            rs.IsCustomerEnable=uss.ShowPopupToCaptureCustomerDetail,rs.NoOfPrints=uss.NumberOfInvoicePrints,
            rs.StartNo=uss.BillStartNumber,rs.IsMultiOrderEnabled=uss.IsMultiOrderEnabled,
            rs.InvoicePrinterID=TRY_CAST(uss.InvoicePrinterID AS UNIQUEIDENTIFIER),
            rs.IsPaxEnabled=uss.IsPaxEnabled,rs.isChairEnabled=uss.isChairEnabled,
            rs.IsCashButtonPrint=uss.IsCashButtonPrint,rs.IsPayScreenPrintOnSettle=uss.IsPayScreenPrintOnSettle,
            rs.IsKitchenManagerPrintEnabled=uss.IsKitchenManagerPrintEnabled,
            rs.KitchenManagerPrinterID=uss.KitchenManagerPrinterID
        FROM dbo.R_Section rs INNER JOIN @UDT_R_SectionSetting uss ON rs.GuID=uss.SectionGuID;
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; THROW;
END CATCH;
GO
PRINT 'Created or altered SP Sync_Section_Insert.';
GO

-- SP: Sync_Category_Insert (File 2 version — only in File 2)
CREATE OR ALTER PROCEDURE [restaurant].[Sync_Category_Insert]
    @UDT_R_Category [restaurant].[Sync_Category_UDT] READONLY
AS
BEGIN TRY
    BEGIN TRANSACTION
        MERGE R_Category AS C USING
        (SELECT [GuID],Name,ShortName,Deleted,Course,CreatedUser,CreatedDate,UpdatedUser,UpdatedDate,CategoryMasterGuID FROM @UDT_R_Category)
        UC ON UC.[GuID] = C.[GuID]
        WHEN MATCHED THEN UPDATE SET
            C.[GuID]=UC.[GuID],C.Name=UC.Name,C.ShortName=UC.ShortName,C.Deleted=UC.Deleted,C.Course=UC.Course,
            C.CreatedUser=UC.CreatedUser,C.CreatedDate=UC.CreatedDate,C.UpdatedUser=UC.UpdatedUser,
            C.UpdatedDate=UC.UpdatedDate,C.CategoryMasterGuID=UC.CategoryMasterGuID
        WHEN NOT MATCHED THEN INSERT ([GuID],Name,ShortName,Deleted,Course,CreatedUser,CreatedDate,UpdatedUser,UpdatedDate,CategoryMasterGuID)
        VALUES (UC.[GuID],UC.Name,UC.ShortName,UC.Deleted,UC.Course,UC.CreatedUser,UC.CreatedDate,UC.UpdatedUser,UC.UpdatedDate,UC.CategoryMasterGuID);
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
PRINT 'Created or altered SP Sync_Category_Insert.';
GO

-- SP: product_insert (only in File 2 — converted to CREATE OR ALTER)
CREATE OR ALTER PROCEDURE [restaurant].[product_insert]
(
    @Guid UNIQUEIDENTIFIER,
    @Name VARCHAR(50),
    @ShortName VARCHAR(50),
    @Barcode VARCHAR(13),
    @RefCode VARCHAR(20),
    @TypeID UNIQUEIDENTIFIER,
    @UnitID UNIQUEIDENTIFIER,
    @CategoryID UNIQUEIDENTIFIER,
    @BranchID UNIQUEIDENTIFIER,
    @Image VARCHAR(150),
    @IsVariableProduct BIT,
    @ArabicDescription NVARCHAR(50),
    @IsStockItem BIT,
    @ERPProductID UNIQUEIDENTIFIER,
    @GroupID UNIQUEIDENTIFIER,
    @ColorID VARCHAR(50),
    @VegTypeNo INT,
    @OtherDescription NVARCHAR(100),
    @Loyalty DECIMAL(18, 2),
    @Cost MONEY,
    @CessPercentage INT,
    @SCategoryID UNIQUEIDENTIFIER,
    @IsActive BIT,
    @IsDailyStockItem BIT,
    @BasePrice MONEY,
    @UpdatedUser UNIQUEIDENTIFIER,
    @ProductDetail Restaurant.ProductDetail READONLY,
    @ProductComboDetail Restaurant.ComboProductDetail READONLY,
    @HSNCode NVARCHAR(200) = null,
    @IsMenuItem BIT,
    @ProductModifierDetail Restaurant.ProductModifierDetail READONLY,
    @Calories int
)
AS
DECLARE @MasterGuid UNIQUEIDENTIFIER
BEGIN
    IF @Guid IS NULL
    BEGIN
        IF NOT EXISTS(SELECT * FROM [restaurant].[Product] WHERE (Barcode=@Barcode OR [Name]=@Name OR ShortName=@ShortName OR RefCode=@RefCode) AND Deleted = 0)
        BEGIN
            SET @MasterGuid = NEWID()
            INSERT INTO [restaurant].[Product]([GuID],[Name],[ShortName],[Barcode],[RefCode],[UnitID],[Image],[ArabicDescription],[ERPProductID],[ColorID],[VegTypeNo],[OtherDescription],[CessPercentage],[SCategoryID],[Deleted],[CreatedUser],[CreatedDate],[UpdatedUser],[UpdatedDate],HSNCode,MenuItem,Calories)
            VALUES(@MasterGuid,@Name,@ShortName,@Barcode,@RefCode,@UnitID,@Image,@ArabicDescription,@ERPProductID,@ColorID,@VegTypeNo,@OtherDescription,@CessPercentage,@SCategoryID,0,@UpdatedUser,GETDATE(),@UpdatedUser,GETDATE(),@HSNCode,@IsMenuItem,@Calories);
            INSERT INTO [restaurant].[ProductPriceDetail]([MasterID],[CategoryID],[GroupID],[TypeID],[IsStockItem],[IsVariableProduct],[Cost],[IsDailyStockItem],[BasePrice],[Loyalty],[BranchID],[CreatedUser],[CreatedDate],[UpdatedUser],[UpdatedDate],[IsActive])
            VALUES(@MasterGuid,@CategoryID,@GroupId,@TypeID,@IsStockItem,@IsVariableProduct,@Cost,@IsDailyStockItem,@BasePrice,@Loyalty,@BranchID,@UpdatedUser,GETDATE(),@UpdatedUser,GETDATE(),@IsActive);
            INSERT INTO restaurant.ProductSectionPriceDetail(MasterID,SectionID,Price,IsTaxIncludedInPrice,TaxID,DiscountID,IsActive,Deleted,BranchID,[CreatedUser],[CreatedDate],[UpdatedUser],[UpdatedDate],[ZoneGuid])
            SELECT @MasterGuid,SectionID,CASE WHEN P.IsTaxIncludedInPrice = 1 THEN Price/(100+(Percentage))*100 ELSE Price END AS Price,IsTaxIncludedInPrice,TaxID,DiscountID,IsActive,0,@BranchID,@UpdatedUser,GETDATE(),@UpdatedUser,GETDATE(),ZoneGuid
            FROM @ProductDetail P LEFT OUTER JOIN R_Tax tx ON tx.GuID = P.TaxId;
            INSERT INTO restaurant.ProductComboDetail(MasterProductId,ProductID,Quantity,TypeID,Deleted,BranchID,[CreatedUser],[CreatedDate],[UpdatedUser],[UpdatedDate])
            SELECT @MasterGuid,ProductID,Quantity,TypeId,0,@BranchID,@UpdatedUser,GETDATE(),@UpdatedUser,GETDATE() FROM @ProductComboDetail;
            INSERT INTO restaurant.ProductLocationMapping(ProductID,BranchID,IsActive,[CreatedUser],[CreatedDate],[UpdatedUser],[UpdatedDate])
            VALUES(@MasterGuid,@BranchID,1,@UpdatedUser,GETDATE(),@UpdatedUser,GETDATE());
            INSERT INTO dbo.R_ProductModifiers(ProductID,ModifierID,ExtraCharge,IsDefault,CreatedDate)
            SELECT @MasterGuid,ModifierID,ExtraCharge,IsDefault,GETDATE() FROM @ProductModifierDetail;
        END
        ELSE
        BEGIN
            IF EXISTS(SELECT * FROM [restaurant].[Product] WHERE (Name=@Name) AND Deleted=0) THROW 51000,'A product with same Name already exists...',1;
            IF EXISTS(SELECT * FROM [restaurant].[Product] WHERE (ShortName=@ShortName) AND Deleted=0) THROW 51000,'A product with same ShortName already exists...',1;
            IF EXISTS(SELECT * FROM [restaurant].[Product] WHERE (RefCode=@RefCode) AND Deleted=0) THROW 51000,'A product with same Code already exists...',1;
            IF EXISTS(SELECT * FROM [restaurant].[Product] WHERE (Barcode=@Barcode) AND Deleted=0) THROW 51000,'A product with same Barcode already exists...',1;
        END
    END
    ELSE
    BEGIN
        IF NOT EXISTS(SELECT * FROM [restaurant].[Product] WHERE (Barcode=@Barcode OR Name=@Name OR ShortName=@ShortName OR RefCode=@RefCode) AND Deleted=0 AND [GuID] != @Guid)
        BEGIN
            SET @MasterGuid = @Guid
            UPDATE [restaurant].[Product] SET [Name]=@Name,ShortName=@ShortName,RefCode=@RefCode,Barcode=@Barcode,UnitID=@UnitID,[Image]=@Image,ArabicDescription=@ArabicDescription,ERPProductID=@ERPProductID,ColorID=@ColorID,VegTypeNo=@VegTypeNo,OtherDescription=@OtherDescription,CessPercentage=@CessPercentage,SCategoryID=@SCategoryID,UpdatedUser=@UpdatedUser,UpdatedDate=GETDATE(),HSNCode=@HSNCode,MenuItem=@IsMenuItem,Calories=@Calories WHERE [GuID]=@Guid;
            UPDATE [restaurant].[ProductPriceDetail] SET CategoryID=@CategoryID,TypeID=@TypeID,IsVariableProduct=@IsVariableProduct,IsStockItem=@IsStockItem,GroupId=@GroupId,Loyalty=@Loyalty,Cost=@Cost,IsActive=@IsActive,IsDailyStockItem=@IsDailyStockItem,BasePrice=@BasePrice,UpdatedUser=@UpdatedUser,UpdatedDate=GETDATE() WHERE MasterID=@MasterGuid AND BranchID=@BranchID;
            UPDATE restaurant.ProductSectionPriceDetail SET Deleted=1 WHERE MasterID=@MasterGuid AND BranchID=@BranchID;
            MERGE restaurant.ProductSectionPriceDetail AS PD USING
            (SELECT [SectionID],CASE WHEN PS.IsTaxIncludedInPrice = 1 THEN Price/(100+(Percentage))*100 ELSE Price END AS Price,[TaxID],[IsTaxIncludedInPrice],[DiscountID],[IsActive],PS.ZoneGuid FROM @ProductDetail PS LEFT OUTER JOIN R_Tax tx ON tx.GuID = PS.[TaxID])
            PDS ON PDS.[SectionID]=PD.[SectionID] AND PD.MasterID=@MasterGuid AND PD.BranchID=@BranchID
            WHEN MATCHED THEN UPDATE SET PD.[Price]=PDS.[Price],PD.[TaxID]=PDS.[TaxID],PD.[IsTaxIncludedInPrice]=PDS.[IsTaxIncludedInPrice],PD.[DiscountID]=PDS.[DiscountID],PD.[IsActive]=PDS.[IsActive],PD.Deleted=0,BranchID=@BranchID,PD.UpdatedUser=@UpdatedUser,PD.UpdatedDate=GETDATE(),PD.ZoneGUID=PDS.ZoneGuid
            WHEN NOT MATCHED THEN INSERT ([MasterID],[SectionID],[Price],[TaxID],[IsTaxIncludedInPrice],[DiscountID],[IsActive],Deleted,BranchID,[CreatedUser],[CreatedDate],[UpdatedUser],[UpdatedDate],[ZoneGuid]) VALUES (@MasterGuid,PDS.[SectionID],PDS.[Price],PDS.[TaxID],PDS.[IsTaxIncludedInPrice],PDS.[DiscountID],PDS.[IsActive],0,@BranchID,@UpdatedUser,GETDATE(),@UpdatedUser,GETDATE(),ZoneGUID);
            UPDATE restaurant.ProductComboDetail SET Deleted=1 WHERE MasterProductID=@MasterGuid AND BranchID=@BranchID;
            MERGE restaurant.ProductComboDetail AS CP USING
            (SELECT MasterProductId,ProductId,Quantity,TypeId FROM @ProductComboDetail)
            CPS ON CP.MasterProductID=CPS.MasterProductId AND CP.ProductId=CPS.ProductId AND CP.BranchID=@BranchID
            WHEN MATCHED THEN UPDATE SET CP.ProductId=CPS.ProductId,CP.Quantity=CPS.Quantity,CP.TypeId=CPS.TypeId,CP.Deleted=0,CP.UpdatedUser=@UpdatedUser,CP.UpdatedDate=GETDATE()
            WHEN NOT MATCHED THEN INSERT (MasterProductID,ProductId,Quantity,TypeId,BranchID,[CreatedUser],[CreatedDate],[UpdatedUser],[UpdatedDate]) VALUES (CPS.MasterProductID,CPS.ProductId,CPS.Quantity,CPS.TypeId,@BranchID,@UpdatedUser,GETDATE(),@UpdatedUser,GETDATE());
            UPDATE restaurant.ProductLocationMapping SET UpdatedUser=@UpdatedUser,UpdatedDate=GETDATE() WHERE BranchID=@BranchID AND ProductID=@MasterGuid;
            DELETE FROM dbo.R_ProductModifiers WHERE ProductID=@MasterGuid;
            INSERT INTO dbo.R_ProductModifiers(ProductID,ModifierID,ExtraCharge,IsDefault,CreatedDate) SELECT @MasterGuid,ModifierID,ExtraCharge,IsDefault,GETDATE() FROM @ProductModifierDetail;
        END
        ELSE
        BEGIN
            IF EXISTS(SELECT * FROM [restaurant].[Product] WHERE (Name=@Name) AND Deleted=0) THROW 51000,'A product with same Name already exists...',1;
            IF EXISTS(SELECT * FROM [restaurant].[Product] WHERE (ShortName=@ShortName) AND Deleted=0) THROW 51000,'A product with same ShortName already exists...',1;
            IF EXISTS(SELECT * FROM [restaurant].[Product] WHERE (RefCode=@RefCode) AND Deleted=0) THROW 51000,'A product with same Code already exists...',1;
            IF EXISTS(SELECT * FROM [restaurant].[Product] WHERE (Barcode=@Barcode) AND Deleted=0) THROW 51000,'A product with same Barcode already exists...',1;
        END
    END
END;
GO
PRINT 'Created or altered SP product_insert.';
GO

-- SP: ProductImport_Insert
CREATE OR ALTER PROCEDURE [restaurant].[ProductImport_Insert]
    @UDT_R_ProductImport              [restaurant].[ProductImport_UDT]                   READONLY,
    @UDT_SectionWiseProductImportDetail [restaurant].[SectionWiseProductImportDetail_UDT] READONLY,
    @BranchID UNIQUEIDENTIFIER = NULL,
    @UpdatedUser UNIQUEIDENTIFIER = NULL
AS
BEGIN TRY
    BEGIN TRANSACTION
        MERGE restaurant.Product AS P USING
        (SELECT UPD.[GuID],UPD.[Name],UPD.[ShortName],Code,Barcode,U.[GuID] UnitID,ArabicDescription,OtherDescription
         FROM @UDT_R_ProductImport UPD INNER JOIN R_Unit U ON U.[Name]=UPD.[UnitName])
        UP ON UP.[GuID]=P.[GuID]
        WHEN MATCHED THEN UPDATE SET P.[GuID]=UP.[GuID],P.[Name]=UP.[Name],P.[ShortName]=UP.[ShortName],P.RefCode=UP.Code,P.Barcode=UP.Barcode,P.UnitID=UP.UnitID,P.ArabicDescription=UP.ArabicDescription,P.OtherDescription=UP.OtherDescription,P.Image='',P.ColorID='',P.VegTypeNo=0,UpdatedUser=@UpdatedUser,UpdatedDate=GETDATE(),Calories=0
        WHEN NOT MATCHED THEN INSERT ([GuID],[Name],[ShortName],RefCode,Barcode,UnitID,ArabicDescription,OtherDescription,Image,ColorID,VegTypeNo,CreatedUser,CreatedDate,UpdatedUser,UpdatedDate,Calories)
        VALUES(UP.[GuID],UP.[Name],UP.[ShortName],UP.Code,UP.Barcode,UP.UnitID,UP.ArabicDescription,OtherDescription,'','',0,@UpdatedUser,GETDATE(),@UpdatedUser,GETDATE(),0);

        INSERT INTO restaurant.ProductLocationMapping(ProductID,BranchID,IsActive,[CreatedUser],[CreatedDate],[UpdatedUser],[UpdatedDate])
        SELECT [GuID],@BranchID,1,@UpdatedUser,GETDATE(),@UpdatedUser,GETDATE() FROM @UDT_R_ProductImport;

        MERGE restaurant.ProductPriceDetail AS P USING
        (SELECT UPD.[GuID],T.[GuID] TypeID,C.[GuID] CategoryID,G.[GuID] GroupID,Cost,BasePrice,IsActive
         FROM @UDT_R_ProductImport UPD INNER JOIN R_Type T ON T.[Name]=UPD.[TypeName] INNER JOIN R_Unit U ON U.[Name]=UPD.[UnitName] INNER JOIN R_Category C ON C.[Name]=UPD.[CategoryName] INNER JOIN R_GroupEntry G ON G.[Name]=UPD.[GroupName])
        UP ON UP.[GuID]=P.MasterID AND P.BranchID=@BranchID
        WHEN MATCHED THEN UPDATE SET P.[MasterID]=UP.[GuID],P.TypeID=UP.TypeID,P.CategoryID=UP.CategoryID,P.IsVariableProduct=0,P.GroupID=UP.GroupID,P.Cost=UP.Cost,P.BasePrice=UP.BasePrice,P.IsActive=UP.IsActive,P.IsStockItem=0,P.Loyalty=0,UpdatedUser=@UpdatedUser,UpdatedDate=GETDATE()
        WHEN NOT MATCHED THEN INSERT ([MasterID],TypeID,CategoryID,IsVariableProduct,GroupID,Cost,BasePrice,IsActive,IsStockItem,Loyalty,BranchID,CreatedUser,CreatedDate,UpdatedUser,UpdatedDate) VALUES(UP.[GuID],UP.TypeID,UP.CategoryID,0,UP.GroupID,UP.Cost,BasePrice,UP.IsActive,0,0.00,@BranchID,@UpdatedUser,GETDATE(),@UpdatedUser,GETDATE());

        MERGE restaurant.ProductSectionPriceDetail AS PD USING
        (SELECT [MasterID],[SectionName],[Price],[IsActive] FROM @UDT_SectionWiseProductImportDetail)
        USPD ON USPD.[MasterID]=PD.[MasterID] AND PD.BranchID=@BranchID
        WHEN MATCHED THEN DELETE;

        INSERT INTO restaurant.ProductSectionPriceDetail([MasterID],[SectionID],[Price],[IsTaxIncludedInPrice],[IsActive],BranchID,CreatedUser,CreatedDate,UpdatedUser,UpdatedDate,ZoneGuID)
        SELECT UST.[MasterID],S.[GuID],UST.[Price],0,UST.[IsActive],@BranchID,@UpdatedUser,GETDATE(),@UpdatedUser,GETDATE(),(SELECT ZoneGuID FROM restaurant.Section WHERE GuID=S.[GuID]) AS ZoneGuID
        FROM @UDT_SectionWiseProductImportDetail UST LEFT JOIN restaurant.Section S ON UST.SectionName=S.[Name];
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    RETURN -1;
END CATCH;
RETURN 1;
GO
PRINT 'Created or altered SP ProductImport_Insert.';
GO

-- SP: Sync_Product_GetAll
CREATE OR ALTER PROCEDURE [restaurant].[Sync_Product_GetAll]
(
    @Version BIGINT = NULL,
    @BranchID UNIQUEIDENTIFIER = NULL
)
AS
    SET NOCOUNT ON
    SELECT ISNULL(PLM.IsActive,0) AS IsActive,P.ID,P.[GUID],[Name],ShortName,RefCode,Barcode,CategoryID,UnitID,TypeID,[Image],IsVariableProduct,ISNULL(ArabicDescription,'')ArabicDescription,IsStockItem,ERPProductID,GroupId,ColorID,VegTypeNo,OtherDescription,Loyalty,Cost,CessPercentage,SCategoryID,CONVERT(BIGINT,PLM.[Version])[Version],CASE WHEN PLM.IsActive = 0 THEN 1 ELSE P.Deleted END AS Deleted,IsDailyStockItem,BasePrice,PLM.IsActive AS LocationIsActive,PLM.CreatedUser,PLM.CreatedDate,PLM.UpdatedUser,PLM.UpdatedDate,ISNULL(P.MenuItem,0)MenuItem,P.HSNCode,ISNULL(P.ProductionQuantity,0)ProductionQuantity,P.Calories,P.ImgDescription
    FROM restaurant.ProductLocationMapping PLM
    INNER JOIN [restaurant].[Product] P ON PLM.ProductID=P.[GuID]
    INNER JOIN [restaurant].[ProductPriceDetail] PPD ON PPD.MasterID=P.[GuID] AND PPD.BranchID=@BranchID AND PPD.Deleted=0
    WHERE (PLM.BranchID=@BranchID) AND PLM.[Version]>@Version

    SELECT P.ID,P.GuID,P.MasterID,P.SectionID,CASE WHEN P.IsTaxIncludedInPrice = 1 THEN ISNULL(P.Price+(P.Price*(T.[Percentage])/100),0) ELSE ISNULL(P.Price,0) END AS Price,T.[Percentage] AS TaxPercentage,P.IsTaxIncludedInPrice,S.[Name] Section,T.[Name] Tax,P.TaxID,P.DiscountID,D.[Name] Discount,D.[Percentage] DiscPercentage,P.IsActive,P.Deleted,P.CreatedUser,P.CreatedDate,P.UpdatedUser,P.UpdatedDate,P.ZoneGuid
    FROM restaurant.ProductSectionPriceDetail P
    LEFT OUTER JOIN restaurant.Section S ON S.[GuID]=P.SectionID
    LEFT OUTER JOIN R_Tax T ON T.[GuID]=P.TaxID AND P.TaxID IS NOT NULL
    LEFT OUTER JOIN R_Discount D ON D.[GuID]=P.DiscountID AND P.DiscountID IS NOT NULL
    WHERE (P.BranchID=@BranchID) AND P.Deleted=0

    SELECT CP.ID,CP.MasterProductID,CP.ProductID,CP.Quantity,CP.TypeID,P.[Name],P.Deleted
    FROM restaurant.ProductComboDetail CP INNER JOIN restaurant.Product P ON CP.productid=P.[GuID]
    WHERE (CP.BranchID=@BranchID)

    SELECT pm.ProductID AS MasterProductID,pm.ModifierID AS Guid,m.Name,ISNULL(pm.ExtraCharge,m.Rate) AS ExtraCharge,pm.IsDefault,m.Deleted
    FROM restaurant.ProductLocationMapping PLM
    INNER JOIN restaurant.Product P ON PLM.ProductID=P.GuID
    INNER JOIN dbo.R_ProductModifiers pm ON pm.ProductID=P.GuID
    INNER JOIN dbo.R_Modifiers m ON pm.ModifierID=m.GUID
    WHERE PLM.BranchID=@BranchID AND m.Deleted=0

    SELECT * FROM R_ProductImage;
    SET NOCOUNT OFF
GO
PRINT 'Created or altered SP Sync_Product_GetAll.';
GO

-- SP: Product_GetAllByBranch
CREATE OR ALTER PROCEDURE [restaurant].[Product_GetAllByBranch]
(
 @BranchID VARCHAR(500) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ISNULL(PPD.IsActive,0) AS IsActive,P.ID,P.[GUID],P.[Name],P.ShortName,RefCode,Barcode,CategoryID,CT.Name As CategoryName,UnitID,TypeID,TP.[Name] as TypeName,[Image],IsVariableProduct,ISNULL(ArabicDescription,'')ArabicDescription,IsStockItem,ERPProductID,GroupId,ColorID,VegTypeNo,OtherDescription,Loyalty,Cost,CessPercentage,SCategoryID,CONVERT(BIGINT,P.[Version])Version,P.Deleted,IsDailyStockItem,BasePrice,PLM.IsActive AS LocationIsActive,ISNULL(MenuItem,0)MenuItem,HSNCode,DepartmentID,P.Calories
    FROM restaurant.ProductLocationMapping PLM
    INNER JOIN [restaurant].[Product] P ON PLM.ProductID=P.[GuID]
    LEFT OUTER JOIN [restaurant].[ProductPriceDetail] PPD ON PPD.MasterID=P.[GuID] AND PPD.BranchID=@BranchID AND PPD.Deleted=0
    LEFT OUTER JOIN [dbo].[R_Type] TP ON TP.GUID=PPD.[TypeID]
    LEFT OUTER JOIN [dbo].[R_Category] CT ON PPD.CategoryID=CT.[GUID]
    WHERE (PLM.BranchID=@BranchID) ORDER BY P.[Name]

    SELECT P.ID,P.GuID,P.MasterID,P.SectionID,CASE WHEN P.IsTaxIncludedInPrice = 1 THEN ROUND(P.Price+(P.Price*(T.[Percentage])/100),4) ELSE P.Price END AS Price,T.[Percentage] AS TaxPercentage,P.IsTaxIncludedInPrice,S.[Name] Section,T.[Name] Tax,P.TaxID,P.DiscountID,D.[Name] Discount,D.[Percentage] DiscPercentage,P.IsActive,P.ZoneGuid
    FROM restaurant.ProductSectionPriceDetail P
    INNER JOIN restaurant.Section S ON S.[GuID]=P.SectionID AND S.Deleted=0
    INNER JOIN restaurant.SectionLocationMapping SLM ON SLM.SectionID=S.[GuID] AND SLM.BranchID=@BranchID AND S.Deleted=0
    LEFT JOIN R_Tax T ON T.[GuID]=P.TaxID AND P.TaxID IS NOT NULL
    LEFT JOIN R_Discount D ON D.[GuID]=P.DiscountID AND P.DiscountID IS NOT NULL
    WHERE (P.BranchID=@BranchID) AND P.Deleted=0 ORDER BY S.[Name]

    SELECT CP.ID,CP.MasterProductID,CP.ProductID,CP.Quantity,CP.TypeID,P.[Name]
    FROM restaurant.ProductComboDetail CP LEFT JOIN restaurant.Product P ON CP.productid=P.[GuID]
    WHERE (CP.BranchID=@BranchID) AND CP.Deleted=0

    SELECT ProductGuID,ImageURL,ThumbnailURL,IsPrimary,P.imgDescription
    FROM dbo.R_ProductImage Inner Join restaurant.Product P ON R_ProductImage.ProductGuID=P.GuID
    WHERE ProductGuID IN (SELECT P.GuID FROM restaurant.ProductLocationMapping PLM INNER JOIN restaurant.Product P ON PLM.ProductID=P.[GuID] WHERE PLM.BranchID=@BranchID);
END
GO
PRINT 'Created or altered SP Product_GetAllByBranch.';
GO

-- SP: Sync_SalesLog_GetAll
CREATE OR ALTER PROCEDURE [restaurant].[Sync_SalesLog_GetAll]
    @SaleVersion BIGINT = NULL,
    @SaleTempVersion BIGINT = NULL
AS
    SET NOCOUNT ON
    SELECT [GuID],MasterID,ProductID,Quantity,NewQuantity,BaseQuantity,UnitRate,ISNULL(TaxID,'00000000-0000-0000-0000-000000000000')TaxID,TaxPercentage,Tax,DiscPercentage,Discount,UnitID,ItemTypeID,Deleted,IsTaxIncludedInPrice,Cancelled,Merged,IsVoid,IsUD,IsDD,UDate,UUser,Convert(Bigint,[Version])[Version],EditType,ISNULL(NewUnitRate,0)NewUnitRate,UUserGuid
    FROM R_SalesED WHERE [Version]>@SaleVersion
    SELECT [GuID],MasterID,ProductID,Quantity,NewQuantity,BaseQuantity,UnitRate,ISNULL(TaxID,'00000000-0000-0000-0000-000000000000')TaxID,TaxPercentage,Tax,DiscPercentage,Discount,UnitID,ItemTypeID,Deleted,IsTaxIncludedInPrice,Cancelled,Merged,IsVoid,IsUD,IsDD,UDate,UUser,Convert(Bigint,[Version])[Version],EditType,ISNULL(NewUnitRate,0)NewUnitRate,UUserGuid
    FROM R_SalesTempED WHERE [Version]>@SaleTempVersion
    SET NOCOUNT OFF
GO
PRINT 'Created or altered SP Sync_SalesLog_GetAll.';
GO

-- SP: SP_InvoicePrintSetup_Insert (File 1 version — CREATE OR ALTER)
CREATE OR ALTER PROCEDURE [dbo].[SP_InvoicePrintSetup_Insert]
(
    @CompanyID UNIQUEIDENTIFIER,
    @TemplateName VARCHAR(100),
    @CompanyName VARCHAR(200),
    @Address1 VARCHAR(200),
    @Address2 VARCHAR(200),
    @Phone VARCHAR(50),
    @Email VARCHAR(100),
    @GSTNo VARCHAR(50),
    @Logo VARBINARY(MAX),
    @PaperSize VARCHAR(20),
    @FontName VARCHAR(50),
    @FontSize INT,
    @IsBold BIT,
    @Alignment VARCHAR(10),
    @FooterText VARCHAR(500),
    @ShowThankYou BIT,
    @ShowQRCode BIT
)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO InvoicePrintSetup(CompanyID,TemplateName,CompanyName,Address1,Address2,Phone,Email,GSTNo,Logo,PaperSize,FontName,FontSize,IsBold,Alignment,FooterText,ShowThankYou,ShowQRCode)
    VALUES(@CompanyID,@TemplateName,@CompanyName,@Address1,@Address2,@Phone,@Email,@GSTNo,@Logo,@PaperSize,@FontName,@FontSize,@IsBold,@Alignment,@FooterText,@ShowThankYou,@ShowQRCode);
    SELECT SCOPE_IDENTITY() AS InsertedID;
END;
GO
PRINT 'Created or altered SP SP_InvoicePrintSetup_Insert.';
GO

-- SP: SP_InvoicePrintSetup_Update (File 1 version — CREATE OR ALTER)
CREATE OR ALTER PROCEDURE [dbo].[SP_InvoicePrintSetup_Update]
(
    @ID INT,
    @CompanyID UNIQUEIDENTIFIER,
    @TemplateName VARCHAR(100),
    @CompanyName VARCHAR(200),
    @Address1 VARCHAR(200),
    @Address2 VARCHAR(200),
    @Phone VARCHAR(50),
    @Email VARCHAR(100),
    @GSTNo VARCHAR(50),
    @Logo VARBINARY(MAX),
    @PaperSize VARCHAR(20),
    @FontName VARCHAR(50),
    @FontSize INT,
    @IsBold BIT,
    @Alignment VARCHAR(10),
    @FooterText VARCHAR(500),
    @ShowThankYou BIT,
    @ShowQRCode BIT
)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE InvoicePrintSetup SET CompanyID=@CompanyID,TemplateName=@TemplateName,CompanyName=@CompanyName,Address1=@Address1,Address2=@Address2,Phone=@Phone,Email=@Email,GSTNo=@GSTNo,Logo=@Logo,PaperSize=@PaperSize,FontName=@FontName,FontSize=@FontSize,IsBold=@IsBold,Alignment=@Alignment,FooterText=@FooterText,ShowThankYou=@ShowThankYou,ShowQRCode=@ShowQRCode WHERE ID=@ID;
    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO
PRINT 'Created or altered SP SP_InvoicePrintSetup_Update.';
GO

-- SP: SP_InvoicePrintSetup_GetAll
CREATE OR ALTER PROCEDURE [dbo].[SP_InvoicePrintSetup_GetAll]
(
    @CompanyID UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM InvoicePrintSetup WHERE CompanyID=@CompanyID ORDER BY CreatedOn DESC;
END;
GO
PRINT 'Created or altered SP SP_InvoicePrintSetup_GetAll.';
GO

-- SP: SP_InvoicePrintSetup_Save (only in File 2 — converted to CREATE OR ALTER)
CREATE OR ALTER PROCEDURE [dbo].[SP_InvoicePrintSetup_Save]
(
    @CompanyID UNIQUEIDENTIFIER,
    @TemplateName VARCHAR(100),
    @CompanyName NVARCHAR(200),
    @OtherLanguage NVARCHAR(200),
    @Header1 VARCHAR(200),
    @Header2 VARCHAR(200),
    @Header3 VARCHAR(200),
    @Header4 VARCHAR(200),
    @Header5 VARCHAR(200),
    @Logo VARBINARY(MAX),
    @PaperSize VARCHAR(20),
    @FontName VARCHAR(50),
    @FontSize INT,
    @IsBold BIT,
    @Alignment VARCHAR(10),
    @FooterText1 VARCHAR(500),
    @FooterText2 VARCHAR(500),
    @ShowThankYou BIT,
    @ShowQRCode BIT
)
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM InvoicePrintSetup WHERE CompanyID=@CompanyID)
    BEGIN
        UPDATE InvoicePrintSetup SET TemplateName=@TemplateName,CompanyName=@CompanyName,OtherLanguage=@OtherLanguage,Header1=@Header1,Header2=@Header2,Header3=@Header3,Header4=@Header4,Header5=@Header5,Logo=@Logo,PaperSize=@PaperSize,FontName=@FontName,FontSize=@FontSize,IsBold=@IsBold,Alignment=@Alignment,FooterText1=@FooterText1,FooterText2=@FooterText2,ShowThankYou=@ShowThankYou,ShowQRCode=@ShowQRCode WHERE CompanyID=@CompanyID;
    END
    ELSE
    BEGIN
        INSERT INTO InvoicePrintSetup(CompanyID,TemplateName,CompanyName,OtherLanguage,Header1,Header2,Header3,Header4,Header5,Logo,PaperSize,FontName,FontSize,IsBold,Alignment,FooterText1,FooterText2,ShowThankYou,ShowQRCode)
        VALUES(@CompanyID,@TemplateName,@CompanyName,@OtherLanguage,@Header1,@Header2,@Header3,@Header4,@Header5,@Logo,@PaperSize,@FontName,@FontSize,@IsBold,@Alignment,@FooterText1,@FooterText2,@ShowThankYou,@ShowQRCode);
    END
    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO
PRINT 'Created or altered SP SP_InvoicePrintSetup_Save.';
GO

-- SP: Report_EinvoiceStatusPaging (File 1 version — CREATE OR ALTER)
CREATE OR ALTER PROCEDURE [restaurant].[Report_EinvoiceStatusPaging]
    @BranchID VARCHAR(50)=NULL,
    @FromDate DATETIME,
    @ToDate DATETIME,
    @PageNumber INT=1,
    @PageSize INT=10,
    @SortingColumn VARCHAR(50)='BillNo',
    @SortingDirection VARCHAR(10)='ASC'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @FromDateOnly DATE=CAST(@FromDate AS DATE), @ToDateOnly DATE=CAST(@ToDate AS DATE);
    DECLARE @BranchGuid UNIQUEIDENTIFIER=TRY_CAST(@BranchID AS UNIQUEIDENTIFIER);
    WITH FilteredEinvoice AS (
        SELECT e.GuID,e.BillNo,e.BillDateTime,e.xmlFileName,e.ResponseStatus,e.ResponseMsg,e.InvoiceType,e.InvoiceHash,e.ReSubmitStatus,e.Version,b.Name AS BranchName,
            ROW_NUMBER() OVER (ORDER BY
                CASE WHEN @SortingDirection='ASC' THEN CASE WHEN @SortingColumn='BillNo' THEN e.BillNo WHEN @SortingColumn='ResponseStatus' THEN e.ResponseStatus ELSE e.BillNo END END ASC,
                CASE WHEN @SortingDirection='DESC' THEN CASE WHEN @SortingColumn='BillNo' THEN e.BillNo WHEN @SortingColumn='ResponseStatus' THEN e.ResponseStatus ELSE e.BillNo END END DESC,
                CASE WHEN @SortingDirection='ASC' AND @SortingColumn='BillDateTime' THEN e.BillDateTime END ASC,
                CASE WHEN @SortingDirection='DESC' AND @SortingColumn='BillDateTime' THEN e.BillDateTime END DESC
            ) AS RowNum,
            COUNT(*) OVER() AS RowCountVal
        FROM dbo.R_EinvoiceStatus e
        LEFT JOIN dbo.R_SalesMaster sm ON e.BillNo=sm.BillNo AND sm.Deleted=0
        LEFT JOIN dbo.R_SalesTempMaster stm ON e.BillNo=stm.BillNo AND stm.Deleted=0
        LEFT JOIN dbo.R_Branch b ON COALESCE(sm.BranchID,stm.BranchID)=b.GuID
        WHERE CAST(e.BillDateTime AS DATE) BETWEEN @FromDateOnly AND @ToDateOnly
          AND (@BranchID IS NULL OR COALESCE(sm.BranchID,stm.BranchID)=@BranchGuid)
    )
    SELECT GuID,BillNo,BillDateTime,xmlFileName,ResponseStatus,ResponseMsg,InvoiceType,InvoiceHash,ReSubmitStatus,Version,BranchName,RowCountVal AS [RowCount]
    FROM FilteredEinvoice
    WHERE RowNum BETWEEN (@PageNumber-1)*@PageSize+1 AND @PageNumber*@PageSize
    ORDER BY RowNum;
END;
GO
PRINT 'Created or altered SP Report_EinvoiceStatusPaging.';
GO

-- SP: SetAMC (File 1 version — CREATE OR ALTER)
CREATE OR ALTER PROCEDURE [restaurant].[SetAMC]
(
    @BranchID UNIQUEIDENTIFIER,
    @VersionKey NVARCHAR(MAX)
)
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM restaurant.AMCActivation WHERE BranchID=@BranchID)
        UPDATE restaurant.AMCActivation SET VersionKey=@VersionKey WHERE BranchID=@BranchID;
    ELSE
        INSERT INTO restaurant.AMCActivation (VersionKey,BranchID) VALUES (@VersionKey,@BranchID);
END
GO
PRINT 'Created or altered SP SetAMC.';
GO

-- SP: Get_ConsolidatedItemWiseReport (only in File 2 — converted to CREATE OR ALTER)
CREATE OR ALTER PROCEDURE [dbo].[Get_ConsolidatedItemWiseReport]
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ResultTable TABLE (SerialNo INT IDENTITY(1,1),Product NVARCHAR(50),Quantity DECIMAL(18,2),Rate DECIMAL(18,8),Amount DECIMAL(18,8));
    DECLARE @ResultTable1 TABLE (SerialNo INT IDENTITY(1,1),Product NVARCHAR(50),Quantity DECIMAL(18,2),Rate DECIMAL(18,8),Amount DECIMAL(18,8));
    INSERT INTO @ResultTable(Product,Quantity,Rate,Amount)
    SELECT P.Name AS Product,SUM(D.Quantity) AS Quantity,D.UnitRate AS Rate,SUM(D.Quantity*D.UnitRate) AS Amount
    FROM dbo.R_SalesDetail D INNER JOIN dbo.R_Product P ON D.ProductID=P.GuID INNER JOIN dbo.R_SalesMaster SM ON D.MasterID=SM.GuID
    WHERE SM.Deleted=0 AND SM.Refund=0 AND SM.Cancelled=0 AND SM.TransactionDate>=@StartDate AND SM.TransactionDate<=@EndDate
    GROUP BY P.Name,D.UnitRate;
    INSERT INTO @ResultTable1(Product,Quantity,Rate,Amount)
    SELECT P.Name AS Product,SUM(DT.Quantity) AS Quantity,DT.UnitRate AS Rate,SUM(DT.Quantity*DT.UnitRate) AS Amount
    FROM dbo.R_SalesTempDetail DT INNER JOIN dbo.R_Product P ON DT.ProductID=P.GuID INNER JOIN dbo.R_SalesTempMaster SM ON DT.MasterID=SM.GuID
    WHERE SM.Deleted=0 AND SM.Refund=0 AND SM.Cancelled=0 AND SM.TransactionDate>=@StartDate AND SM.TransactionDate<=@EndDate
    GROUP BY P.Name,DT.UnitRate;
    ;WITH ConsolidatedResults AS (SELECT Product,Quantity,Rate,Amount FROM @ResultTable UNION ALL SELECT Product,Quantity,Rate,Amount FROM @ResultTable1)
    SELECT ROW_NUMBER() OVER (ORDER BY Product) AS SerialNo,Product,SUM(Quantity) AS Quantity,AVG(Rate) AS Rate,SUM(Amount) AS Amount
    FROM ConsolidatedResults GROUP BY Product ORDER BY Product;
END;
GO
PRINT 'Created or altered SP Get_ConsolidatedItemWiseReport.';
GO

-- SP: R_GetActivationPayload (only in File 2 — converted to CREATE OR ALTER)
CREATE OR ALTER PROCEDURE [dbo].[R_GetActivationPayload]
(
    @BranchGuid UNIQUEIDENTIFIER,
    @ServerName NVARCHAR(200),
    @ServerIP NVARCHAR(100),
    @WindowsDbVersion NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT C.ID AS CompanyId,C.Name AS CompanyName,C.FullName AS CompanyFullName,C.Address1 AS CompanyAddress1,C.Address2 AS CompanyAddress2,C.Address3 AS CompanyCity,C.LocationName AS CompanyState,C.Phone AS CompanyPhone,C.Email AS CompanyEmail,B.ID AS BranchId,B.Guid AS BranchGuid,B.Name AS BranchName,B.Address1 AS BranchAddress1,B.Address2 AS BranchAddress2,B.Address3 AS BranchCity,@ServerName AS ServerName,DB_NAME() AS DatabaseName,@ServerIP AS ServerIP,@WindowsDbVersion AS WindowsDbVersion
    FROM R_Company C INNER JOIN R_Branch B ON B.CompanyID=C.ID;
END;
GO
PRINT 'Created or altered SP R_GetActivationPayload.';
GO

-- SP: GetDailySectionSummaryByTab (only in File 2 — converted to CREATE OR ALTER)
CREATE OR ALTER PROCEDURE [restaurant].[GetDailySectionSummaryByTab]
    @TransactionDate DATE,
    @TabID UNIQUEIDENTIFIER
AS
BEGIN
    SELECT S.ZoneGUID,Z.Name AS ZoneName,S.GUID AS SectionID,S.Name AS SectionName,M.TransactionDate AS Date,
        CASE WHEN ISNULL(M.Refund,0)=0 AND ISNULL(M.Cancelled,0)=0 AND ISNULL(M.Deleted,0)=0 AND ISNULL(M.IsComplementary,0)=0 THEN 'Sales'
             WHEN ISNULL(M.Refund,0)=1 AND ISNULL(M.Cancelled,0)=0 THEN 'Refund'
             WHEN ISNULL(M.Refund,0)=0 AND ISNULL(M.Cancelled,0)=1 THEN 'Cancelled'
             WHEN ISNULL(M.Deleted,0)=1 AND ISNULL(M.Merged,0)=1 THEN 'Merged'
             WHEN ISNULL(M.IsComplementary,0)=1 THEN 'Complementary'
             WHEN ISNULL(M.Deleted,0)=1 AND ISNULL(M.Merged,0)=0 THEN 'Deleted'
        END AS Type,
        SUM(D.Quantity) AS Quantity,SUM(M.Total) AS Amount,SUM(M.ProdDiscount) AS ProdDiscount,SUM(M.Tax) AS Tax,
        SUM(M.CessAmount) AS Cess,SUM(M.Discount) AS Discount,SUM(M.RoundOff) AS RoundOff,
        SUM(ISNULL(MSA.DelAmount,0)+ISNULL(MSA.ContAmount,0)+ISNULL(MSA.OtherAmount,0)) AS ExtraCharge,
        SUM(M.Total-M.ProdDiscount+M.Tax+M.CessAmount-M.Discount+M.RoundOff+ISNULL(MSA.DelAmount,0)+ISNULL(MSA.ContAmount,0)+ISNULL(MSA.OtherAmount,0)) AS NetTotal,
        SUM(M.Cash) AS Cash,SUM(M.Card) AS Card,SUM(M.CustomerCredit) AS Credit,SUM(M.RedeemPoints) AS Redeem,
        SUM(M.Pax) AS Pax,ISNULL(RepaymentSummary.Repayment,0) AS CreditRepayment
    FROM R_SalesMaster M
    INNER JOIN (SELECT MasterID,SUM(Quantity) AS Quantity FROM R_SalesDetail GROUP BY MasterID) D ON D.MasterID=M.GUID
    INNER JOIN R_Section S ON S.GUID=M.SectionID
    LEFT JOIN restaurant.ZoneMaster Z ON Z.GUID=S.ZoneGUID
    LEFT JOIN R_MiscellaneousSalesAmount MSA ON MSA.MasterID=M.GUID AND MSA.Merged=0
    LEFT JOIN (SELECT SUM(CCD.Amount) AS Repayment FROM R_CustomerCreditRepayment CCR INNER JOIN R_CustomerCreditDetail CCD ON CCD.MasterID=CCR.GuID WHERE CCR.Date=@TransactionDate AND CCD.Type='Debit' AND CCD.Module='SalesRepayment' AND CCD.BillID IN (SELECT GuID FROM R_SalesMaster WHERE TabID=@TabID)) RepaymentSummary ON 1=1
    WHERE M.TransactionDate=@TransactionDate AND M.TabID=@TabID
    GROUP BY S.ZoneGUID,Z.Name,S.GUID,S.Name,M.TransactionDate,M.Refund,M.Cancelled,M.Deleted,M.Merged,M.IsComplementary,RepaymentSummary.Repayment
END;
GO
PRINT 'Created or altered SP GetDailySectionSummaryByTab.';
GO

-- SP: GetModifierCategoriesWithModifiers (only in File 2 — converted to CREATE OR ALTER)
CREATE OR ALTER PROCEDURE [restaurant].[GetModifierCategoriesWithModifiers]
AS
BEGIN
    SELECT MC.GUID AS ModifierCategoryID,MC.Name AS ModifierCategoryName,M.GUID AS ModifierID,M.Name AS ModifierName,M.Rate
    FROM R_ModifierCategory MC INNER JOIN R_Modifiers M ON M.ModifierCategoryID=MC.GUID
    WHERE MC.Deleted=0 ORDER BY MC.Name,M.Name
END;
GO
PRINT 'Created or altered SP GetModifierCategoriesWithModifiers.';
GO

-- SP: Section_GetAllByZone (only in File 2 — converted to CREATE OR ALTER)
CREATE OR ALTER PROCEDURE [restaurant].[Section_GetAllByZone]
(
 @BranchID VARCHAR(500) = NULL,
 @ZoneID VARCHAR(500) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT S.ID,S.[GuID],Name,ShortName,IsMultiOrderEnabled,IsTableEnable,CONVERT(BIGINT,S.[Version])[Version],Deleted,S.ZoneGuID,IsCustomerEnable,isChairEnabled,IsPaxEnabled
    FROM R_Section S WHERE (@ZoneID IS NULL OR S.ZoneGuID=@ZoneID) ORDER BY Name;
    SET NOCOUNT OFF;
END;
GO
PRINT 'Created or altered SP Section_GetAllByZone.';
GO

-- SP: GetCustomerLoyaltyPoints (only in File 2 — converted to CREATE OR ALTER)
CREATE OR ALTER PROCEDURE [dbo].[GetCustomerLoyaltyPoints]
    @CustomerID UNIQUEIDENTIFIER,
    @CurrentDate Date,
    @SalesMasterID UNIQUEIDENTIFIER
AS
BEGIN
    SELECT ISNULL(SUM(pointsremaining),0) AS TotalLoyalty
    FROM R_CustomerLoyalty
    WHERE CustomerID=@CustomerID AND expirydate>=@CurrentDate AND pointsremaining>0 AND EntryDate!=@CurrentDate;
END;
GO
PRINT 'Created or altered SP GetCustomerLoyaltyPoints.';
GO

-- SP: GetCustomerLoyaltyReport (only in File 2 — converted to CREATE OR ALTER)
CREATE OR ALTER PROCEDURE [dbo].[GetCustomerLoyaltyReport]
    @CustomerID UNIQUEIDENTIFIER NULL,
    @CurrentDate Date,
    @ExpiringIn INT,
    @ExpiringThisMonth INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ExpiryDays INT;
    SELECT @ExpiryDays=CAST([Value] AS INT) FROM R_Settings WHERE [Key]='LoyaltyPointExpiryDays';
    IF @ExpiringThisMonth IS NOT NULL AND @ExpiringThisMonth != 0
    BEGIN
        SELECT C.Name,C.Address1,C.Mobile,Data.Date AS BillDate,Data.BillNo as BillNo,ISNULL(CL.TotalLoyalty,0) AS Loyalty,ISNULL(Data.RedeemPoints,0) AS RedeemPoints,PointsRemaining AS Balance,CL.ExpiryDate AS ExpiryDate,DATEDIFF(DAY,@CurrentDate,DATEADD(DAY,@ExpiryDays,CL.EntryDate)) AS DaysRemaining
        FROM (SELECT GuID,BillNo,CustomerID,Date,RedeemPoints FROM R_SalesMaster WHERE (CustomerID=@CustomerID OR @CustomerID IS NULL) AND Date<=@CurrentDate UNION ALL SELECT GuID,BillNo,CustomerID,Date,RedeemPoints FROM R_SalesTempMaster WHERE (CustomerID=@CustomerID OR @CustomerID IS NULL) AND Date<=@CurrentDate) AS Data
        LEFT JOIN R_CustomerLoyalty CL ON Data.GuID=CL.SalesMasterID LEFT JOIN R_Customer C ON C.GuID=Data.CustomerID
        WHERE (MONTH(CL.ExpiryDate)=@ExpiringThisMonth) ORDER BY Data.BillNo DESC;
    END
    ELSE IF @ExpiringIn != 0
    BEGIN
        SELECT C.Name,C.Address1,C.Mobile,Data.Date AS BillDate,Data.BillNo as BillNo,ISNULL(CL.TotalLoyalty,0) AS Loyalty,ISNULL(Data.RedeemPoints,0) AS RedeemPoints,PointsRemaining AS Balance,CL.ExpiryDate AS ExpiryDate,DATEDIFF(DAY,@CurrentDate,DATEADD(DAY,@ExpiryDays,CL.EntryDate)) AS DaysRemaining
        FROM (SELECT GuID,BillNo,CustomerID,Date,RedeemPoints FROM R_SalesMaster WHERE (CustomerID=@CustomerID OR @CustomerID IS NULL) AND Date<=@CurrentDate UNION ALL SELECT GuID,BillNo,CustomerID,Date,RedeemPoints FROM R_SalesTempMaster WHERE (CustomerID=@CustomerID OR @CustomerID IS NULL) AND Date<=@CurrentDate) AS Data
        LEFT JOIN R_CustomerLoyalty CL ON Data.GuID=CL.SalesMasterID LEFT JOIN R_Customer C ON C.GuID=Data.CustomerID
        WHERE DATEDIFF(DAY,@CurrentDate,DATEADD(DAY,@ExpiryDays,CL.EntryDate))<@ExpiringIn AND DATEDIFF(DAY,@CurrentDate,DATEADD(DAY,@ExpiryDays,CL.EntryDate))>0
        ORDER BY Data.BillNo DESC;
    END
    ELSE
    BEGIN
        SELECT C.Name,C.Address1,C.Mobile,Data.Date AS BillDate,Data.BillNo as BillNo,ISNULL(CL.TotalLoyalty,0) AS Loyalty,ISNULL(Data.RedeemPoints,0) AS RedeemPoints,PointsRemaining AS Balance,CL.ExpiryDate AS ExpiryDate,DATEDIFF(DAY,@CurrentDate,DATEADD(DAY,@ExpiryDays,CL.EntryDate)) AS DaysRemaining
        FROM (SELECT GuID,BillNo,CustomerID,Date,RedeemPoints FROM R_SalesMaster WHERE (CustomerID=@CustomerID OR @CustomerID IS NULL) AND Date<=@CurrentDate UNION ALL SELECT GuID,BillNo,CustomerID,Date,RedeemPoints FROM R_SalesTempMaster WHERE (CustomerID=@CustomerID OR @CustomerID IS NULL) AND Date<=@CurrentDate) AS Data
        LEFT JOIN R_CustomerLoyalty CL ON Data.GuID=CL.SalesMasterID LEFT JOIN R_Customer C ON C.GuID=Data.CustomerID
        WHERE DATEDIFF(DAY,@CurrentDate,DATEADD(DAY,@ExpiryDays,CL.EntryDate))<@ExpiringIn ORDER BY Data.BillNo DESC;
    END
END;
GO
PRINT 'Created or altered SP GetCustomerLoyaltyReport.';
GO

-- SP: GetCustomerLoyaltySummary (only in File 2 — converted to CREATE OR ALTER)
CREATE OR ALTER PROCEDURE [dbo].[GetCustomerLoyaltySummary]
    @CustomerID UNIQUEIDENTIFIER NULL,
    @FromDate DATE,
    @ToDate DATE,
    @CurrentDate Date
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ExpiryDays INT;
    SELECT @ExpiryDays=CAST([Value] AS INT) FROM R_Settings WHERE [Key]='LoyaltyPointExpiryDays';
    SELECT C.Name,C.Address1,C.Mobile,Data.Date AS BillDate,Data.BillNo as BillNo,ISNULL(CL.TotalLoyalty,0) AS Loyalty,ISNULL(Data.RedeemPoints,0) AS RedeemPoints,PointsRemaining AS Balance,CL.ExpiryDate AS ExpiryDate,DATEDIFF(DAY,@CurrentDate,DATEADD(DAY,@ExpiryDays,CL.EntryDate)) AS DaysRemaining
    FROM (SELECT GuID,BillNo,CustomerID,Date,RedeemPoints FROM R_SalesMaster WHERE (CustomerID=@CustomerID OR @CustomerID IS NULL) AND Date BETWEEN @FromDate AND @ToDate UNION ALL SELECT GuID,BillNo,CustomerID,Date,RedeemPoints FROM R_SalesTempMaster WHERE (CustomerID=@CustomerID OR @CustomerID IS NULL) AND Date BETWEEN @FromDate AND @ToDate) AS Data
    LEFT JOIN R_CustomerLoyalty CL ON Data.GuID=CL.SalesMasterID LEFT JOIN R_Customer C ON C.GuID=Data.CustomerID ORDER BY Data.BillNo DESC;
END;
GO
PRINT 'Created or altered SP GetCustomerLoyaltySummary.';
GO

-- SP: sp_redeem_loyalty_points (only in File 2 — converted to CREATE OR ALTER)
CREATE OR ALTER PROCEDURE [dbo].[sp_redeem_loyalty_points]
    @user_id VARCHAR(MAX),
    @redeem_amount INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @remaining_to_redeem INT=@redeem_amount, @points_id INT, @points_remaining INT, @deduct INT;
    DECLARE point_cursor CURSOR FOR SELECT CustomerLoyaltyID,PointsRemaining FROM R_CustomerLoyalty WHERE CustomerID=@user_id AND ExpiryDate>=CAST(GETDATE() AS DATE) AND PointsRemaining>0 ORDER BY ExpiryDate ASC;
    OPEN point_cursor;
    FETCH NEXT FROM point_cursor INTO @points_id,@points_remaining;
    WHILE @@FETCH_STATUS=0 AND @remaining_to_redeem>0
    BEGIN
        SET @deduct=CASE WHEN @remaining_to_redeem>=@points_remaining THEN @points_remaining ELSE @remaining_to_redeem END;
        UPDATE R_CustomerLoyalty SET PointsRemaining=PointsRemaining-@deduct,Used=CASE WHEN PointsRemaining-@deduct=0 THEN 1 ELSE 0 END WHERE CustomerLoyaltyID=@points_id;
        SET @remaining_to_redeem=@remaining_to_redeem-@deduct;
        FETCH NEXT FROM point_cursor INTO @points_id,@points_remaining;
    END
    CLOSE point_cursor; DEALLOCATE point_cursor;
    IF @remaining_to_redeem>0 PRINT 'Not enough available loyalty points to redeem the full amount.';
    ELSE PRINT 'Loyalty points redeemed successfully.';
END;
GO
PRINT 'Created or altered SP sp_redeem_loyalty_points.';
GO

-- SP: Save_ProductImages (only in File 2 — converted to CREATE OR ALTER)
CREATE OR ALTER PROCEDURE [restaurant].[Save_ProductImages]
    @ProductGuID UNIQUEIDENTIFIER,
    @UDT_ProductImage dbo.UDT_ProductImage READONLY
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM dbo.R_ProductImage WHERE ProductGuID=@ProductGuID;
        INSERT INTO dbo.R_ProductImage(ProductGuID,ImageURL,ThumbnailURL,IsPrimary,CreatedDate)
        SELECT ProductGuID,ImageURL,ThumbnailURL,IsPrimary,GETDATE() FROM @UDT_ProductImage;
        ;WITH RankedImages AS (SELECT *,ROW_NUMBER() OVER (PARTITION BY ProductGuID ORDER BY CASE WHEN IsPrimary=1 THEN 0 ELSE 1 END,ID) AS RowNum FROM dbo.R_ProductImage WHERE ProductGuID=@ProductGuID)
        UPDATE RankedImages SET IsPrimary=CASE WHEN RowNum=1 THEN 1 ELSE 0 END;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION; THROW;
    END CATCH
END;
GO
PRINT 'Created or altered SP Save_ProductImages.';
GO

-- SP: GetPLBalanceForBalanceSheet
CREATE OR ALTER PROCEDURE [dbo].[GetPLBalanceForBalanceSheet] (@Date datetime, @OpeningStockID varchar(max), @BranchID varchar(max))
AS
DECLARE @mIncome money, @mExpense money;
BEGIN
    SELECT @mIncome=SUM(dbo.LedgerOB(Ledger.GuID,@Date,'False',@BranchID,DEFAULT)-dbo.LedgerOB(Ledger.GuID,@Date,'True',@BranchID,DEFAULT)) FROM Ledger,[Group] WHERE Ledger.GroupID=[Group].GuID AND [Group].ParentGroupID IN ('0E0B7E4E-D2B3-4F66-99FC-FA05E25F7A85');
    SET @mIncome=@mIncome;
    SELECT @mExpense=SUM(dbo.LedgerOB(Ledger.GuID,@Date,'True',@BranchID,DEFAULT)-dbo.LedgerOB(Ledger.GuID,@Date,'False',@BranchID,DEFAULT)) FROM Ledger,[Group] WHERE Ledger.GroupID=[Group].GuID AND [Group].ParentGroupID IN ('95A60409-E708-4FB4-BE18-EA22BA994714');
    SET @mExpense=@mExpense+dbo.LedgerOB(@OpeningStockID,@Date,'True',@BranchID,DEFAULT)-dbo.LedgerOB(@OpeningStockID,@Date,'False',@BranchID,DEFAULT);
    IF @mIncome>@mExpense SELECT 'Net Profit' as Status,ISNULL(@mIncome-@mExpense,0) as Amount;
    ELSE SELECT 'Net Loss' as Status,ISNULL(@mExpense-@mIncome,0) as Amount;
END
GO
PRINT 'Created or altered SP GetPLBalanceForBalanceSheet.';
GO

-- SP: User_GetAllByBranch
CREATE OR ALTER PROCEDURE [restaurant].[User_GetAllByBranch]
(
    @BranchID VARCHAR(500) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- NULL-safe: @BranchID IS NULL returns all users (TAB login); real BranchID filters by ULM
    SELECT DISTINCT
        U.Id, Username, Password, UserTypeID, U.Name, PrimaryPhone, SecondaryPhone,
        Address1, Address2, Address3, Email, U.[GuID],
        ISNULL(FinancialYearID, 0) FinancialYearID,
        ISNULL(CompanyID, 0) CompanyID, ISNULL(ClientID, 0) ClientID, UserTypeGuID,
        CONVERT(BIGINT, U.[Version]) [Version], U.Deleted, CanAccessWeb, [Level], UserCode,
        1 AS IsActive
    FROM [R_User] U
    LEFT JOIN R_UserType UT ON UT.Guid = U.UserTypeGuid
    WHERE U.Deleted = 0
      AND U.ID <> 1
      AND (
          @BranchID IS NULL
          OR EXISTS (
              SELECT 1 FROM [restaurant].[UserLocationMapping] ULM
              WHERE ULM.UserID = U.[GuID] AND ULM.BranchID = @BranchID AND ULM.IsActive = 1
          )
      );
    -- Second result set kept for WEBAPI AssignedBranch mapping (ds.Tables[1])
    SELECT ULM.UserID, ULM.BranchID, ULM.IsDefaultBranch, ULM.IsActive, R_Branch.Name
    FROM [restaurant].[UserLocationMapping] ULM
    INNER JOIN R_Branch ON ULM.BranchID = R_Branch.GuID;
    SET NOCOUNT OFF;
END
GO
PRINT 'Created or altered SP User_GetAllByBranch.';
GO

-- SP: Report_ItemWiseSalesreportPaging (File 1)
CREATE OR ALTER PROCEDURE [restaurant].[Report_ItemWiseSalesreportPaging]
(
 @IsDayClosed      INT		     = NULL,
 @CounterID        VARCHAR(MAX)  = NULL,
 @SectionID        VARCHAR(MAX)  = NULL,
 @ProductID        VARCHAR(MAX)  = NULL,
 @CategoryID       VARCHAR(MAX)  = NULL,
 @FromDate         DATE		     = NULL,
 @ToDate           DATE			 = NULL,
 @UserID           VARCHAR(MAX)  = NULL,
 @GroupID          VARCHAR(MAX)  = NULL,
 @VatEnabled	   BIT			 = NULL,
 @PageNumber       INT           = NULL,
 @PageSize		   INT           = NULL,
 @SortingColumn	   VARCHAR(MAX)  = NULL,
 @SortingDirection VARCHAR(MAX)  = NULL,
 @BranchID		   VARCHAR(MAX)  = NULL
 )
AS
BEGIN
	DECLARE
	     @R_IsDayClosed      INT				 = @IsDayClosed,
		 @R_CounterID        VARCHAR(MAX)		 = @CounterID,
		 @R_SectionID        VARCHAR(MAX)		 = @SectionID,
		 @R_ProductID        VARCHAR(MAX)		 = @ProductID,
		 @R_CategoryID       VARCHAR(MAX)		 = @CategoryID,
		 @R_FromDate         DATE				 = @FromDate,
		 @R_ToDate           DATE				 = @ToDate,
		 @R_UserID           VARCHAR(MAX)		 = @UserID,
		 @R_GroupID          VARCHAR(MAX)		 = @GroupID,
	     @R_VatEnabled       BIT				 = @VatEnabled,
	 	 @R_PageNumber		 INT				 = @PageNumber,
         @R_PageSize		 INT				 = @PageSize,
         @R_SortingColumn    VARCHAR(MAX)        = @SortingColumn,
         @R_SortingDirection VARCHAR(MAX)        = @SortingDirection,
		 @R_BranchID         VARCHAR(MAX)		 = @BranchID

	 DECLARE @SortingCmd VARCHAR(MAX)

	SET ARITHABORT ON; SET XACT_ABORT ON; SET NOCOUNT ON;
	SET @R_ToDate = DATEADD(D, 1, @R_ToDate);
	SET @R_VatEnabled = (Select CASE WHEN Value = 'True' THEN 1 ELSE 0 END AS Value from R_Settings where [Key] = 'IsVATEnabled');

	IF Object_id('TempDB.dbo.#ItemWiseSalesReport') IS NOT NULL DROP TABLE #ItemWiseSalesReport;
	IF Object_id('TempDB.dbo.#ItemWiseSalesReportCount') IS NOT NULL DROP TABLE #ItemWiseSalesReportCount;

	SELECT * INTO #ItemWiseSalesReport FROM (
		SELECT SM.[No],SM.BillNo,SM.BillTime,SM.TransactionDate AS BillDate,PM.Name AS Product,SD.Quantity,SD.UnitRate AS Rate,SD.TaxPercentage
		,CASE WHEN @R_VatEnabled=1 THEN SD.Tax ELSE 0.00 END AS VATAmount
		,CASE WHEN @R_VatEnabled=1 THEN 0.00 ELSE SD.Tax END AS TaxAmount
		,CASE WHEN @R_VatEnabled=1 THEN 0.00 ELSE SD.Tax/2 END AS CGST
		,CASE WHEN @R_VatEnabled=1 THEN 0.00 ELSE SD.Tax/2 END AS SGST
		,SD.Discount
		,((SD.unitRate*SD.Quantity)-SD.Discount)+(SD.Tax)+(SD.CessAmount) AS Total
		,S.Name [Section],C.Name [Counter],U.Name AS [User],GE.Name as [Group],Z.Name as ZoneName
		,CT.Name as CategoryName,CM.Name as CategoryMaster,ISNULL(ST.Name,'No Table') as TableName,SM.LastUpdate
		FROM R_SalesMaster SM
		INNER JOIN R_SalesDetail SD ON SD.[MasterID]=SM.[GuID]
		INNER JOIN restaurant.Product PM ON PM.[GuID]=SD.ProductId
		INNER JOIN restaurant.ProductPriceDetail PPD ON PPD.MasterID=PM.[GuID] AND PPD.BranchID=@R_BranchID
		LEFT JOIN R_SectionTables ST ON ST.GUID=SM.TableID
		LEFT OUTER JOIN restaurant.Section S ON SM.SectionID=S.[GuID]
		LEFT OUTER JOIN restaurant.ZoneMaster Z ON S.ZoneGuid=Z.[GuID]
		INNER JOIN R_GroupEntry GE ON GE.[Guid]=PPD.GroupID
		LEFT OUTER JOIN R_Counter C ON SM.CounterID=C.[GuID]
		LEFT OUTER JOIN R_User U on U.[GuID]=SM.WaiterID
		LEFT JOIN R_Category CT On PPD.CategoryID=CT.GuID
		LEFT JOIN restaurant.CategoryMaster CM On CM.GuID=CT.CategoryMasterGuID
		WHERE SM.Refund=0 AND SM.Deleted=0 AND SM.Cancelled=0
		AND (SD.ProductId=@R_ProductID OR @R_ProductID IS NULL)
		AND (S.[GuID]=@R_SectionID OR @R_SectionID IS NULL)
		AND (C.[GuID]=@R_CounterID OR @R_CounterID IS NULL)
		AND (SM.WaiterID=@R_UserID OR @R_UserID IS NULL)
		AND (PPD.CategoryID=@R_CategoryID OR @R_CategoryID IS NULL)
		AND (SM.TransactionDate>=@R_FromDate OR @R_FromDate IS NULL) AND (SM.TransactionDate<@R_ToDate OR @R_ToDate IS NULL)
		AND (SM.BranchID=@R_BranchID OR @R_BranchID IS NULL)
		UNION ALL
		SELECT SM.[No],SM.BillNo,SM.BillTime,SM.TransactionDate AS BillDate,PM.Name AS Product,SD.Quantity
		,SD.UnitRate AS Rate,SD.TaxPercentage,0 AS VATAmount,SD.Tax AS TaxAmount,SD.Tax/2 AS CGST,SD.Tax/2 AS SGST
		,SD.Discount,((SD.unitRate*SD.Quantity)-SD.Discount)+(SD.Tax)+(SD.CessAmount) AS Total
		,S.Name [Section],C.Name [Counter],U.Name AS [User],GE.Name as [Group],Z.Name as ZoneName
		,CT.Name as CategoryName,CM.Name as CategoryMaster,ST.Name as TableName,SM.LastUpdate
		FROM R_SalesTempMaster SM
		INNER JOIN R_SalesTempDetail SD ON SD.[MasterID]=SM.[GuID]
		INNER JOIN restaurant.Product PM ON PM.[GuID]=SD.ProductId
		INNER JOIN restaurant.ProductPriceDetail PPD ON PPD.MasterID=PM.[GuID] AND PPD.BranchID=@R_BranchID
		LEFT JOIN R_SectionTables ST ON ST.GUID=SM.TableID
		LEFT OUTER JOIN restaurant.Section S ON SM.SectionID=S.[GuID]
		LEFT OUTER JOIN restaurant.ZoneMaster Z ON S.ZoneGuid=Z.[GuID]
		INNER JOIN R_GroupEntry GE ON GE.[Guid]=PPD.GroupID
		LEFT OUTER JOIN R_Counter C ON SM.CounterID=C.[GuID]
		LEFT OUTER JOIN R_User U on U.[GuID]=SM.WaiterID
		LEFT JOIN R_Category CT On PPD.CategoryID=CT.GuID
		LEFT JOIN restaurant.CategoryMaster CM On CM.GuID=CT.CategoryMasterGuID
		WHERE SM.Refund=0 AND SM.Deleted=0 AND SM.Cancelled=0
		AND (SD.ProductId=@R_ProductID OR @R_ProductID IS NULL)
		AND (S.[GuID]=@R_SectionID OR @R_SectionID IS NULL)
		AND (C.[GuID]=@R_CounterID OR @R_CounterID IS NULL)
		AND (SM.WaiterID=@R_UserID OR @R_UserID IS NULL)
		AND (PPD.CategoryID=@R_CategoryID OR @R_CategoryID IS NULL)
		AND (SM.TransactionDate>=@R_FromDate OR @R_FromDate IS NULL) AND (SM.TransactionDate<@R_ToDate OR @R_ToDate IS NULL)
		AND (SM.BranchID=@R_BranchID OR @R_BranchID IS NULL)
	) AS ReportDetail ORDER BY Section,BillDate,[No],Product;

	SELECT COUNT(*) AS ItemWiseSalesCount INTO #ItemWiseSalesReportCount FROM #ItemWiseSalesReport;

	IF @PageSize=-1
	BEGIN
		IF @R_SortingColumn IS NULL
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT ItemWiseSalesCount FROM #ItemWiseSalesReportCount)[RowCount] FROM #ItemWiseSalesReport ORDER BY BillDate '+@R_SortingDirection+',[No] '+@R_SortingDirection+',Product '+@R_SortingDirection;
			EXEC(@SortingCmd);
		END
		ELSE
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT ItemWiseSalesCount FROM #ItemWiseSalesReportCount)[RowCount],BillDate AS BillDate1,[No] AS [No1],Product AS Product1 FROM #ItemWiseSalesReport ORDER BY '+@R_SortingColumn+' '+@R_SortingDirection+',BillDate1 asc,[No1] asc,Product1 asc';
			EXEC(@SortingCmd);
		END
	END
	ELSE
	BEGIN
		IF @R_SortingColumn IS NULL
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT ItemWiseSalesCount FROM #ItemWiseSalesReportCount)[RowCount] FROM #ItemWiseSalesReport ORDER BY BillDate '+@R_SortingDirection+',[No] '+@R_SortingDirection+',Product '+@R_SortingDirection+' OFFSET ('+CAST(@R_PageNumber-1 AS NVARCHAR(MAX))+')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS FETCH NEXT '+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS ONLY';
			EXEC(@SortingCmd);
		END
		ELSE
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT ItemWiseSalesCount FROM #ItemWiseSalesReportCount)[RowCount],BillDate AS BillDate1,[No] AS [No1],Product AS Product1 FROM #ItemWiseSalesReport ORDER BY '+@R_SortingColumn+' '+@R_SortingDirection+',BillDate1 asc,[No1] asc,Product1 asc OFFSET ('+CAST(@R_PageNumber-1 AS NVARCHAR(MAX))+')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS FETCH NEXT '+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS ONLY';
			EXEC(@SortingCmd);
		END
	END

	SELECT ''AS [No],''AS BillNo,''AS BillDate,''AS Product,SUM(Quantity)Quantity,SUM(Rate)Rate,''AS TaxPercentage,SUM(VATAmount)VATAmount,SUM(TaxAmount)TaxAmount,SUM(CGST)CGST,SUM(SGST)SGST,SUM(Discount)Discount,SUM(Total)Total,''AS [Section],''AS [Counter],''AS [User] FROM #ItemWiseSalesReport;

	IF Object_id('TempDB.dbo.#ItemWiseSalesReport') IS NOT NULL DROP TABLE #ItemWiseSalesReport;
	IF Object_id('TempDB.dbo.#ItemWiseSalesReportCount') IS NOT NULL DROP TABLE #ItemWiseSalesReportCount;
	SET NOCOUNT OFF;
END
GO
PRINT 'Created or altered SP Report_ItemWiseSalesreportPaging.';
GO

-- SP: Report_ItemWiseSalesReportSummaryPaging (File 1)
CREATE OR ALTER PROCEDURE [restaurant].[Report_ItemWiseSalesReportSummaryPaging]
(
	 @IsDayClosed           INT			    = NULL,
	 @CounterID             VARCHAR(MAX)	= NULL,
	 @SectionID             VARCHAR(MAX)	= NULL,
	 @ProductID             VARCHAR(MAX)	= NULL,
	 @CategoryID            VARCHAR(MAX)	= NULL,
	 @FromDate              DATE			= NULL,
	 @ToDate                DATE			= NULL,
	 @UserID                VARCHAR(MAX)	= NULL,
	 @GroupID               VARCHAR(MAX)	= NULL,
	 @PageNumber			INT             = NULL,
     @PageSize				INT             = NULL,
     @SortingColumn			VARCHAR(MAX)    = NULL,
     @SortingDirection		VARCHAR(MAX)    = NULL,
     @BranchID				VARCHAR(MAX)	= NULL
)
AS
BEGIN
    DECLARE
	 @R_IsDayClosed      INT			= @IsDayClosed,
	 @R_CounterID        VARCHAR(MAX)	= @CounterID,
	 @R_SectionID        VARCHAR(MAX)	= @SectionID,
	 @R_ProductID        VARCHAR(MAX)	= @ProductID,
	 @R_CategoryID       VARCHAR(MAX)	= @CategoryID,
	 @R_FromDate         DATE			= @FromDate,
	 @R_ToDate           DATE			= @ToDate,
	 @R_UserID           VARCHAR(MAX)	= @UserID,
     @R_GroupID          VARCHAR(MAX)	= @GroupID,
     @R_PageNumber		 INT		    = @PageNumber,
     @R_PageSize		 INT		    = @PageSize,
     @R_SortingColumn    VARCHAR(MAX)   = @SortingColumn,
     @R_SortingDirection VARCHAR(MAX)   = @SortingDirection,
	 @R_BranchID         VARCHAR(MAX)   = @BranchID;

	DECLARE @SortingCmd VARCHAR(MAX);
	SET ARITHABORT ON; SET XACT_ABORT ON; SET NOCOUNT ON;
	SET @R_ToDate = DATEADD(D, 1, @R_ToDate);

	IF Object_id('TempDB.dbo.#ItemWiseSalesReportSummary') IS NOT NULL DROP TABLE #ItemWiseSalesReportSummary;
	IF Object_id('TempDB.dbo.#ItemWiseSalesReportSummaryCount') IS NOT NULL DROP TABLE #ItemWiseSalesReportSummaryCount;

	SELECT * INTO #ItemWiseSalesReportSummary FROM (
		SELECT Product,[TransactionDate],[Group],[Category],[BRANCH],SUM(Quantity)Quantity,SUM(Rate)Rate,SUM(Total)Total,[Section],[Counter],[ZoneName],BillTime,CategoryMaster
		FROM (
			SELECT PM.Name AS Product,SM.[TransactionDate],GE.[Name] as [Group],CP.[Name] AS [Category],BR.[Name] AS [BRANCH],
				SUM(SD.Quantity)Quantity,SUM(SD.UnitRate) AS Rate,
				SUM(((SD.unitRate*SD.Quantity)-SD.Discount)+(SD.Tax)+(SD.CessAmount)+(SM.RoundOff)) Total,
				S.Name [Section],C.Name [Counter],Z.Name as ZoneName,SM.BillTime,CM.Name as CategoryMaster
			FROM restaurant.Product PM
			INNER JOIN restaurant.ProductPriceDetail PPD ON PPD.MasterID=PM.[GuID]
			INNER JOIN R_Branch BR ON PPD.BranchID=BR.[GuID]
			INNER JOIN R_SalesMaster SM ON BR.[GuID]=SM.BranchID AND SM.BranchID=@BranchID
			INNER JOIN R_SalesDetail SD ON SD.[MasterID]=SM.[GuID] AND PPD.MasterID=SD.ProductID
			INNER JOIN R_Category CP ON CP.[GuID]=PPD.CategoryID
			INNER JOIN restaurant.CategoryMaster CM ON CM.GuID=CP.CategoryMasterGuID
			LEFT OUTER JOIN R_GroupEntry GE ON GE.[Guid]=PPD.GroupID
			LEFT OUTER JOIN restaurant.Section S ON SM.SectionID=S.[GuID]
			LEFT OUTER JOIN restaurant.ZoneMaster Z ON S.ZoneGuid=Z.[GuID]
			LEFT OUTER JOIN R_Counter C ON SM.CounterID=C.[GuID]
			WHERE SM.Refund=0 AND SM.Deleted=0 AND SM.Cancelled=0
			AND (SD.ProductId=@R_ProductID OR @R_ProductID IS NULL)
			AND (S.[GuID]=@R_SectionID OR @R_SectionID IS NULL)
			AND (C.[GuID]=@R_CounterID OR @R_CounterID IS NULL)
			AND (SM.WaiterID=@R_UserID OR @R_UserID IS NULL)
			AND (PM.SCategoryID=@R_CategoryID OR @R_CategoryID IS NULL)
			AND (GE.[Guid]=@R_GroupID OR @R_GroupID IS NULL)
			AND (TransactionDate>=@R_FromDate OR @R_FromDate IS NULL) AND (TransactionDate<@R_ToDate OR @R_ToDate IS NULL)
			GROUP BY PM.Name,S.Name,GE.[Name],CP.Name,C.Name,BR.Name,SM.[TransactionDate],Z.Name,SM.BillTime,CM.Name
			UNION ALL
			SELECT PM.Name AS Product,SM.[TransactionDate],GE.[Name] as [Group],CP.[Name] AS [Category],BR.[Name] AS [BRANCH],
				SUM(SD.Quantity)Quantity,SUM(SD.UnitRate) AS Rate,
				SUM(((SD.unitRate*SD.Quantity)-SD.Discount)+(SD.Tax)+(SD.CessAmount)+(SM.RoundOff)) Total,
				S.Name [Section],C.Name [Counter],Z.Name as ZoneName,SM.BillTime,CM.Name as CategoryMaster
			FROM restaurant.Product PM
			INNER JOIN restaurant.ProductPriceDetail PPD ON PPD.MasterID=PM.[GuID]
			LEFT OUTER JOIN R_Branch BR ON PPD.BranchID=BR.[GuID] AND BR.GuID=@R_BranchID OR @R_BranchID IS NULL
			INNER JOIN R_SalesTempMaster SM ON BR.[GuID]=SM.BranchID
			INNER JOIN R_SalesTempDetail SD ON SD.[MasterID]=SM.[GuID] AND PPD.MasterID=SD.ProductID
			INNER JOIN R_Category CP ON CP.[GuID]=PPD.CategoryID
			INNER JOIN restaurant.CategoryMaster CM ON CM.GuID=CP.CategoryMasterGuID
			LEFT OUTER JOIN R_GroupEntry GE ON GE.[Guid]=PPD.GroupID
			LEFT OUTER JOIN restaurant.Section S ON SM.SectionID=S.[GuID]
			LEFT OUTER JOIN restaurant.ZoneMaster Z ON S.ZoneGuid=Z.[GuID]
			LEFT OUTER JOIN R_Counter C ON SM.CounterID=C.[GuID]
			WHERE SM.Refund=0 AND SM.Deleted=0 AND SM.Cancelled=0
			AND (SD.ProductId=@R_ProductID OR @R_ProductID IS NULL)
			AND (S.[GuID]=@R_SectionID OR @R_SectionID IS NULL)
			AND (C.[GuID]=@R_CounterID OR @R_CounterID IS NULL)
			AND (SM.WaiterID=@R_UserID OR @R_UserID IS NULL)
			AND (PM.SCategoryID=@R_CategoryID OR @R_CategoryID IS NULL)
			AND (GE.[Guid]=@R_GroupID OR @R_GroupID IS NULL)
			AND (TransactionDate>=@R_FromDate OR @R_FromDate IS NULL) AND (TransactionDate<@R_ToDate OR @R_ToDate IS NULL)
			GROUP BY PM.Name,S.Name,GE.[Name],CP.Name,C.Name,BR.Name,SM.[TransactionDate],Z.Name,SM.BillTime,CM.Name
		) AS T
		GROUP BY Product,[Group],[Category],[Section],[Counter],[BRANCH],[TransactionDate],ZoneName,BillTime,[CategoryMaster]
	) AS ItemWiseSalesReportDetail;

	SELECT COUNT(*) AS ItemWiseSalesReportSummaryCount INTO #ItemWiseSalesReportSummaryCount FROM #ItemWiseSalesReportSummary;

	IF @PageSize=-1
	BEGIN
		IF @R_SortingColumn IS NULL
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT ItemWiseSalesReportSummaryCount FROM #ItemWiseSalesReportSummaryCount)[RowCount] FROM #ItemWiseSalesReportSummary ORDER BY Product '+@R_SortingDirection;
			EXEC(@SortingCmd);
		END
		ELSE
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT ItemWiseSalesReportSummaryCount FROM #ItemWiseSalesReportSummaryCount)[RowCount],Product as Product1 FROM #ItemWiseSalesReportSummary ORDER BY '+@R_SortingColumn+' '+@R_SortingDirection+',Product1 asc';
			EXEC(@SortingCmd);
		END
	END
	ELSE
	BEGIN
		IF @R_SortingColumn IS NULL
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT ItemWiseSalesReportSummaryCount FROM #ItemWiseSalesReportSummaryCount)[RowCount] FROM #ItemWiseSalesReportSummary ORDER BY Product '+@R_SortingDirection+' OFFSET ('+CAST(@R_PageNumber-1 AS NVARCHAR(MAX))+')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS FETCH NEXT '+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS ONLY';
			EXEC(@SortingCmd);
		END
		ELSE
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT ItemWiseSalesReportSummaryCount FROM #ItemWiseSalesReportSummaryCount)[RowCount],Product as Product1 FROM #ItemWiseSalesReportSummary ORDER BY '+@R_SortingColumn+' '+@R_SortingDirection+',Product1 asc OFFSET ('+CAST(@R_PageNumber-1 AS NVARCHAR(MAX))+')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS FETCH NEXT '+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS ONLY';
			EXEC(@SortingCmd);
		END
	END

	SELECT ''AS Product,''AS [Group],''AS [Category],SUM(Quantity)Quantity,SUM(Rate)Rate,SUM(Total)Total,''AS [Section],''AS [Counter],''AS [BRANCH] FROM #ItemWiseSalesReportSummary;

	IF Object_id('TempDB.dbo.#ItemWiseSalesReportSummary') IS NOT NULL DROP TABLE #ItemWiseSalesReportSummary;
	IF Object_id('TempDB.dbo.#ItemWiseSalesReportSummaryCount') IS NOT NULL DROP TABLE #ItemWiseSalesReportSummaryCount;
	SET NOCOUNT OFF;
END
GO
PRINT 'Created or altered SP Report_ItemWiseSalesReportSummaryPaging.';
GO

-- SP: Report_SalesLogReportPaging (File 1)
CREATE OR ALTER PROCEDURE [restaurant].[Report_SalesLogReportPaging]
(
	 @FromDate         DATE   	     = NULL,
	 @ToDate           DATE          = NULL,
	 @SectionID        VARCHAR(MAX)  = NULL,
	 @UserID           VARCHAR(MAX)  = NULL,
	 @CounterID        VARCHAR(MAX)  = NULL,
	 @IsDayClosed      INT		     = NULL,
	 @VatEnabled	   BIT		     = NULL,
	 @PageNumber       INT           = NULL,
     @PageSize		   INT           = NULL,
     @SortingColumn	   VARCHAR(MAX)  = NULL,
     @SortingDirection VARCHAR(MAX)  = NULL,
	 @Status		   VARCHAR(MAX)  = NULL,
	 @EditType		   VARCHAR(MAX)  = NULL,
	 @BranchID		   VARCHAR(MAX)  = NULL
)
AS
BEGIN
	DECLARE
	 @R_FromDate         DATE    	     = @FromDate,
	 @R_ToDate           DATE    	     = @ToDate,
	 @R_SectionID        VARCHAR(MAX)    = @SectionID,
	 @R_UserID           VARCHAR(MAX)    = @UserID,
	 @R_CounterID        VARCHAR(MAX)    = @CounterID,
	 @R_IsDayClosed      INT		     = @IsDayClosed,
	 @R_VatEnabled	     BIT		     = @VatEnabled,
	 @R_PageNumber		 INT			 = @PageNumber,
     @R_PageSize		 INT			 = @PageSize,
     @R_SortingColumn    VARCHAR(MAX)    = @SortingColumn,
     @R_SortingDirection VARCHAR(MAX)    = @SortingDirection,
     @R_Status			 VARCHAR(MAX)    = @Status,
     @R_EditType		 VARCHAR(MAX)    = @EditType,
	 @R_BranchID         VARCHAR(MAX)	 = @BranchID;

	DECLARE @SortingCmd VARCHAR(MAX);
	SET ARITHABORT ON; SET XACT_ABORT ON; SET NOCOUNT ON;
	SET @R_ToDate = DATEADD(D, 1, @R_ToDate);
	SET @R_VatEnabled = (Select CASE WHEN Value='True' THEN 1 ELSE 0 END AS Value from R_Settings where [Key]='IsVATEnabled');
	SET @R_EditType = CASE WHEN @EditType='RunningOrder' THEN 'Running Order' WHEN @EditType='SettledOrder' THEN 'Settled Order' ELSE @EditType END;

	IF Object_id('TempDB.dbo.#SalesLogReport') IS NOT NULL DROP TABLE #SalesLogReport;
	IF Object_id('TempDB.dbo.#SalesLogReportCount') IS NOT NULL DROP TABLE #SalesLogReportCount;

	SELECT * INTO #SalesLogReport FROM (
		SELECT TransactionDate,[Date] AS BillDate,BillNo,EditDate,EditTime,[User],[Status],Section,Product,Quantity,NewQuantity
			,Rate,DiscountTotal,Amount,VatTotal,CGST,SGST,TaxTotal AS TaxAmount,NetTotal,EditType,ISNULL(NewUnitRate,0)NewUnitRate,[No]
		FROM (
			SELECT SM.TransactionDate,SM.Date,SM.BillNo,SED.UDate EditDate,SED.UDate EditTime,U.UserName [User]
				,CASE WHEN SED.IsUD=1 AND SED.IsDD=0 THEN 'Edited' WHEN SED.IsUD=0 AND SED.IsDD=1 THEN 'Deleted' ELSE 'Added' END AS [Status]
				,S.name Section,P.Name Product,SED.Quantity,SED.NewQuantity,SED.UnitRate Rate,SED.Discount DiscountTotal
				,(SED.UnitRate*SED.Quantity) Amount
				,CASE WHEN @R_VatEnabled=1 THEN SED.Tax ELSE 0.00 END AS VatTotal
				,CASE WHEN @R_VatEnabled=1 THEN 0.00 ELSE SED.Tax/2 END AS CGST
				,CASE WHEN @R_VatEnabled=1 THEN 0.00 ELSE SED.Tax/2 END AS SGST
				,CASE WHEN @R_VatEnabled=1 THEN 0.00 ELSE SED.Tax END AS TaxTotal
				,(SED.unitRate*(CASE WHEN SED.NewQuantity>0 THEN SED.NewQuantity ELSE SED.Quantity END))-SED.Discount+SED.Tax+ISNULL(DelAmount+ContAmount+OtherAmount,0) NetTotal
				,SED.EditType,SED.NewUnitRate,SM.[No]
			FROM R_SalesMaster SM
			INNER JOIN R_SalesED SED ON SED.MasterID=SM.[GuID]
			INNER JOIN restaurant.Product P ON P.[GuID]=SED.ProductID
			INNER JOIN R_User U ON U.GuID=SED.UUserGuid
			INNER JOIN restaurant.Section S ON S.[GUID]=SM.SectionID
			INNER JOIN R_Counter C ON SM.CounterID=C.[GuID]
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID=SM.[GuID] AND MSA.Merged=0
			WHERE SM.Deleted=0 AND SM.Cancelled=0
			AND SM.Date BETWEEN @R_FromDate AND @R_ToDate
			AND (S.[GuID]=@R_SectionID OR @R_SectionID IS NULL)
			AND (C.[GuID]=@R_CounterID OR @R_CounterID IS NULL)
			AND (U.[GuID]=@R_UserID OR @R_UserID IS NULL)
			AND (EditType IS NOT NULL) AND (EditType!='')
			AND (SM.BranchID=@R_BranchID OR @R_BranchID IS NULL)
			UNION ALL
			SELECT SM.TransactionDate,SM.Date AS BillDate,SM.BillNo,SED.UDate EditDate,SED.UDate EditTime,U.UserName [User]
				,CASE WHEN SED.IsUD=1 AND SED.IsDD=0 THEN 'Edited' WHEN SED.IsUD=0 AND SED.IsDD=1 THEN 'Deleted' ELSE 'Added' END AS [Status]
				,S.name Section,P.Name Product,SED.Quantity,SED.NewQuantity,SED.UnitRate Rate,SED.Discount DiscountTotal
				,(SED.UnitRate*SED.Quantity) Amount
				,CASE WHEN @R_VatEnabled=1 THEN SED.Tax ELSE 0.00 END AS VatTotal
				,CASE WHEN @R_VatEnabled=1 THEN 0.00 ELSE SED.Tax/2 END AS CGST
				,CASE WHEN @R_VatEnabled=1 THEN 0.00 ELSE SED.Tax/2 END AS SGST
				,CASE WHEN @R_VatEnabled=1 THEN 0.00 ELSE SED.Tax END AS TaxTotal
				,(SED.unitRate*(CASE WHEN SED.NewQuantity>0 THEN SED.NewQuantity ELSE SED.Quantity END))-SED.Discount+SED.Tax+ISNULL(DelAmount+ContAmount+OtherAmount,0) NetTotal
				,SED.EditType,SED.NewUnitRate,SM.[No]
			FROM R_SalesTempMaster SM
			INNER JOIN R_SalesTempED SED ON SED.MasterID=SM.[GuID]
			INNER JOIN restaurant.Product P ON P.[GuID]=SED.ProductID
			INNER JOIN R_User U ON U.GuID=SED.UUserGuid
			INNER JOIN restaurant.Section S ON S.[GUID]=SM.SectionID
			INNER JOIN R_Counter C ON SM.CounterID=C.[GuID]
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID=SM.[GuID] AND MSA.Merged=0
			WHERE SM.Deleted=0 AND SM.Cancelled=0
			AND SM.Date BETWEEN @R_FromDate AND @R_ToDate
			AND (S.[GuID]=@R_SectionID OR @R_SectionID IS NULL)
			AND (C.[GuID]=@R_CounterID OR @R_CounterID IS NULL)
			AND (U.[GuID]=@R_UserID OR @R_UserID IS NULL)
			AND (EditType IS NOT NULL) AND (EditType!='')
			AND (SM.BranchID=@R_BranchID OR @R_BranchID IS NULL)
		) AS T
	) AS SalesLogReport WHERE ([Status]=@R_Status OR @R_Status IS NULL) AND (EditType=@R_EditType OR @R_EditType IS NULL);

	SELECT COUNT(*) AS SalesLogCount INTO #SalesLogReportCount FROM #SalesLogReport;

	IF @R_PageSize=-1
	BEGIN
		IF @R_SortingColumn IS NULL
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT SalesLogCount FROM #SalesLogReportCount)[RowCount] FROM #SalesLogReport ORDER BY TransactionDate '+@R_SortingDirection+',Section '+@R_SortingDirection+',[No] '+@R_SortingDirection;
			EXEC(@SortingCmd);
		END
		ELSE
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT SalesLogCount FROM #SalesLogReportCount)[RowCount],[No] AS [No1],TransactionDate AS TransactionDate1,Section AS Section1 FROM #SalesLogReport ORDER BY '+CASE WHEN @R_SortingColumn='[EditTime]' THEN 'CONVERT(TIME,[EditTime])' ELSE @R_SortingColumn END+' '+@R_SortingDirection+',TransactionDate1 asc,Section1 asc,[No1] asc';
			EXEC(@SortingCmd);
		END
	END
	ELSE
	BEGIN
		IF @R_SortingColumn IS NULL
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT SalesLogCount FROM #SalesLogReportCount)[RowCount] FROM #SalesLogReport ORDER BY TransactionDate '+@R_SortingDirection+',Section '+@R_SortingDirection+',[No] '+@R_SortingDirection+' OFFSET ('+CAST(@R_PageNumber-1 AS NVARCHAR(MAX))+')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS FETCH NEXT '+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS ONLY';
			EXEC(@SortingCmd);
		END
		ELSE
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT SalesLogCount FROM #SalesLogReportCount)[RowCount],[No] AS [No1],TransactionDate AS TransactionDate1,Section AS Section1 FROM #SalesLogReport ORDER BY '+CASE WHEN @R_SortingColumn='[EditTime]' THEN 'CONVERT(TIME,[EditTime])' ELSE @R_SortingColumn END+' '+@R_SortingDirection+',TransactionDate1 asc,Section1 asc,[No1] asc OFFSET ('+CAST(@R_PageNumber-1 AS NVARCHAR(MAX))+')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS FETCH NEXT '+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS ONLY';
			EXEC(@SortingCmd);
		END
	END

	SELECT ''AS TransactionDate,''AS [BillDate],''AS BillNo,''AS EditDate,''AS EditTime,''AS [User],''AS [Status],''AS Section,''AS Product,
		SUM(Quantity)Quantity,SUM(NewQuantity)NewQuantity,SUM(Rate)Rate,SUM(DiscountTotal)DiscountTotal,SUM(Amount)Amount,
		SUM(VatTotal)VatTotal,SUM(CGST)CGST,SUM(SGST)SGST,SUM(TaxAmount)TaxAmount,SUM(NetTotal)NetTotal,''AS EditType,SUM(NewUnitRate)NewUnitRate
	FROM #SalesLogReport;

	IF Object_id('TempDB.dbo.#SalesLogReport') IS NOT NULL DROP TABLE #SalesLogReport;
	IF Object_id('TempDB.dbo.#SalesLogReportCount') IS NOT NULL DROP TABLE #SalesLogReportCount;
	SET NOCOUNT OFF;
END
GO
PRINT 'Created or altered SP Report_SalesLogReportPaging.';
GO

-- SP: Report_CustomerCreditDetailsPaging (File 1)
CREATE OR ALTER PROCEDURE [restaurant].[Report_CustomerCreditDetailsPaging]
(
 @FromDate          DATE              = NULL,
 @ToDate            DATE              = NULL,
 @CustomerId        uniqueidentifier  = NULL,
 @PageNumber        INT               = NULL,
 @PageSize          INT               = NULL,
 @SortingColumn     VARCHAR(MAX)      = NULL,
 @SortingDirection  VARCHAR(MAX)      = NULL,
 @BranchID          VARCHAR(MAX)      = NULL
)
AS
BEGIN
	DECLARE
	@R_FromDate        DATE             = @FromDate,
	@R_ToDate          DATE             = @ToDate,
	@R_CustomerId      uniqueidentifier = @CustomerId,
    @R_PageNumber      INT              = @PageNumber,
    @R_PageSize        INT              = @PageSize,
    @R_SortingColumn   VARCHAR(MAX)     = @SortingColumn,
    @R_SortingDirection VARCHAR(MAX)    = @SortingDirection,
	@R_BranchID        VARCHAR(MAX)     = @BranchID;

	DECLARE @SortingCmd VARCHAR(MAX);
	SET ARITHABORT ON; SET XACT_ABORT ON; SET NOCOUNT ON;
	SET @R_ToDate = DATEADD(D, 1, @R_ToDate);

	IF Object_id('TempDB.dbo.#CustomerCreditDetails') IS NOT NULL DROP TABLE #CustomerCreditDetails;
	IF Object_id('TempDB.dbo.#CustomerCreditDetailsCount') IS NOT NULL DROP TABLE #CustomerCreditDetailsCount;

	SELECT * INTO #CustomerCreditDetails FROM (
		SELECT CCD.Date, CCD.BillNo, CCD.RefNo, CCD.Amount, CM.Name AS Customer,
			SEC.Name AS SectionName,
			CAST(SUBSTRING(CCD.BillNo,PATINDEX('%[0-9]%',CCD.BillNo),LEN(CCD.BillNo)) AS INT) AS [No]
		FROM R_CustomerCreditDetail CCD
		INNER JOIN R_Customer CM ON CM.[GuID]=CCD.CustomerID
		LEFT JOIN R_SalesMaster SM ON SM.GuID=CCD.BillID
		LEFT JOIN R_SalesTempMaster STM ON STM.GuID=CCD.BillID
		LEFT JOIN restaurant.Section SEC ON SEC.GuID=COALESCE(SM.SectionID,STM.SectionID)
		WHERE (CCD.CustomerID=@R_CustomerId OR @R_CustomerId IS NULL)
		AND (CCD.Date>=@R_FromDate OR @R_FromDate IS NULL)
		AND (CCD.Date<@R_ToDate OR @R_ToDate IS NULL)
		AND (CM.BranchID=@R_BranchID OR @R_BranchID IS NULL)
		AND CCD.Module='Sales'
	) AS CustomerCreditDetails;

	SELECT COUNT(*) AS CustomerCreditDetailsCount INTO #CustomerCreditDetailsCount FROM #CustomerCreditDetails;

	IF @R_PageSize=-1
	BEGIN
		IF @R_SortingColumn IS NULL
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT CustomerCreditDetailsCount FROM #CustomerCreditDetailsCount)[RowCount] FROM #CustomerCreditDetails ORDER BY Date '+@R_SortingDirection;
			EXEC(@SortingCmd);
		END
		ELSE
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT CustomerCreditDetailsCount FROM #CustomerCreditDetailsCount)[RowCount],Date as Date1 FROM #CustomerCreditDetails ORDER BY '+@R_SortingColumn+' '+@R_SortingDirection+',Date1 asc';
			EXEC(@SortingCmd);
		END
	END
	ELSE
	BEGIN
		IF @R_SortingColumn IS NULL
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT CustomerCreditDetailsCount FROM #CustomerCreditDetailsCount)[RowCount] FROM #CustomerCreditDetails ORDER BY Date '+@R_SortingDirection+' OFFSET ('+CAST(@R_PageNumber-1 AS NVARCHAR(MAX))+')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS FETCH NEXT '+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS ONLY';
			EXEC(@SortingCmd);
		END
		ELSE
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT CustomerCreditDetailsCount FROM #CustomerCreditDetailsCount)[RowCount],Date as Date1 FROM #CustomerCreditDetails ORDER BY '+@R_SortingColumn+' '+@R_SortingDirection+',Date1 asc OFFSET ('+CAST(@R_PageNumber-1 AS NVARCHAR(MAX))+')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS FETCH NEXT '+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS ONLY';
			EXEC(@SortingCmd);
		END
	END

	SELECT ''AS Date,''AS BillNo,''AS RefNo,SUM(Amount)Amount,''AS Customer FROM #CustomerCreditDetails;

	IF Object_id('TempDB.dbo.#CustomerCreditDetails') IS NOT NULL DROP TABLE #CustomerCreditDetails;
	IF Object_id('TempDB.dbo.#CustomerCreditDetailsCount') IS NOT NULL DROP TABLE #CustomerCreditDetailsCount;
	SET NOCOUNT OFF;
END
GO
PRINT 'Created or altered SP Report_CustomerCreditDetailsPaging.';
GO

-- SP: Report_TimeBasedSalesDetailPaging (File 2 only)
CREATE OR ALTER PROCEDURE [restaurant].[Report_TimeBasedSalesDetailPaging]
(
 @IsDayClosed        INT          = NULL,
 @CounterID          VARCHAR(MAX) = NULL,
 @SectionID          VARCHAR(MAX) = NULL,
 @UserID             VARCHAR(MAX) = NULL,
 @PaymentType        VARCHAR(MAX) = NULL,
 @PaymentCardID      VARCHAR(MAX) = NULL,
 @FromDate           DATE         = NULL,
 @ToDate             DATE         = NULL,
 @StatusType         VARCHAR(MAX) = NULL,
 @PageNumber         INT          = NULL,
 @PageSize           INT          = NULL,
 @SortingColumn      VARCHAR(MAX) = NULL,
 @SortingDirection   VARCHAR(MAX) = NULL,
 @BranchID           VARCHAR(MAX) = NULL
)
AS
BEGIN
	DECLARE
	     @R_IsDayClosed      INT             = @IsDayClosed,
		 @R_CounterID        VARCHAR(MAX)    = @CounterID,
		 @R_SectionID        VARCHAR(MAX)    = @SectionID,
		 @R_UserID           VARCHAR(MAX)    = @UserID,
		 @R_PaymentType      VARCHAR(MAX)    = @PaymentType,
		 @R_PaymentCardID    VARCHAR(MAX)    = @PaymentCardID,
		 @R_FromDate         DATE            = @FromDate,
		 @R_ToDate           DATE            = @ToDate,
		 @R_StatusType       VARCHAR(MAX)    = @StatusType,
         @VatEnabled         BIT = (Select CASE WHEN Value='True' THEN 1 ELSE 0 END AS Value from R_Settings where [Key]='IsVATEnabled'),
		 @R_PageNumber       INT             = @PageNumber,
         @R_PageSize         INT             = @PageSize,
         @R_SortingColumn    VARCHAR(MAX)    = @SortingColumn,
         @R_SortingDirection VARCHAR(MAX)    = @SortingDirection,
		 @R_BranchID         VARCHAR(MAX)    = @BranchID;

	DECLARE @SortingCmd VARCHAR(MAX);
	SET ARITHABORT ON; SET XACT_ABORT ON; SET NOCOUNT ON;
	SET @R_ToDate = DATEADD(D, 1, @R_ToDate);

	IF Object_id('TempDB.dbo.#SalesReport') IS NOT NULL DROP TABLE #SalesReport;
	IF Object_id('TempDB.dbo.#SalesReportCount') IS NOT NULL DROP TABLE #SalesReportCount;

	SELECT * INTO #SalesReport FROM (
		SELECT SM.[No],SM.BillNo,SM.TransactionDate,SM.BillTime AS BillDate,
			S.Name AS Section,B.Name AS Branch,U.Name AS [User],ST.Name AS TableName,
			ZM.Name AS ZoneName,SD.ChairNo,P.Name as PRODUCTNAME,C.Name as CATEGORY,CM.Name as CATEGORYGROUP
		FROM R_SalesMaster SM
			LEFT JOIN restaurant.Section S ON S.[GuID]=SM.SectionID
			LEFT JOIN R_Branch B ON B.[GuID]=SM.BranchID
			LEFT JOIN R_User U ON U.[GuID]=SM.WaiterID
			LEFT JOIN R_SectionTables ST ON ST.GUID=SM.TableID
			LEFT JOIN restaurant.ZoneMaster ZM ON ZM.GuID=S.ZoneGuID
			LEFT JOIN R_SalesDetail SD ON SD.MasterID=SM.GuID
			LEFT JOIN restaurant.Product P On SD.ProductID=P.GuID
			LEFT JOIN restaurant.ProductPriceDetail PP ON PP.MasterID=P.GuID
			LEFT JOIN R_Category C On PP.CategoryID=C.GuID
			LEFT JOIN restaurant.CategoryMaster CM On CM.GuID=C.CategoryMasterGuID
		WHERE (SM.TransactionDate>=@R_FromDate OR @R_FromDate IS NULL) AND (SM.TransactionDate<@R_ToDate OR @R_ToDate IS NULL)
			AND (SM.BranchID=@R_BranchID OR @R_BranchID IS NULL)
		UNION ALL
		SELECT SM.[No],SM.BillNo,SM.TransactionDate,SM.BillTime AS BillDate,
			S.Name AS Section,B.Name AS Branch,U.Name AS [User],ST.Name AS TableName,
			ZM.Name AS ZoneName,SD.ChairNo,P.Name as PRODUCTNAME,C.Name as CATEGORY,CM.Name as CATEGORYGROUP
		FROM R_SalesTempMaster SM
			LEFT JOIN restaurant.Section S ON S.[GuID]=SM.SectionID
			LEFT JOIN R_Branch B ON B.[GuID]=SM.BranchID
			LEFT JOIN R_User U ON U.[GuID]=SM.WaiterID
			LEFT JOIN R_SectionTables ST ON ST.GUID=SM.TableID
			LEFT JOIN restaurant.ZoneMaster ZM ON ZM.GuID=S.ZoneGuID
			LEFT JOIN R_SalesTempDetail SD ON SD.MasterID=SM.GuID
			LEFT JOIN restaurant.Product P On SD.ProductID=P.GuID
			LEFT JOIN restaurant.ProductPriceDetail PP ON PP.MasterID=P.GuID
			LEFT JOIN R_Category C On PP.CategoryID=C.GuID
			LEFT JOIN restaurant.CategoryMaster CM On CM.GuID=C.CategoryMasterGuID
		WHERE (SM.TransactionDate>=@R_FromDate OR @R_FromDate IS NULL) AND (SM.TransactionDate<@R_ToDate OR @R_ToDate IS NULL)
			AND (SM.BranchID=@R_BranchID OR @R_BranchID IS NULL)
	) AS SalesDetail;

	SELECT COUNT(*) AS SalesCount INTO #SalesReportCount FROM #SalesReport;

	IF @PageSize=-1
	BEGIN
		IF @R_SortingColumn IS NULL
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT SalesCount FROM #SalesReportCount)[RowCount] FROM #SalesReport ORDER BY TransactionDate '+@R_SortingDirection+',Section '+@R_SortingDirection+',[BillDate] '+@R_SortingDirection;
			EXEC(@SortingCmd);
		END
		ELSE
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT SalesCount FROM #SalesReportCount)[RowCount],[BillNo] AS [No1],TransactionDate AS TransactionDate1,Section AS Section1 FROM #SalesReport ORDER BY '+@R_SortingColumn+' '+@R_SortingDirection+',TransactionDate1 asc,Section1 asc,[No1] asc';
			EXEC(@SortingCmd);
		END
	END
	ELSE
	BEGIN
		IF @R_SortingColumn IS NULL
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT SalesCount FROM #SalesReportCount)[RowCount] FROM #SalesReport ORDER BY TransactionDate '+@R_SortingDirection+',Section '+@R_SortingDirection+',[BillNo] '+@R_SortingDirection+' OFFSET ('+CAST(@R_PageNumber-1 AS NVARCHAR(MAX))+')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS FETCH NEXT '+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS ONLY';
			EXEC(@SortingCmd);
		END
		ELSE
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT SalesCount FROM #SalesReportCount)[RowCount],[BillNo] AS [No1],TransactionDate AS TransactionDate1,Section AS Section1 FROM #SalesReport ORDER BY '+@R_SortingColumn+' '+@R_SortingDirection+',TransactionDate1 asc,Section1 asc,[No1] asc OFFSET ('+CAST(@R_PageNumber-1 AS NVARCHAR(MAX))+')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS FETCH NEXT '+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS ONLY';
			EXEC(@SortingCmd);
		END
	END

	SELECT ''AS [No],''AS BillNo,''AS TransactionDate,''AS BillDate,'Cash' AS PaymentType,'Cash' AS PaymenCardType,
		0 AS NetTotal,''AS [Counter],''AS Section,''AS [Branch],''AS [User],'Completed' AS [SalesStatus],''AS Reason,''AS CardNo,''AS Customer
	FROM #SalesReport;

	IF Object_id('TempDB.dbo.#SalesReport') IS NOT NULL DROP TABLE #SalesReport;
	IF Object_id('TempDB.dbo.#SalesReportCount') IS NOT NULL DROP TABLE #SalesReportCount;
	SET NOCOUNT OFF;
END
GO
PRINT 'Created or altered SP Report_TimeBasedSalesDetailPaging.';
GO

-- ============================================================
-- SECTION G: DROP OBSOLETE/UNUSED OBJECTS
-- ============================================================
PRINT 'Section G: Dropping obsolete/unused objects...';
GO

-- Drop obsolete tables
IF OBJECT_ID('dbo.R_Product1', 'U') IS NOT NULL DROP TABLE dbo.R_Product1;
IF OBJECT_ID('dbo.R_Product2', 'U') IS NOT NULL DROP TABLE dbo.R_Product2;
IF OBJECT_ID('dbo.R_Product20251218', 'U') IS NOT NULL DROP TABLE dbo.R_Product20251218;
IF OBJECT_ID('dbo.R_ProductDetail1', 'U') IS NOT NULL DROP TABLE dbo.R_ProductDetail1;
IF OBJECT_ID('dbo.R_SectionKOTPrinter1', 'U') IS NOT NULL DROP TABLE dbo.R_SectionKOTPrinter1;
GO

-- Drop obsolete stored procedures
IF OBJECT_ID('dbo.ClearDb_1', 'P') IS NOT NULL DROP PROCEDURE dbo.ClearDb_1;
IF OBJECT_ID('dbo.GetCreditorsReportBefrUpt', 'P') IS NOT NULL DROP PROCEDURE dbo.GetCreditorsReportBefrUpt;
IF OBJECT_ID('dbo.GetCreditorsReportTest', 'P') IS NOT NULL DROP PROCEDURE dbo.GetCreditorsReportTest;
IF OBJECT_ID('dbo.GetDebtorsReportBefUp', 'P') IS NOT NULL DROP PROCEDURE dbo.GetDebtorsReportBefUp;
IF OBJECT_ID('dbo.GetDebtorsReportOld', 'P') IS NOT NULL DROP PROCEDURE dbo.GetDebtorsReportOld;
IF OBJECT_ID('dbo.GetLedgerSam', 'P') IS NOT NULL DROP PROCEDURE dbo.GetLedgerSam;
IF OBJECT_ID('dbo.GetSalesDetailReportNew', 'P') IS NOT NULL DROP PROCEDURE dbo.GetSalesDetailReportNew;
IF OBJECT_ID('dbo.GetSalesDetailReportNew1', 'P') IS NOT NULL DROP PROCEDURE dbo.GetSalesDetailReportNew1;
IF OBJECT_ID('dbo.GetSalesMasterReportTest', 'P') IS NOT NULL DROP PROCEDURE dbo.GetSalesMasterReportTest;
IF OBJECT_ID('dbo.GetTrialBalanceOld', 'P') IS NOT NULL DROP PROCEDURE dbo.GetTrialBalanceOld;
IF OBJECT_ID('dbo.TESTPROCEDURE', 'P') IS NOT NULL DROP PROCEDURE dbo.TESTPROCEDURE;
IF OBJECT_ID('restaurant.BillPaymentReceiptInsertUpdate', 'P') IS NOT NULL DROP PROCEDURE restaurant.BillPaymentReceiptInsertUpdate;
IF OBJECT_ID('restaurant.dailyClose_getByDate', 'P') IS NOT NULL DROP PROCEDURE restaurant.dailyClose_getByDate;
IF OBJECT_ID('restaurant.user_getByUsernameAndPassword', 'P') IS NOT NULL DROP PROCEDURE restaurant.user_getByUsernameAndPassword;
IF OBJECT_ID('restaurant.PromoPoduct_Delete', 'P') IS NOT NULL DROP PROCEDURE restaurant.PromoPoduct_Delete;
GO

-- Drop obsolete UDTs
IF EXISTS (SELECT 1 FROM sys.types t INNER JOIN sys.schemas s ON t.schema_id=s.schema_id WHERE t.name='InvSalesDetail_UDT' AND s.name='restaurant' AND t.is_table_type=1)
    DROP TYPE [restaurant].[InvSalesDetail_UDT];
IF EXISTS (SELECT 1 FROM sys.types t INNER JOIN sys.schemas s ON t.schema_id=s.schema_id WHERE t.name='BillPaymentReceiptDetail_UDT' AND s.name='restaurant' AND t.is_table_type=1)
    DROP TYPE [restaurant].[BillPaymentReceiptDetail_UDT];
IF EXISTS (SELECT 1 FROM sys.types t INNER JOIN sys.schemas s ON t.schema_id=s.schema_id WHERE t.name='Sync_Product_UDT1' AND s.name='restaurant' AND t.is_table_type=1)
    DROP TYPE [restaurant].[Sync_Product_UDT1];
IF EXISTS (SELECT 1 FROM sys.types t INNER JOIN sys.schemas s ON t.schema_id=s.schema_id WHERE t.name='Sync_SalesLog_UDT1' AND s.name='restaurant' AND t.is_table_type=1)
    DROP TYPE [restaurant].[Sync_SalesLog_UDT1];
IF EXISTS (SELECT 1 FROM sys.types t INNER JOIN sys.schemas s ON t.schema_id=s.schema_id WHERE t.name='Sync_Section_UDT1' AND s.name='restaurant' AND t.is_table_type=1)
    DROP TYPE [restaurant].[Sync_Section_UDT1];
GO

-- ============================================================
-- SP: GetSupplierPayableReport
-- Returns outstanding purchase bills as of a given date,
-- with ageing and credit period calculations.
--
-- Tables used (verify against your actual schema):
--   restaurant.Purchase : purchase invoice master  (GuID, EntryDate, SupplierID, EntryNumber, NetTotal, BranchID, PaymentType)
--   BillPaymentDetail   : bill payments per invoice (PurchaseMasterID, Amount, Discount)
--   Supplier            : supplier master           (GuID, Name, CreditDays, Mobile)
--
-- Ageing      = DATEDIFF(day, EntryDate, @AsOfDate)
-- Balance     = NetTotal - TotalPaid (bills with Balance > 0 only)
-- CreditPeriod= Supplier.CreditDays
-- ============================================================
CREATE OR ALTER PROCEDURE [dbo].[GetSupplierPayableReport]
(
    @AsOfDate           DATE,
    @SupplierGuid       VARCHAR(50)  = '00000000-0000-0000-0000-000000000000',
    @AgeingPeriod       VARCHAR(20)  = 'All',   -- All | Above120 | 90-120 | 60-90 | 30-60 | 0-30
    @CreditPeriodFilter VARCHAR(10)  = 'All',   -- All | Above | Within
    @location           VARCHAR(50)  = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    WITH PaymentTotals AS (
        SELECT
            PurchaseMasterID,
            SUM(ISNULL(Amount, 0))   AS TotalPaid,
            SUM(ISNULL(Discount, 0)) AS TotalDiscount
        FROM BillPaymentDetail
        WHERE PurchaseMasterID IS NOT NULL
          AND PurchaseMasterID <> '00000000-0000-0000-0000-000000000000'
        GROUP BY PurchaseMasterID
    ),
    BillData AS (
        SELECT
            PM.EntryDate                                                     AS Date,
            S.Name                                                           AS VendorName,
            PM.EntryNumber                                                   AS BillNo,
            PM.NetTotal                                                      AS BillAmount,
            ISNULL(PT.TotalPaid, 0) + ISNULL(PT.TotalDiscount, 0)          AS PaidAmount,
            PM.NetTotal - (ISNULL(PT.TotalPaid, 0) + ISNULL(PT.TotalDiscount, 0)) AS Balance,
            DATEDIFF(DAY, PM.EntryDate, @AsOfDate)                          AS Ageing,
            ISNULL(S.CreditDays, 0)                                         AS CreditPeriod
        FROM restaurant.Purchase PM
        INNER JOIN Supplier S ON S.GuID = PM.SupplierID
        LEFT  JOIN PaymentTotals PT ON PT.PurchaseMasterID = PM.GuID
        WHERE PM.EntryDate <= @AsOfDate
          AND (PM.BranchID = @location OR @location IS NULL)
          AND (PM.SupplierID = @SupplierGuid OR @SupplierGuid = '00000000-0000-0000-0000-000000000000')
    )
    SELECT
        Date, VendorName, BillNo, BillAmount, PaidAmount, Balance, Ageing, CreditPeriod
    FROM BillData
    WHERE Balance > 0
      AND (
            @AgeingPeriod = 'All'
            OR (@AgeingPeriod = 'Above120' AND Ageing > 120)
            OR (@AgeingPeriod = '90-120'   AND Ageing >= 90  AND Ageing <= 120)
            OR (@AgeingPeriod = '60-90'    AND Ageing >= 60  AND Ageing < 90)
            OR (@AgeingPeriod = '30-60'    AND Ageing >= 30  AND Ageing < 60)
            OR (@AgeingPeriod = '0-30'     AND Ageing >= 0   AND Ageing < 30)
          )
      AND (
            @CreditPeriodFilter = 'All'
            OR (@CreditPeriodFilter = 'Above'  AND Ageing > CreditPeriod)
            OR (@CreditPeriodFilter = 'Within' AND Ageing <= CreditPeriod)
          )
    ORDER BY VendorName, Date;
END;
GO

PRINT 'Created SP GetSupplierPayableReport.';
GO

-- ============================================================
-- SP: GetCustomerReceivableReport
-- Returns outstanding customer credit bills as of a given date,
-- with ageing and credit period calculations.
--
-- Sources (UNIONed):
--   restaurant.Inv_SalesMaster : web app invoices   (GUID, INVDATE, CUSTOMER, EntryNumber, NetTotal, PaymentMode=3 for Credit, IsDeleted, BranchID)
--   R_SalesMaster              : WinApp active bills (GUID, TransactionDate, CustomerID, BillNo, CustomerCredit, Deleted, Cancelled, BranchID)
--   R_SalesTempMaster          : WinApp post-dayclose bills (same structure as R_SalesMaster)
--   BillReceiptDetail          : receipts per bill   (SalesMasterID, Amount, Discount)
--   R_Customer                 : customer master     (GuID, Name, CreditDays)
--
-- Ageing      = DATEDIFF(day, SaleDate, @AsOfDate)
-- Balance     = CreditAmount - TotalReceived (bills with Balance > 0 only)
-- CreditPeriod= R_Customer.CreditDays
-- ============================================================
CREATE OR ALTER PROCEDURE [dbo].[GetCustomerReceivableReport]
(
    @AsOfDate           DATE,
    @CustomerGuid       VARCHAR(50)  = '00000000-0000-0000-0000-000000000000',
    @AgeingPeriod       VARCHAR(20)  = 'All',   -- All | Above120 | 90-120 | 60-90 | 30-60 | 0-30
    @CreditPeriodFilter VARCHAR(10)  = 'All',   -- All | Above | Within
    @location           VARCHAR(50)  = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    WITH ReceiptTotals AS (
        SELECT
            SalesMasterID,
            SUM(ISNULL(Amount, 0))   AS TotalReceived,
            SUM(ISNULL(Discount, 0)) AS TotalDiscount
        FROM BillReceiptDetail
        WHERE SalesMasterID IS NOT NULL
          AND SalesMasterID <> '00000000-0000-0000-0000-000000000000'
        GROUP BY SalesMasterID
    ),
    AllCreditSales AS (
        -- Web app invoices (restaurant.Inv_SalesMaster) - PaymentMode 3 = Credit
        SELECT
            SM.GUID         AS GUID,
            SM.INVDATE      AS SaleDate,
            SM.EntryNumber  AS BillNo,
            SM.NetTotal     AS CreditAmount,
            SM.CUSTOMER     AS CustomerID,
            SM.BranchID     AS BranchID
        FROM restaurant.Inv_SalesMaster SM
        WHERE SM.PaymentMode = 3
          AND ISNULL(SM.Deleted, 0) = 0

        UNION ALL

        -- WinApp active bills (R_SalesMaster)
        SELECT
            SM.GUID             AS GUID,
            SM.TransactionDate  AS SaleDate,
            SM.BillNo           AS BillNo,
            SM.CustomerCredit   AS CreditAmount,
            SM.CustomerID       AS CustomerID,
            SM.BranchID         AS BranchID
        FROM R_SalesMaster SM
        WHERE SM.CustomerCredit > 0
          AND SM.Deleted = 0
          AND SM.Cancelled = 0

        UNION ALL

        -- WinApp post-dayclose bills (R_SalesTempMaster)
        SELECT
            SM.GUID             AS GUID,
            SM.TransactionDate  AS SaleDate,
            SM.BillNo           AS BillNo,
            SM.CustomerCredit   AS CreditAmount,
            SM.CustomerID       AS CustomerID,
            SM.BranchID         AS BranchID
        FROM R_SalesTempMaster SM
        WHERE SM.CustomerCredit > 0
          AND SM.Deleted = 0
          AND SM.Cancelled = 0
    ),
    BillData AS (
        SELECT
            CAST(S.SaleDate AS DATE)                                               AS Date,
            C.Name                                                                 AS CustomerName,
            S.BillNo                                                               AS BillNo,
            S.CreditAmount                                                         AS BillAmount,
            ISNULL(RT.TotalReceived, 0) + ISNULL(RT.TotalDiscount, 0)            AS PaidAmount,
            S.CreditAmount - (ISNULL(RT.TotalReceived, 0) + ISNULL(RT.TotalDiscount, 0)) AS Balance,
            DATEDIFF(DAY, S.SaleDate, @AsOfDate)                                  AS Ageing,
            ISNULL(C.CreditDays, 0)                                               AS CreditPeriod
        FROM AllCreditSales S
        INNER JOIN R_Customer C ON C.GuID = S.CustomerID
        LEFT  JOIN ReceiptTotals RT ON RT.SalesMasterID = S.GUID
        WHERE S.SaleDate <= @AsOfDate
          AND (S.BranchID = @location OR @location IS NULL)
          AND (S.CustomerID = @CustomerGuid OR @CustomerGuid = '00000000-0000-0000-0000-000000000000')
    )
    SELECT
        Date, CustomerName, BillNo, BillAmount, PaidAmount, Balance, Ageing, CreditPeriod
    FROM BillData
    WHERE Balance > 0
      AND (
            @AgeingPeriod = 'All'
            OR (@AgeingPeriod = 'Above120' AND Ageing > 120)
            OR (@AgeingPeriod = '90-120'   AND Ageing >= 90  AND Ageing <= 120)
            OR (@AgeingPeriod = '60-90'    AND Ageing >= 60  AND Ageing < 90)
            OR (@AgeingPeriod = '30-60'    AND Ageing >= 30  AND Ageing < 60)
            OR (@AgeingPeriod = '0-30'     AND Ageing >= 0   AND Ageing < 30)
          )
      AND (
            @CreditPeriodFilter = 'All'
            OR (@CreditPeriodFilter = 'Above'  AND Ageing > CreditPeriod)
            OR (@CreditPeriodFilter = 'Within' AND Ageing <= CreditPeriod)
          )
    ORDER BY CustomerName, Date;
END;
GO

PRINT 'Created SP GetCustomerReceivableReport.';
GO

PRINT 'Database update completed successfully.';
GO

-- ============================================================
-- SECTION H: POSACC — POS Accounts Posting + Accounts Sync
-- Implementation Plan Date: 2026-06-26
-- *** Run on ALL databases (Windows local DB and Web DB) ***
-- All blocks are idempotent — safe to run multiple times.
-- ============================================================

PRINT 'Section H: POSACC — POS Accounts Posting + Accounts Sync...';
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'restaurant')
    EXEC('CREATE SCHEMA restaurant');
GO

-- ============================================================
-- H1: R_DailyClosingMaster — Add GL tracking columns
-- (Auto-skipped if R_DailyClosingMaster does not exist in this DB)
-- ============================================================
PRINT 'H1: Adding GL tracking columns to R_DailyClosingMaster...';
GO

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'R_DailyClosingMaster')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = 'R_DailyClosingMaster' AND COLUMN_NAME = 'IsPostedToGL')
        ALTER TABLE dbo.R_DailyClosingMaster ADD IsPostedToGL BIT NOT NULL DEFAULT 0;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = 'R_DailyClosingMaster' AND COLUMN_NAME = 'GLVoucherNo')
        ALTER TABLE dbo.R_DailyClosingMaster ADD GLVoucherNo INT NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = 'R_DailyClosingMaster' AND COLUMN_NAME = 'GLVoucherGUID')
        ALTER TABLE dbo.R_DailyClosingMaster ADD GLVoucherGUID UNIQUEIDENTIFIER NULL;

    PRINT 'H1: GL tracking columns processed for R_DailyClosingMaster.';
END
ELSE
    PRINT 'H1: R_DailyClosingMaster not in this DB — skipped.';
GO

PRINT 'H1 complete.';
GO

-- ============================================================
-- H2: R_Ledger — Fix IsDebit flags + add missing ledgers
-- ============================================================
PRINT 'H2: Fixing R_Ledger IsDebit flags and adding missing ledgers...';
GO

-- Fix IsDebit = 1 (Asset / Expense nature ledgers)
UPDATE dbo.R_Ledger SET IsDebit = 1 WHERE Name IN (
    'CASH ACCOUNT', 'DEFAULT BANK ACCOUNT', 'INPUT TAX',
    'PURCHASE', 'DISCOUNT PAID', 'CASH DISCOUNTS', 'OVERHEAD EXPENSES', 'SALES ADDITION'
);
PRINT 'Updated IsDebit=1 for asset/expense ledgers.';
GO

-- Fix IsDebit = 0 (Liability / Income nature ledgers)
UPDATE dbo.R_Ledger SET IsDebit = 0 WHERE Name IN (
    'SALES', 'SALES RETURN', 'PURCHASE RETURN', 'OUTPUT TAX', 'DISCOUNT RECEIVED', 'ROUND OFF'
);
PRINT 'Updated IsDebit=0 for liability/income ledgers.';
GO

-- Move OUTPUT TAX into DUTIES & TAXES subgroup
UPDATE dbo.R_Ledger
SET GroupID = (SELECT GuID FROM dbo.R_Group WHERE Name = 'DUTIES & TAXES')
WHERE Name = 'OUTPUT TAX';
PRINT 'Moved OUTPUT TAX into DUTIES & TAXES group.';
GO

-- Add CUSTOMER RECEIVABLES under SUNDRY DEBTORS
IF NOT EXISTS (SELECT 1 FROM dbo.R_Ledger WHERE Name = 'CUSTOMER RECEIVABLES')
BEGIN
    INSERT INTO dbo.R_Ledger (Name, GroupID, IsDebit, Amount, CompanyID, IsFixed, GuID)
    VALUES (
        'CUSTOMER RECEIVABLES',
        (SELECT GuID FROM dbo.R_Group WHERE Name = 'SUNDRY DEBTORS'),
        1, 0, 1, 1, NEWID()
    );
    PRINT 'Added CUSTOMER RECEIVABLES ledger.';
END
ELSE
    PRINT 'CUSTOMER RECEIVABLES ledger already exists.';
GO

-- Add COMPLEMENTARY EXPENSE under INDIRECT EXPENSE
IF NOT EXISTS (SELECT 1 FROM dbo.R_Ledger WHERE Name = 'COMPLEMENTARY EXPENSE')
BEGIN
    INSERT INTO dbo.R_Ledger (Name, GroupID, IsDebit, Amount, CompanyID, IsFixed, GuID)
    VALUES (
        'COMPLEMENTARY EXPENSE',
        (SELECT GuID FROM dbo.R_Group WHERE Name = 'INDIRECT EXPENSE'),
        1, 0, 1, 1, NEWID()
    );
    PRINT 'Added COMPLEMENTARY EXPENSE ledger.';
END
ELSE
    PRINT 'COMPLEMENTARY EXPENSE ledger already exists.';
GO

-- Add CESS PAYABLE under DUTIES & TAXES
IF NOT EXISTS (SELECT 1 FROM dbo.R_Ledger WHERE Name = 'CESS PAYABLE')
BEGIN
    INSERT INTO dbo.R_Ledger (Name, GroupID, IsDebit, Amount, CompanyID, IsFixed, GuID)
    VALUES (
        'CESS PAYABLE',
        (SELECT GuID FROM dbo.R_Group WHERE Name = 'DUTIES & TAXES'),
        0, 0, 1, 1, NEWID()
    );
    PRINT 'Added CESS PAYABLE ledger.';
END
ELSE
    PRINT 'CESS PAYABLE ledger already exists.';
GO

PRINT 'H2 complete.';
GO

-- ============================================================
-- H3: Accounts Sync UDTs (including VoucherDetail_UDT for GL posting)
-- ============================================================
PRINT 'H3: Creating Accounts Sync UDTs...';
GO

IF NOT EXISTS (SELECT 1 FROM sys.types
    WHERE name = 'Sync_AccGroup_UDT' AND schema_id = SCHEMA_ID('restaurant'))
BEGIN
    CREATE TYPE [restaurant].[Sync_AccGroup_UDT] AS TABLE (
        GuID                       NVARCHAR(50)  NOT NULL,
        Name                       NVARCHAR(200) NOT NULL,
        ParentGroupID              NVARCHAR(50)  NULL,
        ShowDetailsInFinalAccounts BIT           NOT NULL
    );
    PRINT 'Created UDT restaurant.Sync_AccGroup_UDT.';
END
ELSE
    PRINT 'UDT restaurant.Sync_AccGroup_UDT already exists.';
GO

IF NOT EXISTS (SELECT 1 FROM sys.types
    WHERE name = 'Sync_AccLedger_UDT' AND schema_id = SCHEMA_ID('restaurant'))
BEGIN
    CREATE TYPE [restaurant].[Sync_AccLedger_UDT] AS TABLE (
        GuID      NVARCHAR(50)  NOT NULL,
        Name      NVARCHAR(200) NOT NULL,
        GroupID   NVARCHAR(50)  NOT NULL,
        IsDebit   BIT           NOT NULL,
        Amount    MONEY         NOT NULL,
        CompanyID INT           NOT NULL,
        IsFixed   BIT           NOT NULL
    );
    PRINT 'Created UDT restaurant.Sync_AccLedger_UDT.';
END
ELSE
    PRINT 'UDT restaurant.Sync_AccLedger_UDT already exists.';
GO

IF NOT EXISTS (SELECT 1 FROM sys.types
    WHERE name = 'VoucherDetail_UDT' AND schema_id = SCHEMA_ID('restaurant'))
BEGIN
    CREATE TYPE [restaurant].[VoucherDetail_UDT] AS TABLE (
        [No]              INT              NOT NULL,
        [Date]            DATETIME         NOT NULL,
        [Type]            NVARCHAR(10)     NOT NULL,
        [LedgerID]        UNIQUEIDENTIFIER NOT NULL,
        [IsDebit]         BIT              NOT NULL,
        [Amount]          MONEY            NOT NULL,
        [IsPrimary]       BIT              NOT NULL,
        [IsDayBook]       BIT              NOT NULL,
        [Narration]       NVARCHAR(500)    NULL,
        [FinancialYearID] UNIQUEIDENTIFIER NOT NULL,
        [CompanyID]       INT              NOT NULL,
        [BranchID]        UNIQUEIDENTIFIER NULL,
        [CreatedUser]     NVARCHAR(100)    NULL,
        [CreatedDate]     DATETIME         NULL,
        [UpdatedUser]     NVARCHAR(100)    NULL,
        [UpdatedDate]     DATETIME         NULL
    );
    PRINT 'Created UDT restaurant.VoucherDetail_UDT.';
END
ELSE
    PRINT 'UDT restaurant.VoucherDetail_UDT already exists.';
GO

PRINT 'H3 complete.';
GO

-- ============================================================
-- H4: restaurant.Voucher table + Accounts Sync MERGE Stored Procedures
-- ============================================================
PRINT 'H4: Ensuring restaurant.Voucher table and Accounts Sync MERGE SPs...';
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'restaurant' AND TABLE_NAME = 'Voucher')
BEGIN
    CREATE TABLE [restaurant].[Voucher] (
        [ID]              INT IDENTITY(1,1) PRIMARY KEY,
        [No]              INT              NOT NULL,
        [Date]            DATETIME         NOT NULL,
        [Type]            NVARCHAR(10)     NOT NULL,
        [LedgerID]        UNIQUEIDENTIFIER NOT NULL,
        [IsDebit]         BIT              NOT NULL,
        [Amount]          MONEY            NOT NULL,
        [IsPrimary]       BIT              NOT NULL DEFAULT 0,
        [IsDayBook]       BIT              NOT NULL DEFAULT 0,
        [Narration]       NVARCHAR(500)    NULL,
        [FinancialYearID] UNIQUEIDENTIFIER NOT NULL,
        [CompanyID]       INT              NOT NULL,
        [BranchID]        UNIQUEIDENTIFIER NULL,
        [CreatedUser]     NVARCHAR(100)    NULL,
        [CreatedDate]     DATETIME         NULL DEFAULT GETDATE(),
        [UpdatedUser]     NVARCHAR(100)    NULL,
        [UpdatedDate]     DATETIME         NULL
    );
    PRINT 'Created restaurant.Voucher table.';
END
ELSE
    PRINT 'restaurant.Voucher already exists.';
GO

CREATE OR ALTER PROCEDURE [restaurant].[Sync_AccGroup_Insert]
    @UDT_AccGroup [restaurant].[Sync_AccGroup_UDT] READONLY
AS
BEGIN
    SET NOCOUNT ON;
    MERGE dbo.R_Group AS target
    USING (
        SELECT
            CAST(GuID AS UNIQUEIDENTIFIER)                     AS GuID,
            Name,
            CAST(ParentGroupID AS UNIQUEIDENTIFIER)            AS ParentGroupID,
            ShowDetailsInFinalAccounts
        FROM @UDT_AccGroup
    ) AS source ON target.GuID = source.GuID
    WHEN MATCHED THEN
        UPDATE SET
            Name                       = source.Name,
            ParentGroupID              = source.ParentGroupID,
            ShowDetailsInFinalAccounts = source.ShowDetailsInFinalAccounts
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (Name, ParentGroupID, ShowDetailsInFinalAccounts, GuID)
        VALUES (source.Name, source.ParentGroupID, source.ShowDetailsInFinalAccounts, source.GuID);
END
GO
PRINT 'Created or altered SP restaurant.Sync_AccGroup_Insert.';
GO

CREATE OR ALTER PROCEDURE [restaurant].[Sync_AccLedger_Insert]
    @UDT_AccLedger [restaurant].[Sync_AccLedger_UDT] READONLY
AS
BEGIN
    SET NOCOUNT ON;
    MERGE dbo.R_Ledger AS target
    USING (
        SELECT
            CAST(GuID AS UNIQUEIDENTIFIER)    AS GuID,
            Name,
            CAST(GroupID AS UNIQUEIDENTIFIER) AS GroupID,
            IsDebit,
            Amount,
            CompanyID,
            IsFixed
        FROM @UDT_AccLedger
    ) AS source ON target.GuID = source.GuID
    WHEN MATCHED THEN
        UPDATE SET
            Name      = source.Name,
            GroupID   = source.GroupID,
            IsDebit   = source.IsDebit,
            Amount    = source.Amount,
            CompanyID = source.CompanyID,
            IsFixed   = source.IsFixed
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (Name, GroupID, IsDebit, Amount, CompanyID, IsFixed, GuID)
        VALUES (source.Name, source.GroupID, source.IsDebit, source.Amount,
                source.CompanyID, source.IsFixed, source.GuID);
END
GO
PRINT 'Created or altered SP restaurant.Sync_AccLedger_Insert.';
GO

PRINT 'H4 complete.';
GO

-- ============================================================
-- H5: Accounts Sync read SPs (expose R_Group / R_Ledger to sync clients)
-- ============================================================
PRINT 'H5: Creating Accounts Sync read stored procedures...';
GO

CREATE OR ALTER PROCEDURE [restaurant].[Sync_AccGroup_GetAll]
    @Version BIGINT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        CAST(GuID AS VARCHAR(50))          AS Guid,
        Name,
        CAST(ParentGroupID AS VARCHAR(50)) AS ParentGroupID,
        ShowDetailsInFinalAccounts,
        0                                  AS Version
    FROM dbo.R_Group;
END
GO

CREATE OR ALTER PROCEDURE [restaurant].[Sync_AccLedger_GetAll]
    @Version BIGINT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        CAST(GuID AS VARCHAR(50))    AS Guid,
        Name,
        CAST(GroupID AS VARCHAR(50)) AS GroupID,
        IsDebit,
        Amount,
        CompanyID,
        IsFixed,
        0                            AS Version
    FROM dbo.R_Ledger;
END
GO

PRINT 'H5 complete.';
GO

-- ============================================================
-- H6: DayClose GL Posting SP
-- Called by DailyCloseDataAccess.InsertVouchers() after day close sync.
-- ============================================================
PRINT 'H6: Creating DayClose_PostGL_Insert SP...';
GO

CREATE OR ALTER PROCEDURE [restaurant].[DayClose_PostGL_Insert]
    @VoucherDetails_UDT [restaurant].[VoucherDetail_UDT] READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- Duplicate guard: skip rows already posted (No + Type pair already in Voucher)
    IF EXISTS (
        SELECT 1 FROM restaurant.Voucher v
        INNER JOIN @VoucherDetails_UDT u ON v.No = u.No AND v.Type = u.Type
    )
        RETURN;

    INSERT INTO restaurant.Voucher
        ([No], [Date], [Type], [LedgerID], [IsDebit], [Amount], [IsPrimary], [IsDayBook],
         [Narration], [FinancialYearID], [CompanyID], [BranchID], [CreatedUser], [CreatedDate], [UpdatedUser], [UpdatedDate])
    SELECT
        [No], [Date], [Type], [LedgerID], [IsDebit], [Amount], [IsPrimary], [IsDayBook],
        [Narration], [FinancialYearID], [CompanyID], [BranchID], [CreatedUser], [CreatedDate], [UpdatedUser], [UpdatedDate]
    FROM @VoucherDetails_UDT;
END
GO

PRINT 'H6 complete.';
GO

PRINT 'Section H complete.';
GO

-- ============================================================
-- SECTION I: COMBO INTELLIGENCE
-- Added: 2026-06-29
-- Feature: "Customers also ordered" suggestion strip
-- Run this section on every production database being deployed.
-- The entire section is idempotent — safe to run multiple times.
-- After running, execute: EXEC usp_ComputeComboIntelligence
-- to populate suggestion data from existing sales history.
-- ============================================================
PRINT 'Section I: Combo Intelligence setup...';
GO

-- I1: Create R_ComboIntelligence table
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'R_ComboIntelligence')
BEGIN
    CREATE TABLE R_ComboIntelligence (
        ID              INT IDENTITY(1,1) PRIMARY KEY,
        ProductID       UNIQUEIDENTIFIER NOT NULL,
        SuggestedID     UNIQUEIDENTIFIER NOT NULL,
        TimeSlot        TINYINT NOT NULL,
        -- 0 = All (time-agnostic aggregate)
        -- 1 = Breakfast  06:00 - 10:59
        -- 2 = Lunch      11:00 - 14:59
        -- 3 = Dinner     15:00 - 22:59
        -- 4 = Late Night 23:00 - 05:59
        CoCount         INT NOT NULL DEFAULT 0,
        BaseCount       INT NOT NULL DEFAULT 0,
        Confidence      DECIMAL(5,4) NOT NULL DEFAULT 0,
        LastUpdated     DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT UQ_ComboIntel UNIQUE (ProductID, SuggestedID, TimeSlot)
    );

    CREATE INDEX IX_ComboIntel_Lookup
        ON R_ComboIntelligence (ProductID, TimeSlot, Confidence DESC);

    PRINT 'R_ComboIntelligence table created.';
END
ELSE
    PRINT 'R_ComboIntelligence already exists - skipped.';
GO

-- I2: Create usp_ComputeComboIntelligence stored procedure
IF OBJECT_ID('usp_ComputeComboIntelligence', 'P') IS NOT NULL
    DROP PROCEDURE usp_ComputeComboIntelligence;
GO

CREATE PROCEDURE usp_ComputeComboIntelligence
AS
BEGIN
    SET NOCOUNT ON;

    -- Cold-start guard: need at least 500 completed bills before patterns mean anything
    DECLARE @TotalBills INT;
    SELECT @TotalBills = COUNT(*)
    FROM R_SalesTempMaster
    WHERE Deleted <> 1 AND Cancelled <> 1 AND Refund <> 1 AND IsComplementary <> 1;

    IF @TotalBills < 500
    BEGIN
        PRINT 'Cold start: fewer than 500 bills. Computation skipped.';
        RETURN;
    END

    -- Purge suggestions where either product has since been deleted
    DELETE FROM R_ComboIntelligence
    WHERE ProductID   NOT IN (SELECT GuID FROM R_Product WHERE Deleted <> 1)
       OR SuggestedID NOT IN (SELECT GuID FROM R_Product WHERE Deleted <> 1);

    ;WITH BillItems AS (
        SELECT
            SM.GuID                                       AS BillID,
            SD.ProductID,
            CASE
                WHEN CAST(SM.BillTime AS TIME) >= '06:00' AND CAST(SM.BillTime AS TIME) < '11:00' THEN 1
                WHEN CAST(SM.BillTime AS TIME) >= '11:00' AND CAST(SM.BillTime AS TIME) < '15:00' THEN 2
                WHEN CAST(SM.BillTime AS TIME) >= '15:00' AND CAST(SM.BillTime AS TIME) < '23:00' THEN 3
                ELSE 4
            END AS TimeSlot
        FROM R_SalesTempMaster SM
        INNER JOIN R_SalesTempDetail SD ON SD.MasterID = SM.GuID
        INNER JOIN R_Product P ON P.GuID = SD.ProductID AND P.Deleted <> 1
        WHERE SM.Deleted <> 1
          AND SM.Cancelled <> 1
          AND SM.Refund <> 1
          AND SM.IsComplementary <> 1
          AND SD.Deleted <> 1
          AND SD.Cancelled <> 1
    ),
    PairsSlotted AS (
        SELECT
            A.ProductID,
            B.ProductID   AS SuggestedID,
            A.TimeSlot,
            COUNT(DISTINCT A.BillID) AS CoCount
        FROM BillItems A
        INNER JOIN BillItems B ON B.BillID = A.BillID
                               AND B.ProductID <> A.ProductID
                               AND B.TimeSlot = A.TimeSlot
        GROUP BY A.ProductID, B.ProductID, A.TimeSlot
    ),
    BaseSlotted AS (
        SELECT ProductID, TimeSlot, COUNT(DISTINCT BillID) AS BaseCount
        FROM BillItems
        GROUP BY ProductID, TimeSlot
    ),
    PairsAll AS (
        SELECT
            A.ProductID,
            B.ProductID   AS SuggestedID,
            0             AS TimeSlot,
            COUNT(DISTINCT A.BillID) AS CoCount
        FROM BillItems A
        INNER JOIN BillItems B ON B.BillID = A.BillID
                               AND B.ProductID <> A.ProductID
        GROUP BY A.ProductID, B.ProductID
    ),
    BaseAll AS (
        SELECT ProductID, 0 AS TimeSlot, COUNT(DISTINCT BillID) AS BaseCount
        FROM BillItems
        GROUP BY ProductID
    ),
    AllPairs AS (
        SELECT P.ProductID, P.SuggestedID, P.TimeSlot, P.CoCount, B.BaseCount,
               CAST(P.CoCount AS DECIMAL(10,4)) / CAST(B.BaseCount AS DECIMAL(10,4)) AS Confidence
        FROM PairsSlotted P
        INNER JOIN BaseSlotted B ON B.ProductID = P.ProductID AND B.TimeSlot = P.TimeSlot
        WHERE B.BaseCount >= 20

        UNION ALL

        SELECT P.ProductID, P.SuggestedID, P.TimeSlot, P.CoCount, B.BaseCount,
               CAST(P.CoCount AS DECIMAL(10,4)) / CAST(B.BaseCount AS DECIMAL(10,4)) AS Confidence
        FROM PairsAll P
        INNER JOIN BaseAll B ON B.ProductID = P.ProductID
        WHERE B.BaseCount >= 20
    )

    MERGE R_ComboIntelligence AS Target
    USING (
        SELECT ProductID, SuggestedID, TimeSlot, CoCount, BaseCount, Confidence
        FROM AllPairs
        WHERE Confidence >= 0.25
    ) AS Source
        ON  Target.ProductID   = Source.ProductID
        AND Target.SuggestedID = Source.SuggestedID
        AND Target.TimeSlot    = Source.TimeSlot
    WHEN MATCHED THEN
        UPDATE SET
            CoCount     = Source.CoCount,
            BaseCount   = Source.BaseCount,
            Confidence  = Source.Confidence,
            LastUpdated = GETDATE()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (ProductID, SuggestedID, TimeSlot, CoCount, BaseCount, Confidence, LastUpdated)
        VALUES (Source.ProductID, Source.SuggestedID, Source.TimeSlot,
                Source.CoCount, Source.BaseCount, Source.Confidence, GETDATE())
    WHEN NOT MATCHED BY SOURCE THEN
        DELETE;

    PRINT 'usp_ComputeComboIntelligence completed. Rows affected: ' + CAST(@@ROWCOUNT AS VARCHAR);
END;
GO

-- I3: Populate initial data (skip if table already has rows from a prior run)
IF NOT EXISTS (SELECT 1 FROM R_ComboIntelligence)
BEGIN
    EXEC usp_ComputeComboIntelligence;
    PRINT 'Initial combo intelligence data populated.';
END
ELSE
    PRINT 'R_ComboIntelligence already has data - skipped initial population. Run EXEC usp_ComputeComboIntelligence manually to refresh.';
GO

PRINT 'Section I complete.';
GO

-- ============================================================
-- SECTION J: Bill-wise Receipt -- POS Extension (Option B)
-- Added: 2026-07-01
-- Extends the existing web bill-wise receipt to also cover
-- credit bills from POS (R_SalesMaster / R_SalesTempMaster).
--
-- DB changes:
--   J1: ALTER dbo.BillReceiptDetail    -- add SourceType column
--   J2: Recreate BillReceiptDetail_UDT -- add SourceType
--   J3: Recreate GETCUSTOMERBILLS      -- UNION 3 sources
--   J4: Recreate BillReceiptInsertUpdate -- SourceType + IsSettled
--   J5: Recreate Get_BillReceiptDetails  -- POS-aware detail join
-- ============================================================
PRINT 'Section J: Bill-wise Receipt POS Extension...';
GO

-- ------------------------------------------------------------
-- J1: Add SourceType column to restaurant.BillReceiptDetail and dbo.BillReceiptDetail
-- ------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE Name = 'SourceType'
      AND Object_ID = OBJECT_ID('restaurant.BillReceiptDetail')
)
BEGIN
    ALTER TABLE restaurant.BillReceiptDetail ADD SourceType varchar(10) NULL DEFAULT 'WEB';
    PRINT 'J1: Added SourceType to restaurant.BillReceiptDetail.';
END
ELSE
    PRINT 'J1: SourceType already exists in restaurant.BillReceiptDetail.';

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE Name = 'SourceType'
      AND Object_ID = OBJECT_ID('dbo.BillReceiptDetail')
)
BEGIN
    ALTER TABLE dbo.BillReceiptDetail ADD SourceType varchar(10) NULL DEFAULT 'WEB';
    PRINT 'J1: Added SourceType to dbo.BillReceiptDetail.';
END
ELSE
    PRINT 'J1: SourceType already exists in dbo.BillReceiptDetail.';
GO

-- ------------------------------------------------------------
-- J2: Recreate BillReceiptDetail_UDT with SourceType
--     Must drop dependent SPs before dropping the type.
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS [restaurant].[BillReceiptInsertUpdate];
DROP PROCEDURE IF EXISTS [restaurant].[Get_BillReceiptDetails];
DROP PROCEDURE IF EXISTS [restaurant].[GETCUSTOMERBILLS];
GO

DROP TYPE IF EXISTS [restaurant].[BillReceiptDetail_UDT];
GO

CREATE TYPE [restaurant].[BillReceiptDetail_UDT] AS TABLE
(
    SalesMasterID       uniqueidentifier NULL,
    SalesReturnMasterID uniqueidentifier NULL,
    SourceType          varchar(10)      NULL,
    Amount              decimal(18, 2)   NOT NULL DEFAULT 0,
    Discount            decimal(18, 2)   NOT NULL DEFAULT 0
);
GO

PRINT 'J2: BillReceiptDetail_UDT recreated with SourceType.';
GO

-- ------------------------------------------------------------
-- J3: Recreate restaurant.GETCUSTOMERBILLS
--     Returns outstanding credit bills from all 3 sources.
--     Columns: TransType, GUID, InvoiceNo, EntryNumber,
--              EntryDate, NetTotal, Amount, Discount, SourceType
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE [restaurant].[GETCUSTOMERBILLS]
    @BranchID   uniqueidentifier,
    @CustomerID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    WITH Received AS (
        SELECT
            SalesMasterID,
            SUM(ISNULL(Amount,   0)) AS TotalReceived,
            SUM(ISNULL(Discount, 0)) AS TotalDiscount
        FROM (
            SELECT SalesMasterID, Amount, Discount FROM restaurant.BillReceiptDetail WHERE SalesMasterID IS NOT NULL
            UNION ALL
            SELECT SalesMasterID, Amount, Discount FROM dbo.BillReceiptDetail WHERE SalesMasterID IS NOT NULL
        ) BRD
        WHERE SalesMasterID <> CAST('00000000-0000-0000-0000-000000000000' AS uniqueidentifier)
        GROUP BY SalesMasterID
    )

    SELECT
        'SI'                       AS TransType,
        SM.GUID                    AS GUID,
        SM.EntryNumber             AS InvoiceNo,
        SM.EntryNumber             AS EntryNumber,
        SM.INVDATE                 AS EntryDate,
        SM.NetTotal                AS NetTotal,
        ISNULL(R.TotalReceived, 0) AS Amount,
        ISNULL(R.TotalDiscount, 0) AS Discount,
        'WEB'                      AS SourceType
    FROM restaurant.Inv_SalesMaster SM
    LEFT JOIN Received R ON R.SalesMasterID = SM.GUID
    WHERE SM.CUSTOMER    = @CustomerID
      AND SM.BranchID    = @BranchID
      AND SM.PaymentMode = 1
      AND SM.TransType   = 'SI'
      AND ISNULL(SM.Deleted, 0) = 0
      AND SM.NetTotal > ISNULL(R.TotalReceived, 0) + ISNULL(R.TotalDiscount, 0)

    UNION ALL

    SELECT
        'SI'                                 AS TransType,
        SM.GUID                              AS GUID,
        SM.BillNo                            AS InvoiceNo,
        SM.BillNo                            AS EntryNumber,
        CAST(SM.TransactionDate AS datetime) AS EntryDate,
        SM.CustomerCredit                    AS NetTotal,
        ISNULL(R.TotalReceived, 0)           AS Amount,
        ISNULL(R.TotalDiscount, 0)           AS Discount,
        'POS'                                AS SourceType
    FROM dbo.R_SalesMaster SM
    LEFT JOIN Received R ON R.SalesMasterID = SM.GUID
    WHERE SM.CustomerID   = @CustomerID
      AND SM.BranchID     = @BranchID
      AND SM.CustomerCredit > 0
      AND SM.Deleted      = 0
      AND SM.Cancelled    = 0
      AND SM.CustomerCredit > ISNULL(R.TotalReceived, 0) + ISNULL(R.TotalDiscount, 0)

    UNION ALL

    SELECT
        'SI'                                 AS TransType,
        SM.GUID                              AS GUID,
        SM.BillNo                            AS InvoiceNo,
        SM.BillNo                            AS EntryNumber,
        CAST(SM.TransactionDate AS datetime) AS EntryDate,
        SM.CustomerCredit                    AS NetTotal,
        ISNULL(R.TotalReceived, 0)           AS Amount,
        ISNULL(R.TotalDiscount, 0)           AS Discount,
        'POS'                                AS SourceType
    FROM dbo.R_SalesTempMaster SM
    LEFT JOIN Received R ON R.SalesMasterID = SM.GUID
    WHERE SM.CustomerID   = @CustomerID
      AND SM.BranchID     = @BranchID
      AND SM.CustomerCredit > 0
      AND SM.Deleted      = 0
      AND SM.Cancelled    = 0
      AND SM.CustomerCredit > ISNULL(R.TotalReceived, 0) + ISNULL(R.TotalDiscount, 0)

    ORDER BY EntryDate;
END;
GO

PRINT 'J3: GETCUSTOMERBILLS SP created.';
GO

-- ------------------------------------------------------------
-- J4: Recreate restaurant.BillReceiptInsertUpdate
--     INSERT/UPDATE master, refresh detail with SourceType,
--     post GL voucher, mark POS bills IsSettled when fully paid.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE [restaurant].[BillReceiptInsertUpdate]
    @GuID               uniqueidentifier = NULL,
    @Date               datetime,
    @No                 bigint,
    @CustomerID         uniqueidentifier,
    @LedgerID           uniqueidentifier,
    @Narration          nvarchar(500)    = NULL,
    @Amount             decimal(18, 2),
    @CompanyID          uniqueidentifier,
    @FinancialYearID    uniqueidentifier,
    @IsCheque           bit              = 0,
    @CurrencyID         uniqueidentifier,
    @CurrencyRate       decimal(18, 4)   = 1,
    @BranchID           uniqueidentifier,
    @Discount           decimal(18, 2)   = 0,
    @UpdatedUser        nvarchar(100)    = NULL,
    @BillReceiptDetail_UDT [restaurant].[BillReceiptDetail_UDT] READONLY,
    @VoucherDetails_UDT    [restaurant].[VoucherDetail_UDT]     READONLY
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY

        DECLARE @MasterGUID uniqueidentifier;
        DECLARE @ActualNo   bigint         = @No;
        DECLARE @BranchStr  nvarchar(50)   = CAST(@BranchID AS nvarchar(50));
        DECLARE @NoStr      nvarchar(50);

        IF @ActualNo = 0
            SELECT @ActualNo = ISNULL(MAX(No), 0) + 1
            FROM dbo.BillReceiptMaster
            WHERE BranchID = @BranchID;

        SET @NoStr = CAST(@ActualNo AS nvarchar(50));

        IF @GuID IS NULL
        BEGIN
            SET @MasterGUID = NEWID();
            INSERT INTO restaurant.BillReceiptMaster
                (GUID, No, Date, CustomerID, LedgerID, Narration, Amount,
                 CompanyID, FinancialYearID, IsCheque, CurrencyID, CurrencyRate,
                 BranchID, Discount, UpdatedUser, IsDeleted)
            VALUES
                (@MasterGUID, @ActualNo, @Date, @CustomerID, @LedgerID, @Narration, @Amount,
                 @CompanyID, @FinancialYearID, @IsCheque, @CurrencyID, @CurrencyRate,
                 @BranchID, @Discount, @UpdatedUser, 0);
        END
        ELSE
        BEGIN
            SET @MasterGUID = @GuID;
            SELECT @NoStr = CAST(No AS nvarchar(50))
            FROM restaurant.BillReceiptMaster WHERE GUID = @MasterGUID;

            UPDATE restaurant.BillReceiptMaster
            SET No = @ActualNo, Date = @Date, CustomerID = @CustomerID,
                LedgerID = @LedgerID, Narration = @Narration, Amount = @Amount,
                CompanyID = @CompanyID, FinancialYearID = @FinancialYearID,
                IsCheque = @IsCheque, CurrencyID = @CurrencyID, CurrencyRate = @CurrencyRate,
                BranchID = @BranchID, Discount = @Discount, UpdatedUser = @UpdatedUser
            WHERE GUID = @MasterGUID;
        END;

        DELETE FROM restaurant.BillReceiptDetail WHERE MasterID = @MasterGUID;

        INSERT INTO restaurant.BillReceiptDetail
            (GUID, MasterID, SalesMasterID, SalesReturnMasterID, SourceType, Amount, Discount)
        SELECT
            NEWID(),
            @MasterGUID,
            SalesMasterID,
            SalesReturnMasterID,
            ISNULL(SourceType, 'WEB'),
            Amount,
            Discount
        FROM @BillReceiptDetail_UDT;

        DELETE FROM restaurant.Voucher
        WHERE No = @NoStr AND Type = 'BR' AND BranchID = @BranchStr;

        INSERT INTO restaurant.Voucher
            ([No], [Date], [Type], [LedgerID], [IsDebit], [Amount], [IsPrimary],
             [IsDayBook], [Narration], [FinancialYearID], [CompanyID], [BranchID],
             [CreatedUser], [CreatedDate], [UpdatedUser], [UpdatedDate])
        SELECT
            @NoStr, [Date], [Type], [LedgerID], [IsDebit], [Amount], [IsPrimary],
            [IsDayBook], [Narration], [FinancialYearID], [CompanyID], [BranchID],
            [CreatedUser], [CreatedDate], [UpdatedUser], [UpdatedDate]
        FROM @VoucherDetails_UDT;

        UPDATE dbo.R_SalesMaster
        SET IsSettled = 1
        WHERE GUID IN (
            SELECT SalesMasterID FROM @BillReceiptDetail_UDT
            WHERE SourceType = 'POS' AND SalesMasterID IS NOT NULL
        )
          AND CustomerCredit <= (
            SELECT ISNULL(SUM(bd.Amount + bd.Discount), 0)
            FROM restaurant.BillReceiptDetail bd
            WHERE bd.SalesMasterID = dbo.R_SalesMaster.GUID
          );

        UPDATE dbo.R_SalesTempMaster
        SET IsSettled = 1
        WHERE GUID IN (
            SELECT SalesMasterID FROM @BillReceiptDetail_UDT
            WHERE SourceType = 'POS' AND SalesMasterID IS NOT NULL
        )
          AND CustomerCredit <= (
            SELECT ISNULL(SUM(bd.Amount + bd.Discount), 0)
            FROM restaurant.BillReceiptDetail bd
            WHERE bd.SalesMasterID = dbo.R_SalesTempMaster.GUID
          );

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

PRINT 'J4: BillReceiptInsertUpdate SP created.';
GO

-- ------------------------------------------------------------
-- J5: Recreate restaurant.Get_BillReceiptDetails
--     SourceType-aware JOIN for receipt history detail view.
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE [restaurant].[Get_BillReceiptDetails]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        BRM.ID, BRM.GUID, BRM.BranchID, BRM.No, BRM.Date,
        BRM.CustomerID, BRM.LedgerID, BRM.Narration, BRM.Amount,
        BRM.FinancialYearID, BRM.CompanyID, BRM.IsCheque,
        BRM.CurrencyID, BRM.CurrencyRate, BRM.Discount,
        ISNULL(BRM.IsDeleted, 0) AS IsDeleted
    FROM restaurant.BillReceiptMaster BRM
    ORDER BY BRM.Date DESC;

    SELECT
        BRD.MasterID,
        BRD.SalesMasterID,
        BRD.SalesReturnMasterID,
        BRD.Amount,
        BRD.Discount,
        ISNULL(BRD.SourceType, 'WEB')                              AS SourceType,
        COALESCE(WEB.EntryNumber, POS.BillNo)                      AS EntryNumber,
        COALESCE(WEB.INVDATE,     POS.TransactionDate)             AS InvDate,
        COALESCE(WEB.NetTotal,    POS.CustomerCredit)              AS NetTotal,
        CASE ISNULL(BRD.SourceType, 'WEB') WHEN 'POS' THEN 'POS' ELSE 'SI' END AS TransType
    FROM restaurant.BillReceiptDetail BRD
    LEFT JOIN restaurant.Inv_SalesMaster WEB
        ON WEB.GUID = BRD.SalesMasterID
       AND ISNULL(BRD.SourceType, 'WEB') = 'WEB'
    LEFT JOIN (
        SELECT GUID, BillNo, TransactionDate, CustomerCredit FROM dbo.R_SalesMaster
        UNION ALL
        SELECT GUID, BillNo, TransactionDate, CustomerCredit FROM dbo.R_SalesTempMaster
    ) POS ON POS.GUID = BRD.SalesMasterID AND BRD.SourceType = 'POS';

END;
GO

PRINT 'J5: Get_BillReceiptDetails SP created.';
GO

PRINT 'Section J complete.';
GO
