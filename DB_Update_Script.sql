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

-- NOTE: Run this script while connected to your target database.
-- Do NOT add a USE statement here; select the correct database
-- in SSMS (dropdown) or via: sqlcmd -S <server> -d <database> -i DB_Update_Script.sql

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
-- SECTION A3: KASHKAN PHASE 2 — COMPLIMENTARY REASON (Req #5)
-- ============================================================
PRINT 'Section A3: Complimentary Reason setup...';
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[R_Settings] WHERE [Key] = 'IsComplimentaryReasonEnabled')
BEGIN
    INSERT INTO [dbo].[R_Settings] ([Key], [Value])
    VALUES ('IsComplimentaryReasonEnabled', 'FALSE');
    PRINT 'Inserted setting IsComplimentaryReasonEnabled successfully.';
END
ELSE
BEGIN
    PRINT 'Setting IsComplimentaryReasonEnabled already exists.';
END
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[R_ReasonType]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.R_ReasonType WHERE GuID = '3B1F5C2A-6D8E-4F1B-9A3C-7E2D4B5F6A8C')
    BEGIN
        INSERT INTO dbo.R_ReasonType (Name, GuID, Deleted) VALUES ('Complimentary', '3B1F5C2A-6D8E-4F1B-9A3C-7E2D4B5F6A8C', 0);
        PRINT 'Inserted R_ReasonType row Complimentary successfully.';
    END
    ELSE
        PRINT 'R_ReasonType row Complimentary already exists.';
END
ELSE
    PRINT 'Skipped R_ReasonType seed (table does not exist on this database).';
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

    -- KitchenManagerPrinter and KitchenManagerPrinterID are two separate, legitimate
    -- columns in the current schema (a printer name/label and a printer reference ID) —
    -- confirmed directly against defaultDB. An earlier version of this script assumed
    -- KitchenManagerPrinter was a mistaken duplicate meant to be renamed into
    -- KitchenManagerPrinterID, which fails with "already in use as a COLUMN name" on any
    -- database where both columns legitimately coexist. Ensure both exist independently.
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_Section') AND name = 'KitchenManagerPrinter')
    BEGIN
        ALTER TABLE [dbo].[R_Section] ADD [KitchenManagerPrinter] NVARCHAR(255) NULL;
        PRINT 'Added column KitchenManagerPrinter to dbo.R_Section.';
    END
    ELSE
        PRINT 'Column KitchenManagerPrinter already exists in dbo.R_Section.';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_Section') AND name = 'KitchenManagerPrinterID')
    BEGIN
        ALTER TABLE [dbo].[R_Section] ADD [KitchenManagerPrinterID] NVARCHAR(255) NULL;
        PRINT 'Added column KitchenManagerPrinterID to dbo.R_Section.';
    END
    ELSE
        PRINT 'Column KitchenManagerPrinterID already exists in dbo.R_Section.';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_Section') AND name = 'DeliveryPrinterID')
    BEGIN
        ALTER TABLE [dbo].[R_Section] ADD [DeliveryPrinterID] NVARCHAR(255) NULL;
        PRINT 'Added column DeliveryPrinterID to dbo.R_Section.';
    END
    ELSE
        PRINT 'Column DeliveryPrinterID already exists in dbo.R_Section.';

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

-- dbo.R_SectionKOTPrinter
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.R_SectionKOTPrinter') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_SectionKOTPrinter') AND name = 'ProductID')
    BEGIN
        ALTER TABLE [dbo].[R_SectionKOTPrinter] ADD [ProductID] UNIQUEIDENTIFIER NULL;
        PRINT 'Added column ProductID to dbo.R_SectionKOTPrinter.';
    END
    ELSE
        PRINT 'Column ProductID already exists in dbo.R_SectionKOTPrinter.';
END
ELSE
    PRINT 'Table dbo.R_SectionKOTPrinter does not exist. Skipping alters.';
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

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'DeliveryPrinterID' AND Object_ID = Object_ID('restaurant.SectionSettings'))
    BEGIN
        ALTER TABLE [restaurant].[SectionSettings] ADD [DeliveryPrinterID] NVARCHAR(50) NULL;
        PRINT 'Added column DeliveryPrinterID to restaurant.SectionSettings.';
    END
    ELSE
        PRINT 'Column DeliveryPrinterID already exists in restaurant.SectionSettings.';
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

-- Heal R_Category.CategoryMasterGuID from restaurant.CategoryLocationMapping.
-- The Category-master link is stored in BOTH R_Category (global, read by the sales/profit/summary
-- reports) and CategoryLocationMapping (per-branch, read by the Category master UI). On any DB where
-- categories existed before R_Category.CategoryMasterGuID was added, the base column stays NULL while
-- the mapping already carries the link, so Category/Group-wise and Item-Summary reports come back blank
-- even though the UI shows the category as grouped. Idempotent: only fills rows still NULL, from an
-- active mapping that actually has a master.
IF OBJECT_ID('dbo.R_Category','U') IS NOT NULL AND OBJECT_ID('restaurant.CategoryLocationMapping','U') IS NOT NULL
BEGIN
    UPDATE C
        SET C.CategoryMasterGuID = X.CategoryMasterGuID
    FROM dbo.R_Category C
    CROSS APPLY (
        SELECT TOP 1 CLM.CategoryMasterGuID
        FROM restaurant.CategoryLocationMapping CLM
        WHERE CLM.CategoryID = C.GuID AND CLM.CategoryMasterGuID IS NOT NULL
        ORDER BY CLM.IsActive DESC, CLM.UpdatedDate DESC
    ) X
    WHERE C.CategoryMasterGuID IS NULL;
    PRINT 'Backfilled R_Category.CategoryMasterGuID from CategoryLocationMapping where missing.';
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

-- Kashkan Phase 2: Complimentary Reason (Req #5) — ComplimentaryReason column, mirrors
-- CancelReason/ComplementaryTotal which already exist on both R_SalesMaster and
-- R_SalesTempMaster since SalesMaster.Insert()/Update() write to whichever table
-- IsTemp resolves to.
-- dbo.R_SalesMaster
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[R_SalesMaster]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_SalesMaster') AND name = 'ComplimentaryReason')
    BEGIN
        ALTER TABLE dbo.R_SalesMaster ADD ComplimentaryReason varchar(250) NULL;
        PRINT 'Added column ComplimentaryReason to dbo.R_SalesMaster successfully.';
    END
END
GO

-- dbo.R_SalesTempMaster
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[R_SalesTempMaster]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_SalesTempMaster') AND name = 'ComplimentaryReason')
    BEGIN
        ALTER TABLE dbo.R_SalesTempMaster ADD ComplimentaryReason varchar(250) NULL;
        PRINT 'Added column ComplimentaryReason to dbo.R_SalesTempMaster successfully.';
    END
END
GO

-- Kashkan Phase 5: Order Timing + Captain/Waiter Report (Req #4) —
-- OrderOpenedDateTime/OrderClosedDateTime, same two tables as
-- ComplimentaryReason above, for the same reason (Insert()/Update()
-- write to whichever table IsTemp resolves to). Opened is stamped
-- once at Insert() time; Closed is stamped the first time IsPending
-- transitions 1->0 (payment covers total, or Cancel), guarded so a
-- later unrelated edit never overwrites the original closed time.
-- dbo.R_SalesMaster
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[R_SalesMaster]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_SalesMaster') AND name = 'OrderOpenedDateTime')
    BEGIN
        ALTER TABLE dbo.R_SalesMaster ADD OrderOpenedDateTime datetime NULL;
        PRINT 'Added column OrderOpenedDateTime to dbo.R_SalesMaster successfully.';
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_SalesMaster') AND name = 'OrderClosedDateTime')
    BEGIN
        ALTER TABLE dbo.R_SalesMaster ADD OrderClosedDateTime datetime NULL;
        PRINT 'Added column OrderClosedDateTime to dbo.R_SalesMaster successfully.';
    END
END
GO

-- dbo.R_SalesTempMaster
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[R_SalesTempMaster]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_SalesTempMaster') AND name = 'OrderOpenedDateTime')
    BEGIN
        ALTER TABLE dbo.R_SalesTempMaster ADD OrderOpenedDateTime datetime NULL;
        PRINT 'Added column OrderOpenedDateTime to dbo.R_SalesTempMaster successfully.';
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_SalesTempMaster') AND name = 'OrderClosedDateTime')
    BEGIN
        ALTER TABLE dbo.R_SalesTempMaster ADD OrderClosedDateTime datetime NULL;
        PRINT 'Added column OrderClosedDateTime to dbo.R_SalesTempMaster successfully.';
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

-- restaurant.Sync_Sales_GetAll (Windows-side sync source proc read by Axobis.Restaurant.Server.Sync's
-- SalesSyncHandler.GetAllSales — must select OrderType or the C# row["OrderType"] mapping throws and
-- breaks the whole sales upload batch for this customer)
CREATE OR ALTER PROCEDURE [restaurant].[Sync_Sales_GetAll]
	@Version BIGINT = NULL
AS

    SET NOCOUNT ON

	SELECT SM.ID,SM.[GuID],[No],[Date],SectionID,CounterID,BillTime,CustomerID,Total,RTotal,Tax,Cash,[Card],[CardNo],
	FxPaid,FxTypeID,FxRate,FxAmount,CustomerCredit,Discount,DiscountPercentage,RoundOff,FinancialYearID,
	UserID,CreatedBy,Remarks,CompanyID,LastUpdate,BranchID,Deleted,Refund,TransactionDate,IsPending,
	BillTypeID,Cancelled,WaiterID,ProdDiscount,CustomerGSTNo,BillNo,SeriesType,TableID,CancelReason,
	TokenNo,IsDespatched,IsSettled,DeliveryDate,DeliveryTime,DeliveryRemarks,IsShiftClosed,ShiftNumber,
	TabID,Merged,Pax,Redeem,ISNULL(RedeemPoints,0)RedeemPoints,NoOfChairs,ChairPositions,TabBillNo,IsComplementary,ComplementaryTotal,
	CardID,IsprintedFromPay,CessAmount,WaiterRemarks,IsSaved,IsTakenForUpload,EditedAfterUpload,vehicleno,
	TabOrderNo,convert(BIGINT,Version)[Version],UpdatedUser
	,SD.[GuID] AS DeliveryID, OrderType, OrderOpenedDateTime, OrderClosedDateTime
	FROM [R_SalesMaster] SM
	LEFT OUTER JOIN [R_SalesDelivery] SD ON SM.[GuID] = SD.MasterID
	WHERE [Version] > @Version

	SELECT *  FROM [R_SalesDetail]

	SELECT [GuID],MasterID,[Type],[Amount],CardNo,CardTypeID,FxTypeID,FxPaid,FxRate,[CustomerID],deleted,Cancelled
	FROM [dbo].[R_SalesPaymentDetail]

	SELECT * FROM R_SalesProductModifierDetail

	SELECT * FROM [R_SalesComboDetail]

	SELECT * FROM [R_SalesDelivery]

	SELECT * FROM [R_MiscellaneousSalesAmount]

	SET NOCOUNT OFF
GO
PRINT 'Created or altered restaurant.Sync_Sales_GetAll (added OrderType to SELECT list).';
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
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('restaurant.BillReceiptMaster') AND name = 'Deleted')
    BEGIN
        ALTER TABLE restaurant.BillReceiptMaster ADD Deleted bit NULL DEFAULT ((0));
        PRINT 'Added column Deleted to restaurant.BillReceiptMaster successfully.';
    END
END
GO

-- dbo.LedgerBranchOpeningMaster
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LedgerBranchOpeningMaster]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LedgerBranchOpeningMaster') AND name = 'Deleted')
    BEGIN
        ALTER TABLE dbo.LedgerBranchOpeningMaster ADD Deleted bit NULL DEFAULT ((0));
        PRINT 'Added column Deleted to dbo.LedgerBranchOpeningMaster successfully.';
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LedgerBranchOpeningMaster') AND name = 'CreatedUser')
    BEGIN
        ALTER TABLE dbo.LedgerBranchOpeningMaster ADD CreatedUser uniqueidentifier NULL;
        PRINT 'Added column CreatedUser to dbo.LedgerBranchOpeningMaster successfully.';
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LedgerBranchOpeningMaster') AND name = 'CreatedDate')
    BEGIN
        ALTER TABLE dbo.LedgerBranchOpeningMaster ADD CreatedDate datetime NULL;
        PRINT 'Added column CreatedDate to dbo.LedgerBranchOpeningMaster successfully.';
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LedgerBranchOpeningMaster') AND name = 'UpdatedUser')
    BEGIN
        ALTER TABLE dbo.LedgerBranchOpeningMaster ADD UpdatedUser uniqueidentifier NULL;
        PRINT 'Added column UpdatedUser to dbo.LedgerBranchOpeningMaster successfully.';
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LedgerBranchOpeningMaster') AND name = 'UpdatedDate')
    BEGIN
        ALTER TABLE dbo.LedgerBranchOpeningMaster ADD UpdatedDate datetime NULL;
        PRINT 'Added column UpdatedDate to dbo.LedgerBranchOpeningMaster successfully.';
    END
END
GO

-- dbo.R_FinancialYear
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[R_FinancialYear]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_FinancialYear') AND name = 'GuID')
    BEGIN
        ALTER TABLE dbo.R_FinancialYear ADD GuID uniqueidentifier NOT NULL DEFAULT (newid());
        PRINT 'Added column GuID to dbo.R_FinancialYear successfully.';
    END
END
GO

-- restaurant.BillPaymentMaster
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[BillPaymentMaster]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('restaurant.BillPaymentMaster') AND name = 'Deleted')
    BEGIN
        ALTER TABLE restaurant.BillPaymentMaster ADD Deleted bit NULL DEFAULT ((0));
        PRINT 'Added column Deleted to restaurant.BillPaymentMaster successfully.';
    END
END
GO

-- restaurant.JournalMaster
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[JournalMaster]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('restaurant.JournalMaster') AND name = 'Deleted')
    BEGIN
        ALTER TABLE restaurant.JournalMaster ADD Deleted bit NULL DEFAULT ((0));
        PRINT 'Added column Deleted to restaurant.JournalMaster successfully.';
    END
END
GO

-- restaurant.PaymentMaster
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[PaymentMaster]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('restaurant.PaymentMaster') AND name = 'Deleted')
    BEGIN
        ALTER TABLE restaurant.PaymentMaster ADD Deleted bit NULL DEFAULT ((0));
        PRINT 'Added column Deleted to restaurant.PaymentMaster successfully.';
    END
END
GO

-- restaurant.ReceiptMaster
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[ReceiptMaster]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('restaurant.ReceiptMaster') AND name = 'Deleted')
    BEGIN
        ALTER TABLE restaurant.ReceiptMaster ADD Deleted bit NULL DEFAULT ((0));
        PRINT 'Added column Deleted to restaurant.ReceiptMaster successfully.';
    END
END
GO

-- restaurant.WebMenu
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[WebMenu]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('restaurant.WebMenu') AND name = 'IsActive')
    BEGIN
        ALTER TABLE restaurant.WebMenu ADD IsActive bit NULL DEFAULT ((1));
        PRINT 'Added column IsActive to restaurant.WebMenu successfully.';
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

IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[ZoneMaster]') AND type in (N'U'))
BEGIN
    CREATE TABLE [restaurant].[ZoneMaster](
        [GuID] [uniqueidentifier] NOT NULL,
        [Name] [varchar](100) NOT NULL,
        [BranchID] [uniqueidentifier] NOT NULL,
        [Deleted] [bit] NOT NULL DEFAULT ((0)),
        [CreatedDate] [datetime] NOT NULL DEFAULT (getdate()),
        [UpdatedDate] [datetime] NULL,
        [OtherLanguageName] [nvarchar](100) NULL,
        [CreatedUser] [nvarchar](100) NOT NULL DEFAULT (''),
        [UpdatedUser] [nvarchar](100) NULL,
    PRIMARY KEY CLUSTERED ([GuID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
          ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY];
    PRINT 'Created Table restaurant.ZoneMaster successfully.';
END
ELSE
    PRINT 'Table restaurant.ZoneMaster already exists.';
GO

IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[CategoryMaster]') AND type in (N'U'))
BEGIN
    CREATE TABLE [restaurant].[CategoryMaster](
        [GuID] [uniqueidentifier] NOT NULL,
        [Name] [varchar](100) NOT NULL,
        [OtherLanguageName] [nvarchar](100) NULL,
        [BranchID] [uniqueidentifier] NOT NULL,
        [Deleted] [bit] NOT NULL DEFAULT ((0)),
        [CreatedDate] [datetime] NOT NULL DEFAULT (getdate()),
        [UpdatedDate] [datetime] NULL,
        [CreatedUser] [nvarchar](100) NOT NULL DEFAULT (''),
        [UpdatedUser] [nvarchar](100) NULL,
    PRIMARY KEY CLUSTERED ([GuID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
          ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY];
    PRINT 'Created Table restaurant.CategoryMaster successfully.';
END
ELSE
    PRINT 'Table restaurant.CategoryMaster already exists.';
GO

IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[R_ProductImage]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[R_ProductImage](
        [ID] [int] IDENTITY(1,1) NOT NULL,
        [ProductGuID] [uniqueidentifier] NOT NULL,
        [ImageURL] [nvarchar](500) NOT NULL,
        [ThumbnailURL] [nvarchar](500) NULL,
        [IsPrimary] [bit] NOT NULL DEFAULT ((0)),
        [CreatedDate] [datetime] NULL DEFAULT (getdate()),
        [CreatedUser] [nvarchar](100) NULL,
        [UpdatedDate] [datetime] NULL,
        [UpdatedUser] [nvarchar](100) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
          ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY];
    PRINT 'Created Table dbo.R_ProductImage successfully.';
END
ELSE
    PRINT 'Table dbo.R_ProductImage already exists.';
GO

IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[R_ProductModifiers]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[R_ProductModifiers](
        [ID] [int] IDENTITY(1,1) NOT NULL,
        [ProductID] [uniqueidentifier] NOT NULL,
        [ModifierID] [uniqueidentifier] NOT NULL,
        [IsDefault] [bit] NOT NULL DEFAULT ((0)),
        [ExtraCharge] [money] NULL,
        [CreatedDate] [datetime] NOT NULL DEFAULT (getdate()),
    PRIMARY KEY CLUSTERED ([ID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
          ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY];
    PRINT 'Created Table dbo.R_ProductModifiers successfully.';
END
ELSE
    PRINT 'Table dbo.R_ProductModifiers already exists.';
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

-- Kashkan Phase 3: Item Void / Quantity-Decrease Reason (Req #2).
-- Voided items are removed from the billing grid before the order is ever
-- saved, so there is no R_SalesDetail row to attach a VoidReason column to
-- (confirmed no SP references the orphaned restaurant.SaleED UDT, and
-- R_SalesDetail/R_SalesTempDetail carry no IsVoid/VoidReason columns today
-- -- extending them would be dead weight). A standalone audit-log table,
-- written at the moment of void regardless of whether the order is ever
-- saved, is the correct fit and is what the Void Report (Req #3) queries.
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[R_VoidLog]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[R_VoidLog](
        [ID] [int] IDENTITY(1,1) NOT NULL,
        [GuID] [uniqueidentifier] NOT NULL,
        [MasterID] [uniqueidentifier] NULL,
        [BillNo] [varchar](50) NULL,
        [SectionID] [uniqueidentifier] NULL,
        [CounterID] [uniqueidentifier] NULL,
        [BranchID] [uniqueidentifier] NULL,
        [ProductID] [uniqueidentifier] NULL,
        [ProductName] [varchar](200) NULL,
        [Quantity] [decimal](18, 3) NULL,
        [UnitRate] [money] NULL,
        [Reason] [varchar](250) NULL,
        [VoidedByUserID] [uniqueidentifier] NULL,
        [VoidedByUserName] [varchar](100) NULL,
        [VoidedDate] [datetime] NOT NULL,
        [CompanyID] [int] NULL,
        [FinancialYearID] [decimal](18, 0) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
          ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY];
    PRINT 'Created Table dbo.R_VoidLog successfully.';
END
ELSE
    PRINT 'Table dbo.R_VoidLog already exists.';
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[R_Settings] WHERE [Key] = 'IsVoidReasonEnabled')
BEGIN
    INSERT INTO [dbo].[R_Settings] ([Key], [Value])
    VALUES ('IsVoidReasonEnabled', 'FALSE');
    PRINT 'Inserted setting IsVoidReasonEnabled successfully.';
END
ELSE
BEGIN
    PRINT 'Setting IsVoidReasonEnabled already exists.';
END
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[R_ReasonType]') AND type = 'U')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.R_ReasonType WHERE GuID = '9C2E4A7B-1F3D-4E6A-8B5C-2D9F0A1E3C7B')
    BEGIN
        INSERT INTO dbo.R_ReasonType (Name, GuID, Deleted) VALUES ('Void', '9C2E4A7B-1F3D-4E6A-8B5C-2D9F0A1E3C7B', 0);
        PRINT 'Inserted R_ReasonType row Void successfully.';
    END
    ELSE
        PRINT 'R_ReasonType row Void already exists.';
END
ELSE
    PRINT 'Skipped R_ReasonType seed (table does not exist on this database).';
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
    [KitchenManagerPrinterID]        [nvarchar](50)  NULL,
    [DeliveryPrinterID]              [nvarchar](50)  NULL
);
GO
PRINT 'Created UDT restaurant.Sync_Section_Setting_UDT (27 columns).';
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
        [ProductGuid] [uniqueidentifier] NULL,
        [ImageURL] [nvarchar](500) NULL,
        [ThumbnailURL] [nvarchar](500) NULL,
        [IsPrimary] [bit] NULL,
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
        [ProductGuid] [uniqueidentifier] NULL,
        [ImageURL] [nvarchar](500) NULL,
        [ThumbnailURL] [nvarchar](500) NULL,
        [IsPrimary] [bit] NULL,
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
        D.SectionID, D.Price, ISNULL(P.Barcode, '') AS Barcode,
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
      AND ISNULL(P.MenuItem, 1) = 1
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
        D.SectionID, D.Price, ISNULL(P.Barcode, '') AS Barcode,
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
      AND ISNULL(P.MenuItem, 1) = 1
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
    @KitchenManagerPrinterID NVARCHAR(50) = NULL,
    @DeliveryPrinterID NVARCHAR(50) = NULL
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
            KitchenManagerPrinterID = @KitchenManagerPrinterID,
            DeliveryPrinterID = @DeliveryPrinterID
        WHERE [MasterID] = @MasterID AND BranchID = @BranchID
    END
    ELSE
    BEGIN
        SET @NewGuid = NEWID()
        INSERT INTO restaurant.SectionSettings
        ([GuID],MasterID,BranchID,IsTableEnable,IsWaiterEnable,IsCustomerEnable,IsKOTSalesPrint,IsKOTinReceiptPrinter,IsKOTPrint,IsSalesPrintOnSave,
         PrintTempFile,NoOfPrints,StartNo,InvoicePrefix,TaxId,CreatedUser,CreatedDate,UpdatedUser,UpdatedDate,
         IsMultiOrderEnabled,InvoicePrinterID,IsPaxEnabled,isChairEnabled,IsCashButtonPrint,
         IsPayScreenPrintOnSettle,IsKitchenManagerPrintEnabled,KitchenManagerPrinterID,DeliveryPrinterID)
        VALUES
        (@NewGuid,@MasterID,@BranchID,@ShowPopupToSelectTable,@ShowPopupToSelectWaiter,@ShowPopupToCaptureCustomerDetail,@PrintKOTInSalesBillFormat,@PrintKOTInSalesBillPrinter,
         @EnableKOTPrint,@PrintBothSalesAndKOTPrint,@PrintFileName,@NumberOfKOTPrints,@BillStartNumber,@InvoicePrefix,@TaxId,@UpdatedUser,GETDATE(),@UpdatedUser,GETDATE(),
         @IsMultiOrderEnabled,@InvoicePrinterID,@IsPaxEnabled,@isChairEnabled,@IsCashButtonPrint,
         @IsPayScreenPrintOnSettle,@IsKitchenManagerPrintEnabled,@KitchenManagerPrinterID,@DeliveryPrinterID)
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
           IsCashButtonPrint,IsPayScreenPrintOnSettle,IsKitchenManagerPrintEnabled,KitchenManagerPrinterID,DeliveryPrinterID
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
           IsCashButtonPrint,IsPayScreenPrintOnSettle,IsKitchenManagerPrintEnabled,KitchenManagerPrinterID,DeliveryPrinterID
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
-- 2026-07-12: R_SalesTempED insert below now also carries UUserGuid across from R_SalesED.
-- It was previously omitted from both the column list and the SELECT, so every edit-log
-- row got UUserGuid = NULL the moment day-close moved it from R_SalesED to R_SalesTempED
-- -- regardless of whether R_SalesED itself had the value set correctly. R_SalesTempED is
-- the table that actually syncs to the web (Sync_SalesTempLog_Insert), so this is why
-- UUserGuid was always arriving NULL on the customer/web side. Single-column addition only
-- -- no other column, WHERE clause, or transaction/trigger logic in this proc changed, so
-- day-close behavior is otherwise identical.
CREATE OR ALTER PROCEDURE [dbo].[usp_TransferDataToTempTable]
    @ClosingDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO R_SalesTempMaster([GuID],[No],[Date],[SectionID],[CounterID],[BillTime],[CustomerID],[Merged],[Total],[RTotal],[Tax],[Cash],[Card],[CardNo],[FxPaid],[FxTypeID],[FxRate],[FxAmount],[CustomerCredit],[Discount],[DiscountPercentage],[ProdDiscount],[RoundOff],[FinancialYearID],[UserID],[CreatedBy],[Remarks],[CompanyID],[LastUpdate],[BranchID],[Deleted],[Refund],[TransactionDate],[IsPending],[Cancelled],[WaiterID],[CustomerGSTNo],[BillNo],[SeriesType],[TableID],[CancelReason],[Pax],[TabBillNo],[Redeem],[RedeemPoints],[NoOfChairs],[TabID],[ShiftNumber],IsShiftClosed,CardID,CessAmount,IsComplementary,ComplementaryTotal,WaiterRemarks,IsSaved,IsTakenForUpload,EditedAfterUpload,UpdatedUser,LevyTotal,OrderType,OrderOpenedDateTime,OrderClosedDateTime)
        SELECT [GuID],[No],[Date],[SectionID],[CounterID],[BillTime],[CustomerID],[Merged],[Total],[RTotal],[Tax],[Cash],[Card],[CardNo],[FxPaid],[FxTypeID],[FxRate],[FxAmount],[CustomerCredit],[Discount],[DiscountPercentage],[ProdDiscount],[RoundOff],[FinancialYearID],[UserID],[CreatedBy],[Remarks],[CompanyID],[LastUpdate],[BranchID],[Deleted],[Refund],[TransactionDate],[IsPending],[Cancelled],[WaiterID],[CustomerGSTNo],[BillNo],[SeriesType],[TableID],[CancelReason],[Pax],[TabBillNo],[Redeem],[RedeemPoints],[NoOfChairs],[TabID],[ShiftNumber],IsShiftClosed,CardID,CessAmount,IsComplementary,ComplementaryTotal,WaiterRemarks,IsSaved,IsTakenForUpload,EditedAfterUpload,UpdatedUser,LevyTotal,OrderType,OrderOpenedDateTime,OrderClosedDateTime
        FROM R_SalesMaster WHERE Cancelled = 1 OR (IsPending = 0 AND CAST(TransactionDate AS DATE) = @ClosingDate);
        INSERT INTO R_SalesTempDetail([GuID],[MasterID],[ProductID],[Quantity],[BaseQuantity],[UnitRate],[TaxID],[TaxPercentage],[Tax],[DiscPercentage],[Discount],[Merged],[UnitID],[ItemTypeID],[Deleted],[IsTaxIncludedInPrice],[Cancelled],[CessAmount],[PromoID],[Levy],[LevyPercentage],ChairNo,CourseNo)
        SELECT D.[GuID],D.[MasterID],D.[ProductID],D.[Quantity],D.[BaseQuantity],D.[UnitRate],D.[TaxID],D.[TaxPercentage],D.[Tax],D.[DiscPercentage],D.[Discount],D.[Merged],D.[UnitID],D.[ItemTypeID],D.[Deleted],D.[IsTaxIncludedInPrice],D.[Cancelled],D.[CessAmount],D.[PromoID],D.[Levy],D.[LevyPercentage],D.ChairNo,D.CourseNo
        FROM R_SalesDetail D INNER JOIN R_SalesMaster M ON D.MasterID = M.GUID
        WHERE M.Cancelled = 1 OR (M.IsPending = 0 AND CAST(M.TransactionDate AS DATE) = @ClosingDate);
        INSERT INTO R_SalesTempComboDetail([DetailGuID],[ProductID],[Quantity],[TypeID],[MasterProductID])
        SELECT C.[DetailGuID],C.[ProductID],C.[Quantity],C.[TypeID],C.[MasterProductID]
        FROM R_SalesComboDetail C INNER JOIN R_SalesDetail D ON C.DetailGuID = D.GUID INNER JOIN R_SalesMaster M ON D.MasterID = M.GUID
        WHERE M.Cancelled = 1 OR (M.IsPending = 0 AND CAST(M.TransactionDate AS DATE) = @ClosingDate);
        INSERT INTO R_SalesTempED([GuID],[MasterID],[ProductID],[Quantity],[BaseQuantity],[UnitRate],[TaxID],[TaxPercentage],[Tax],[DiscPercentage],[Discount],[UnitID],[ItemTypeID],[Deleted],[IsTaxIncludedInPrice],[Cancelled],[NewQuantity],[IsUD],[IsDD],[UDate],[UUser],[EditType],[NewUnitRate],[UUserGuid])
        SELECT E.[GuID],E.[MasterID],E.[ProductID],E.[Quantity],E.[BaseQuantity],E.[UnitRate],E.[TaxID],E.[TaxPercentage],E.[Tax],E.[DiscPercentage],E.[Discount],E.[UnitID],E.[ItemTypeID],E.[Deleted],E.[IsTaxIncludedInPrice],E.[Cancelled],E.[NewQuantity],E.[IsUD],E.[IsDD],E.[UDate],E.[UUser],E.[EditType],E.[NewUnitRate],E.[UUserGuid]
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
    INSERT INTO restaurant.KOTSequence (SalesMasterGuid, KOTNo, KOTDate, CreatedDate) VALUES (@SalesMasterGuid, @KOTNo, @TransactionDate, GETDATE());
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
-- 2026-07-12: trigger disable/enable made conditional on the trigger actually existing —
-- some customer DBs (e.g. arafa) don't have dltBlk on R_SalesED (removed intentionally,
-- not needed on the web side); an unconditional ALTER TABLE ... DISABLE TRIGGER throws
-- "trigger 'Dltblk' ... does not exist" and fails every SalesED upload on those DBs.
--
-- 2026-07-20: SET NOCOUNT ON removed. SaleDataAccess.cs's UploadSalesLog checks success as
-- `ExecuteNonQueryAsync(cmd) > 0` -- but SET NOCOUNT ON inside a stored proc makes ADO.NET's
-- ExecuteNonQuery return -1 instead of the real affected-row count, so `-1 > 0` is always
-- false regardless of whether the INSERT actually succeeded. Same root cause and same fix as
-- Sync_EinvoiceStatus_Insert above -- both were the only two receiving procs with this
-- combination (SET NOCOUNT ON + a caller checking the returned count), which is exactly why
-- SalesED and EinvoiceStatus were the only two entities stuck permanently reporting "Failure"
-- locally while their data landed correctly centrally.
CREATE OR ALTER PROCEDURE [restaurant].[Sync_SalesLog_Insert]
    @UDT_R_SalesLog [restaurant].Sync_SalesLog_UDT READONLY
AS
BEGIN
    IF EXISTS (SELECT 1 FROM sys.triggers WHERE name = 'dltBlk' AND parent_id = OBJECT_ID('R_SalesED'))
        ALTER TABLE R_SalesED DISABLE TRIGGER [dltBlk];
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
        IF EXISTS (SELECT 1 FROM sys.triggers WHERE name = 'dltBlk' AND parent_id = OBJECT_ID('R_SalesED'))
            ALTER TABLE R_SalesED ENABLE TRIGGER [dltBlk];
        RETURN 1;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        IF EXISTS (SELECT 1 FROM sys.triggers WHERE name = 'dltBlk' AND parent_id = OBJECT_ID('R_SalesED'))
            ALTER TABLE R_SalesED ENABLE TRIGGER [dltBlk];
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

-- NOTE: Sync_EinvoiceStatus_Insert / Sync_EinvoiceStatus_GetAll used to be
-- (re)defined here too ("File 1 version"), but that copy explicitly assigned
-- R_EinvoiceStatus.Version (a rowversion/timestamp column), which SQL Server
-- rejects outright once the table actually exists. On a brand-new DB this
-- passed silently (deferred name resolution — the table doesn't exist yet at
-- this point in the script), but it broke every subsequent replay of this
-- script the moment the table was present, aborting the whole run partway
-- through Section F. The only correct definitions are the later ones in
-- Section O/P (search Sync_EinvoiceStatus_Insert), which correctly exclude
-- Version and additionally add BranchID. Removed the stale/broken duplicate
-- here rather than leave two competing definitions in the file (found via
-- the Phase 4 Kashkan idempotency re-run, 2026-08-16).

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
            rs.KitchenManagerPrinterID=uss.KitchenManagerPrinterID,
            rs.DeliveryPrinterID=uss.DeliveryPrinterID
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
-- NOTE: PPD-sourced columns (IsVariableProduct, IsStockItem, IsDailyStockItem, Cost,
-- BasePrice, Loyalty) are wrapped in ISNULL(...,0). The Web API's C# mapper
-- (ProductDataAccess.SafeProductCreate) calls raw Convert.ToBoolean/Convert.ToDecimal
-- on these with no null-check, so a NULL here (deleted/inactive PPD row failing the
-- join, or a genuinely-null Cost/BasePrice/Loyalty) 500s the whole endpoint.
-- Deleted/inactive products are still returned as before, so they can be re-enabled.
CREATE OR ALTER PROCEDURE [restaurant].[Product_GetAllByBranch]
(
 @BranchID VARCHAR(500) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ISNULL(PPD.IsActive,0) AS IsActive,P.ID,P.[GUID],P.[Name],P.ShortName,RefCode,Barcode,CategoryID,CT.Name As CategoryName,UnitID,TypeID,TP.[Name] as TypeName,[Image],ISNULL(PPD.IsVariableProduct,0) AS IsVariableProduct,ISNULL(ArabicDescription,'')ArabicDescription,ISNULL(PPD.IsStockItem,0) AS IsStockItem,ERPProductID,GroupId,ColorID,VegTypeNo,OtherDescription,ISNULL(PPD.Loyalty,0) AS Loyalty,ISNULL(PPD.Cost,0) AS Cost,CessPercentage,SCategoryID,CONVERT(BIGINT,P.[Version])Version,P.Deleted,ISNULL(PPD.IsDailyStockItem,0) AS IsDailyStockItem,ISNULL(PPD.BasePrice,0) AS BasePrice,PLM.IsActive AS LocationIsActive,ISNULL(MenuItem,0)MenuItem,HSNCode,DepartmentID,P.Calories
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

-- SP: Report_EinvoiceStatusPaging — moved further below in this script (see
-- Section P), because it reads R_EinvoiceStatus.BranchID, which doesn't
-- exist on the table yet at this point in the script. Unlike a forward
-- reference to a table that doesn't exist at all, SQL Server does NOT defer
-- column-level validation once the table itself already exists (it does
-- here, created earlier above) — so this must be created after the ALTER
-- TABLE that adds BranchID, not here.

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

-- SP: Section_GetAllByBranch
-- 2026-07-12: added here for the first time — this proc was never in DB_Update_Script.sql
-- at all, so no customer DB running this script ever got the fix below (confirmed missing
-- via grep before adding). The fix itself (S.ZoneGuID in the SELECT + optional @ZoneID
-- filter) was previously applied directly to defaultDB only, one-off, and never folded back
-- into this shared script — every other customer DB (confirmed on "arafa") was still on the
-- older shape with no ZoneGuID column and no @ZoneID parameter, causing LoungeWebApp's
-- Section/GetAllByBranch calls to fail with "Column 'ZoneGuID' does not belong to table
-- Table" (SectionDataAccess.cs reads row["ZoneGuID"] from the result set unconditionally).
CREATE OR ALTER PROCEDURE [restaurant].[Section_GetAllByBranch]
(
 @BranchID  VARCHAR(500)	=	NULL,
 @ZoneID  VARCHAR(500)	=	NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT S.ID,S.[GuID],Name,ShortName,CONVERT(BIGINT,S.[Version])[Version],Deleted,SLM.IsActive, S.ZoneGuID
	FROM restaurant.SectionLocationMapping SLM
    INNER JOIN restaurant.Section S ON SLM.SectionID = S.[GuID]
	WHERE (BranchID = @BranchID) AND (@ZoneID IS NULL OR S.ZoneGuID = @ZoneID)
 AND SLM.IsActive = 1
			ORDER BY Name

	SET NOCOUNT OFF;

END
GO
PRINT 'Created or altered SP Section_GetAllByBranch.';
GO

-- SP: Sync_Section_GetAll
-- 2026-08-24: added here for the first time -- same class of bug as Section_GetAllByBranch
-- directly above, and confirmed missing from this whole script via grep before adding.
-- The S.ZoneGuID column was added to this proc on 2025-07-30 by a one-off ALTER applied to
-- ~30 databases only; it was never folded back into this shared script, so every customer
-- DB that is otherwise fully current on DB_Update_Script.sql still had the pre-2025-07-30
-- shape. SectionDataAccess.GetAll(Section) reads row["ZONEGUID"] unconditionally, so the
-- WinForms Section sync (Section/Sync/Download) died with "Column 'ZONEGUID' does not
-- belong to table Table" surfacing to the client as HTTP 500. Found on customer "alyuom",
-- which had every Phase 2-5 object present yet still failed for exactly this reason.
-- Definition below is byte-identical (whitespace-normalised) to defaultDB and to live
-- customer DB "kashkan". Note WHERE uses CONVERT(BIGINT, SLM.[Version]) -- the old shape
-- compared the rowversion to @Version implicitly.
CREATE OR ALTER PROCEDURE [restaurant].[Sync_Section_GetAll]
(
	@Version BIGINT = NULL,
	@BranchID  UNIQUEIDENTIFIER	=	NULL
)
AS

    SET NOCOUNT ON

	SELECT S.ID,S.[Guid],[Name],ShortName,Convert(Bigint,SLM.[Version])[Version]
	,CASE WHEN SLM.IsActive = 0 THEN 1 ELSE Deleted END AS Deleted
	,SLM.CreatedUser,SLM.CreatedDate,SLM.UpdatedUser,SLM.UpdatedDate, S.ZoneGuID
	FROM restaurant.SectionLocationMapping SLM 
	INNER JOIN  restaurant.Section S ON S.[GuID] = SLM.SectionID AND SLM.BranchID = @BranchID
	WHERE CONVERT(BIGINT, SLM.[Version]) > @Version

	SET NOCOUNT OFF
GO
PRINT 'Created or altered SP Sync_Section_GetAll.';
GO

-- SP: Section_GetAll
-- 2026-08-24: added here for the first time (grep-confirmed absent), for the same reason as
-- Sync_Section_GetAll above -- it is missing the ZoneGuID column on every DB that never got
-- the 2025-07-30 one-off ALTER. SectionDataAccess.GetAll() reads row["ZoneGuID"], so
-- GET api/Section/GetAll returns HTTP 500 on those DBs. Same latent failure, different
-- endpoint: the WebApp section list rather than the WinForms sync.
CREATE OR ALTER PROCEDURE [restaurant].[Section_GetAll]
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT 
	     ID,GuID,Name,ShortName,convert(BIGINT,Version)Version,Deleted, ZoneGuID
	FROM
	       restaurant.Section
       
END
GO
PRINT 'Created or altered SP Section_GetAll.';
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
			LEFT OUTER JOIN restaurant.CategoryMaster CM ON CM.GuID=CP.CategoryMasterGuID
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
			LEFT OUTER JOIN restaurant.CategoryMaster CM ON CM.GuID=CP.CategoryMasterGuID
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

-- SP: Report_CustomerCreditDetails (drift-fix: existed on customer DBs but was missing from this script; serves CustomerCreditReport/GetAll)
CREATE OR ALTER PROCEDURE [restaurant].[Report_CustomerCreditDetails]
 @FromDate       DATETIME	      = NULL,
 @ToDate         DATETIME	      = NULL,
 @CustomerId     uniqueidentifier = NULL
AS
BEGIN
	DECLARE
	@R_FromDate       DATETIME	       = @FromDate,
	@R_ToDate         DATETIME	       = @ToDate,
	@R_CustomerId     uniqueidentifier = @CustomerId

	SET ARITHABORT ON
	SET XACT_ABORT ON
	SET NOCOUNT ON

	SET @R_ToDate = DATEADD(D, 1, @R_ToDate);

	SELECT CCD.Date,BillNo,RefNo,Amount,CM.Name as Customer
	FROM R_CustomerCreditDetail CCD
	LEFT  OUTER JOIN R_Customer CM ON CM.[GuID] = CCD.CustomerID
	WHERE CustomerID=@R_CustomerId OR @R_CustomerId IS NULL
	AND (CCD.Date>=@R_FromDate OR @R_FromDate IS NULL)
	AND (CCD.Date<@R_ToDate OR @R_ToDate IS NULL)
	AND Module = 'Sales'
	ORDER BY CCD.Date,cast(CCD.BillNo AS INT)

	SET NOCOUNT OFF
END
GO
PRINT 'Created or altered SP Report_CustomerCreditDetails.';
GO

-- SP: Report_CustomerCreditRepaymentDetails (drift-fix: missing from this script; serves CustomerCreditRepaymentReport/GetAll)
CREATE OR ALTER PROCEDURE [restaurant].[Report_CustomerCreditRepaymentDetails](
	@FromDate		DATETIME			= NULL,
	@ToDate			DATETIME			= NULL,
	@CustomerId     UNIQUEIDENTIFIER	= NULL
)
AS
BEGIN
	DECLARE
	@R_FromDate		   DATETIME			= @FromDate,
	@R_ToDate		   DATETIME			= @ToDate,
	@R_CustomerId      UNIQUEIDENTIFIER	= @CustomerId

	SET ARITHABORT ON
	SET XACT_ABORT ON

	SET NOCOUNT ON
	SET @R_ToDate = DATEADD(D, 1, @R_ToDate);

	SELECT CCR.Date,S.Date [BillDate],CCD.BillNo,CCD.RefNo,C.Name Customer,CCD.Amount
	FROM R_CustomerCreditRepayment CCR
	INNER JOIN R_CustomerCreditDetail CCD on CCD.MasterID=CCR.GuID
	INNER JOIN R_Customer C on C.GuID=CCD.CustomerID
	INNER JOIN (SELECT GuID,Date from R_SalesMaster UNION SELECT GuID,Date FROM R_SalesTempMaster) S ON S.GuID=CCD.BillID
	WHERE CCD.Type='Debit' AND Module='SalesRepayment' AND CustomerID=@R_CustomerId OR @R_CustomerId IS NULL
	AND (CCR.Date>=@R_FromDate OR @R_FromDate IS NULL) AND (CCR.Date<@R_ToDate OR @R_ToDate IS NULL)  ORDER BY CCR.Date,cast(CCD.BillNo AS INT)

	SET NOCOUNT OFF
END
GO
PRINT 'Created or altered SP Report_CustomerCreditRepaymentDetails.';
GO

-- SP: Report_CustomerCreditRepaymentDetailsPaging (drift-fix: missing from this script; serves CustomerCreditRepaymentReport/GetAllLazyPagedData — the Customer Repayment report)
CREATE OR ALTER PROCEDURE [restaurant].[Report_CustomerCreditRepaymentDetailsPaging]
(
	@FromDate		  DATE      		= NULL,
	@ToDate			  DATE      		= NULL,
	@CustomerId       UNIQUEIDENTIFIER	= NULL,
    @PageNumber		  INT               = NULL,
    @PageSize	      INT               = NULL,
    @SortingColumn	  VARCHAR(MAX)      = NULL,
    @SortingDirection VARCHAR(MAX)      = NULL,
 @BranchID				 VARCHAR(MAX) = NULL
)
AS
BEGIN
	DECLARE
	@R_FromDate		    DATE     			= @FromDate,
	@R_ToDate		    DATE    			= @ToDate,
	@R_CustomerId       UNIQUEIDENTIFIER	= @CustomerId,
    @R_PageNumber	    INT				    = @PageNumber,
    @R_PageSize		    INT				    = @PageSize,
    @R_SortingColumn    VARCHAR(MAX)        = @SortingColumn,
    @R_SortingDirection VARCHAR(MAX)        = @SortingDirection,
		 @R_BranchID        VARCHAR(MAX)		 = @BranchID

	DECLARE @SortingCmd VARCHAR(MAX)

	SET ARITHABORT ON
	SET XACT_ABORT ON

	SET NOCOUNT ON
	SET @R_ToDate = DATEADD(D, 1, @R_ToDate);
	 IF Object_id('TempDB.dbo.#CustomerCreditRepaymentDetails') IS NOT NULL
	BEGIN
		DROP TABLE #CustomerCreditRepaymentDetails
	END
		IF Object_id('TempDB.dbo.#CustomerCreditRepaymentDetailsCount') IS NOT NULL
	BEGIN
		DROP TABLE #CustomerCreditRepaymentDetailsCount
	END

	------BEGIN SELECT FOR Customer Credit Repayment Details REPORT-----
		SELECT *
		INTO #CustomerCreditRepaymentDetails
		FROM
			(
				SELECT CCR.Date,S.Date [BillDate],CCD.BillNo,CCD.RefNo,C.Name Customer,CCD.Amount ,  CAST(SUBSTRING(billno, PATINDEX('%[0-9]%', BillNo), LEN(BillNo)) AS INT) AS [No]
				FROM R_CustomerCreditRepayment CCR
				INNER JOIN R_CustomerCreditDetail CCD on CCD.MasterID=CCR.GuID
				INNER JOIN R_Customer C on C.GuID=CCD.CustomerID
				INNER JOIN (SELECT GuID,Date from R_SalesMaster UNION SELECT GuID,Date FROM R_SalesTempMaster) S ON S.GuID=CCD.BillID
				WHERE CCD.Type='Debit' AND Module='SalesRepayment' AND CustomerID=@R_CustomerId OR @R_CustomerId IS NULL
				AND (CCR.Date>=@R_FromDate OR @R_FromDate IS NULL) AND (CCR.Date<@R_ToDate OR @R_ToDate IS NULL) AND(CCR.BranchID = @R_BranchID OR @R_BranchID IS NULL)
			) AS CustomerCreditRepaymentDetails

	SELECT COUNT(*) AS CustomerCreditRepaymentDetailsCount
		INTO #CustomerCreditRepaymentDetailsCount
		FROM #CustomerCreditRepaymentDetails

	IF @R_PageSize = -1
	BEGIN
		IF @R_SortingColumn IS NULL
			BEGIN
				SELECT @SortingCmd = '
					SELECT *,(SELECT CustomerCreditRepaymentDetailsCount FROM #CustomerCreditRepaymentDetailsCount)[RowCount]
					FROM #CustomerCreditRepaymentDetails
					ORDER BY [Date] '+ @R_SortingDirection+''
				EXEC (@SortingCmd)
			END
		ELSE
			BEGIN
				SELECT @SortingCmd = '
					SELECT *,(SELECT CustomerCreditRepaymentDetailsCount FROM #CustomerCreditRepaymentDetailsCount)[RowCount] ,Date as Date1
					FROM #CustomerCreditRepaymentDetails
					ORDER BY  ' + @R_SortingColumn +' '+ @R_SortingDirection+',[Date1] asc'
				EXEC (@SortingCmd)
			END
		END

	ELSE
	BEGIN
		IF @R_SortingColumn IS NULL
			BEGIN
				SELECT @SortingCmd = '
					SELECT *,(SELECT CustomerCreditRepaymentDetailsCount FROM #CustomerCreditRepaymentDetailsCount)[RowCount]
					FROM #CustomerCreditRepaymentDetails
					ORDER BY [Date] '+ @R_SortingDirection+'
					OFFSET (' + CAST(@R_PageNumber - 1 AS NVARCHAR(MAX)) + ')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS
					FETCH NEXT ' + CAST(@R_PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY'
				EXEC (@SortingCmd)
			END
		ELSE
			BEGIN
				SELECT @SortingCmd = '
					SELECT *,(SELECT CustomerCreditRepaymentDetailsCount FROM #CustomerCreditRepaymentDetailsCount)[RowCount] ,Date as Date1
					FROM #CustomerCreditRepaymentDetails
					ORDER BY  ' + @R_SortingColumn +' '+ @R_SortingDirection+',[Date1] asc
					OFFSET (' + CAST(@R_PageNumber - 1 AS NVARCHAR(MAX)) + ')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS
					FETCH NEXT ' + CAST(@R_PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY'
				EXEC (@SortingCmd)
		END
	END

	------ FOR GETTING FOOTER TOTAL---------------------
		SELECT  ''AS Date,
		        ''AS[BillDate],
				''AS BillNo,
				''AS RefNo,
				''AS Customer,
				SUM(Amount)Amount
		FROM #CustomerCreditRepaymentDetails

	------END OF DETAIL SECTION-----

	IF Object_id('TempDB.dbo.#CustomerCreditRepaymentDetails') IS NOT NULL
	BEGIN
		DROP TABLE #CustomerCreditRepaymentDetails
	END

	IF Object_id('TempDB.dbo.#CustomerCreditRepaymentDetailsCount') IS NOT NULL
	BEGIN
		DROP TABLE #CustomerCreditRepaymentDetailsCount
	END


 SET NOCOUNT OFF
END
GO
PRINT 'Created or altered SP Report_CustomerCreditRepaymentDetailsPaging.';
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
-- Phase 1 fix: running vs settled split (Req #1, #10)
-- Root cause: @IsLiveSale / @StatusType parameters were declared
-- but never referenced in the proc bodies, so dashboard/report
-- totals always combined running + settled orders.
-- Fix convention: NULL parameter = unfiltered (today's default,
-- unchanged), explicit value = filtered. Running/settled is
-- determined by SM.IsPending (0=settled,1=running), matching
-- the same flag already used by [Status] CASE logic in
-- Report_SalesStatusReport and by Day Close's pending exclusion.
-- ============================================================

CREATE OR ALTER PROCEDURE [restaurant].[GetSectionWiseSale]
(
 @IsLiveSale     BIT              = NULL,
 @UserID         VARCHAR(MAX)     = NULL,
 @FromDate       VARCHAR(MAX)	  = NULL,
 @ToDate         VARCHAR(MAX)	  = NULL,
 @BranchID       UNIQUEIDENTIFIER	  = NULL
 )
AS

			IF Object_id('TempDB.dbo.#SectionWiseSale') IS NOT NULL
				BEGIN
					DROP TABLE #SectionWiseSale
			END

			SELECT Section,SUM(BillTotal)BillTotal
			INTO #SectionWiseSale
			FROM (

			SELECT S.[Name] Section
			,(SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff+ ISNULL(DelAmount+ContAmount+OtherAmount,0)) BillTotal
			--INTO #SectionWiseSale
			FROM R_SalesTempMaster SM
			LEFT OUTER JOIN restaurant.Section S ON SM.SectionID = S.[GuID]
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND Cancelled=0 and SM.Deleted=0 AND Refund=0 AND IsComplementary = 0
			AND SM.BranchID = @BranchID
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))
			--GROUP BY S.[Name]

			UNION ALL

			SELECT S.[Name] Section
			,(SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff+ ISNULL(DelAmount+ContAmount+OtherAmount,0)) BillTotal
			FROM R_SalesMaster SM
			LEFT OUTER JOIN restaurant.Section S ON SM.SectionID = S.[GuID]
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND Cancelled=0 and SM.Deleted=0 AND Refund=0 AND IsComplementary = 0
			AND SM.BranchID = @BranchID
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))
			--GROUP BY S.[Name]
			) AS T
			GROUP BY Section

			SELECT Section,BillTotal,CAST(IIF(BillTotal=0,0,ROUND((BillTotal*100)/SUM(BillTotal) OVER(),2)) AS DECIMAL(18,2))
			PERCENTAGE
			FROM #SectionWiseSale
GO
PRINT 'Created or altered SP GetSectionWiseSale.';
GO


CREATE OR ALTER PROCEDURE [restaurant].[GetSubSectionWiseSale]
(
 @IsLiveSale     BIT              = NULL,
 @Section        VARCHAR(MAX)     = NULL,
 @FromDate       VARCHAR(MAX)	  = NULL,
 @ToDate         VARCHAR(MAX)	  = NULL,
 @BranchID       UNIQUEIDENTIFIER	  = NULL
 )
AS

IF Object_id('TempDB.dbo.#SectionWiseSale') IS NOT NULL
				BEGIN
					DROP TABLE #SectionWiseSale
			END

			SELECT TransactionDate,Section,SUM(BillTotal)BillTotal
			INTO #SectionWiseSale
			FROM(
			SELECT SM.TransactionDate,S.[Name] Section,(SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff+ ISNULL(DelAmount+ContAmount+OtherAmount,0)) BillTotal
			--INTO #TempSectionWiseSale
			FROM R_SalesTempMaster SM
			LEFT OUTER JOIN restaurant.Section S ON SM.SectionID = S.[GuID]
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND Cancelled=0 and SM.Deleted=0 AND Refund=0 AND IsComplementary = 0
			AND SM.BranchID = @BranchID
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))
			--GROUP BY SM.TransactionDate,S.[Name]

			UNION ALL

			SELECT SM.TransactionDate,S.[Name] Section,(SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff+ ISNULL(DelAmount+ContAmount+OtherAmount,0)) BillTotal
			--INTO #SectionWiseSale
			FROM R_SalesMaster SM
			LEFT OUTER JOIN restaurant.Section S ON SM.SectionID = S.[GuID]
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND Cancelled=0 and SM.Deleted=0 AND Refund=0 AND IsComplementary = 0
			AND SM.BranchID = @BranchID
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))
			--GROUP BY SM.TransactionDate,S.[Name]
			) AS T
			GROUP BY TransactionDate,Section

			SELECT TransactionDate,Section,BillTotal,CAST(IIF(BillTotal=0,0,ROUND((BillTotal*100)/SUM(BillTotal) OVER(),2)) AS DECIMAL(18,2))
			PERCENTAGE
			FROM #SectionWiseSale
			WHERE (Section = @Section OR @Section IS NULL)
GO
PRINT 'Created or altered SP GetSubSectionWiseSale.';
GO


CREATE OR ALTER PROCEDURE [restaurant].[GetDateWiseSectionSale]
(
 @IsLiveSale     BIT              = NULL,
 @UserID         VARCHAR(MAX)     = NULL,
 @FromDate       VARCHAR(MAX)	  = NULL,
 @ToDate         VARCHAR(MAX)	  = NULL,
 @BranchID       UNIQUEIDENTIFIER	  = NULL
 )
AS
SELECT TransactionDate,Section,SUM(BillTotal)BillTotal
from(
		SELECT TransactionDate,S.[Name] as Section,
			(SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff+ ISNULL(DelAmount+ContAmount+OtherAmount,0)) AS BillTotal
			FROM R_SalesTempMaster SM
			LEFT OUTER JOIN restaurant.Section S ON S.[GuID] = SM.[SectionID]
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND Cancelled=0 and SM.Deleted=0 AND Refund=0 AND IsComplementary = 0
			AND SM.BranchID = @BranchID
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))

		UNION ALL

		SELECT TransactionDate,S.[Name] as Section,
			(SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff+ ISNULL(DelAmount+ContAmount+OtherAmount,0)) AS BillTotal
			FROM R_SalesMaster SM
			LEFT OUTER JOIN restaurant.Section S ON S.[GuID] = SM.[SectionID]
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND Cancelled=0 and SM.Deleted=0 AND Refund=0 AND IsComplementary = 0
			AND SM.BranchID = @BranchID
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))
			)T
			GROUP BY TransactionDate,Section
			ORDER BY TransactionDate
GO
PRINT 'Created or altered SP GetDateWiseSectionSale.';
GO


CREATE OR ALTER PROCEDURE [restaurant].[GetProductWiseSale]
(
 @IsLiveSale     BIT              = NULL,
 @FromDate       VARCHAR(MAX)	  = NULL,
 @ToDate         VARCHAR(MAX)	  = NULL,
 @BranchID       UNIQUEIDENTIFIER	  = NULL
 )
AS

			IF Object_id('TempDB.dbo.#GetProductWiseSale') IS NOT NULL
				BEGIN
					DROP TABLE #GetProductWiseSale
			END
		 SELECT Product,Total,Quantity,TransactionDate
		 INTO #GetProductWiseSale
		 FROM(
					SELECT P.[Name] Product
					,((SD.unitRate* SD.Quantity)-SD.Discount)+(SD.Tax)+(SD.CessAmount) Total
					,TransactionDate,SD.Quantity
					--INTO #GetProductWiseSale
					FROM R_SalesTempMaster SM
					LEFT OUTER JOIN R_SalesTempDetail SD ON SD.[MasterID] = SM.[GuID]
					LEFT OUTER JOIN restaurant.Product P ON P.[GuID] = SD.[ProductID]
					WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
					AND SM.Cancelled=0 and SM.Deleted=0 AND Refund=0 AND IsComplementary = 0
					AND SM.BranchID = @BranchID
					AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))

					UNION ALL

					SELECT P.[Name] Product
					,((SD.unitRate* SD.Quantity)-SD.Discount)+(SD.Tax)+(SD.CessAmount) Total
					,TransactionDate,SD.Quantity
					FROM R_SalesMaster SM
					LEFT OUTER JOIN R_SalesDetail SD ON SD.[MasterID] = SM.[GuID]
					LEFT OUTER JOIN restaurant.Product P ON P.[GuID] = SD.[ProductID]
					WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
							AND SM.Cancelled=0 and SM.Deleted=0 AND Refund=0 AND IsComplementary = 0
							AND SM.BranchID = @BranchID
							AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))

		) AS TAD
					SELECT Product,SUM(Total)BillTotal,SUM(Quantity)Quantity,TransactionDate
					FROM #GetProductWiseSale
					GROUP BY Product,TransactionDate
GO
PRINT 'Created or altered SP GetProductWiseSale.';
GO


CREATE OR ALTER PROCEDURE [restaurant].[GetWaiterWiseSale]
(
 @IsLiveSale     BIT              = NULL,
 @UserID         VARCHAR(MAX)     = NULL,
 @FromDate       VARCHAR(MAX)	  = NULL,
 @ToDate         VARCHAR(MAX)	  = NULL,
 @BranchID       UNIQUEIDENTIFIER	  = NULL
 )
AS
 SELECT Waiter,SUM(BillTotal)BillTotal
 FROM
 (
 	SELECT UM.[Name] Waiter
			,SUM(SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff+ ISNULL(DelAmount+ContAmount+OtherAmount,0)) BillTotal
			FROM R_SalesTempMaster SM
			LEFT OUTER JOIN R_User UM ON SM.[WaiterID] = UM.[GuID]
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND Cancelled=0 and SM.Deleted=0 AND Refund=0 AND IsComplementary = 0
			AND SM.BranchID = @BranchID
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))
			GROUP BY UM.[Name]

			UNION ALL

			SELECT UM.[Name] Waiter
			,SUM(SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff+ ISNULL(DelAmount+ContAmount+OtherAmount,0)) BillTotal
			FROM R_SalesMaster SM
			LEFT OUTER JOIN R_User UM ON SM.[WaiterID] = UM.[GuID]
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND Cancelled=0 and SM.Deleted=0 AND Refund=0 AND IsComplementary = 0
			AND SM.BranchID = @BranchID
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))
			GROUP BY UM.[Name]

			)
			AS T
			GROUP BY Waiter
GO
PRINT 'Created or altered SP GetWaiterWiseSale.';
GO


CREATE OR ALTER PROCEDURE [restaurant].[GetDailySale]
(
 @IsLiveSale     BIT              = NULL,
 @FromDate       VARCHAR(MAX)	  = NULL,
 @ToDate         VARCHAR(MAX)	  = NULL,
 @BranchID       UNIQUEIDENTIFIER	  = NULL
 )
AS

SET NOCOUNT ON;

 	SELECT SM.TransactionDate,SUM(SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff+ ISNULL(DelAmount+ContAmount+OtherAmount,0)) BillTotal
			FROM R_SalesTempMaster SM
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND Cancelled=0 and SM.Deleted=0 AND Refund=0 AND IsComplementary = 0 AND IsComplementary = 0
			AND SM.BranchID = @BranchID
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))
			GROUP BY SM.TransactionDate
			UNION ALL
   SELECT SM.TransactionDate,SUM(SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff+ ISNULL(DelAmount+ContAmount+OtherAmount,0)) BillTotal
			FROM R_SalesMaster SM
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND Cancelled=0 and SM.Deleted=0 AND Refund=0 AND IsComplementary = 0 AND IsComplementary = 0
			AND SM.BranchID = @BranchID
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))
			GROUP BY SM.TransactionDate


SET NOCOUNT OFF;
GO
PRINT 'Created or altered SP GetDailySale.';
GO


CREATE OR ALTER PROCEDURE [restaurant].[GetTop5WaiterWiseSale]
(
 @IsLiveSale     BIT              = NULL,
 @UserID         VARCHAR(MAX)     = NULL,
 @FromDate       VARCHAR(MAX)	  = NULL,
 @ToDate         VARCHAR(MAX)	  = NULL,
 @BranchID       UNIQUEIDENTIFIER	  = NULL
 )
AS

			 IF Object_id('TempDB.dbo.#TempTop5Waiter') IS NOT NULL
				BEGIN
					DROP TABLE #TempTop5Waiter
			END

			SELECT Waiter,SUM(BillTotal)BillTotal
			INTO #TempTop5Waiter
			FROM (
			SELECT UM.[Name] Waiter,(SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff+ ISNULL(DelAmount+ContAmount+OtherAmount,0)) BillTotal
			FROM R_SalesTempMaster SM
			LEFT OUTER JOIN R_User UM ON SM.[WaiterID] = UM.[GuID]
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND Cancelled=0 and SM.Deleted=0 AND Refund=0 AND IsComplementary = 0
			AND SM.BranchID = @BranchID
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))

			UNION ALL

			SELECT UM.[Name] Waiter
			,(SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff+ ISNULL(DelAmount+ContAmount+OtherAmount,0)) BillTotal
			FROM R_SalesMaster SM
			LEFT OUTER JOIN R_User UM ON SM.[WaiterID] = UM.[GuID]
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND Cancelled=0 and SM.Deleted=0 AND Refund=0 AND IsComplementary = 0
			AND SM.BranchID = @BranchID
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))
			) AS T
			GROUP BY Waiter

			SELECT TOP 5 Waiter,BillTotal,CAST(IIF(BillTotal=0,0,ROUND((BillTotal*100)/SUM(BillTotal) OVER(),2)) AS DECIMAL(18,2))
			PERCENTAGE
			FROM #TempTop5Waiter
			ORDER BY BillTotal DESC
GO
PRINT 'Created or altered SP GetTop5WaiterWiseSale.';
GO


CREATE OR ALTER PROCEDURE [restaurant].[GetLeast5WaiterWiseSale]
(
 @IsLiveSale     BIT              = NULL,
 @UserID         VARCHAR(MAX)     = NULL,
 @FromDate       VARCHAR(MAX)	  = NULL,
 @ToDate         VARCHAR(MAX)	  = NULL,
 @BranchID       UNIQUEIDENTIFIER	  = NULL
 )
AS

			 IF Object_id('TempDB.dbo.#Top5Waiter') IS NOT NULL
				BEGIN
					DROP TABLE #Top5Waiter
			END

			SELECT Waiter,SUM(BillTotal)BillTotal
			INTO #Top5Waiter
			FROM
			(
			SELECT UM.[Name] Waiter
			,(SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff+ ISNULL(DelAmount+ContAmount+OtherAmount,0)) BillTotal
			FROM R_SalesTempMaster SM
			LEFT OUTER JOIN R_User UM ON SM.[WaiterID] = UM.[GuID]
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND Cancelled=0 and SM.Deleted=0 AND Refund=0 AND IsComplementary = 0
			AND SM.BranchID = @BranchID
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))

			UNION ALL

			SELECT UM.[Name] Waiter
			,(SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff+ ISNULL(DelAmount+ContAmount+OtherAmount,0)) BillTotal
			FROM R_SalesMaster SM
			LEFT OUTER JOIN R_User UM ON SM.[WaiterID] = UM.[GuID]
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND Cancelled=0 and SM.Deleted=0 AND Refund=0 AND IsComplementary = 0
			AND SM.BranchID = @BranchID
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))
			) AS T
			GROUP BY Waiter

			SELECT TOP 5 Waiter,BillTotal,CAST(IIF(BillTotal=0,0,ROUND((BillTotal*100)/SUM(BillTotal) OVER(),2)) AS DECIMAL(18,2))
			PERCENTAGE
			FROM #Top5Waiter
			ORDER BY BillTotal ASC
GO
PRINT 'Created or altered SP GetLeast5WaiterWiseSale.';
GO


CREATE OR ALTER PROCEDURE [restaurant].[GetTop5ItemWiseSale]
(
 @IsLiveSale     BIT              = NULL,
 @UserID         VARCHAR(MAX)     = NULL,
 @FromDate       VARCHAR(MAX)	  = NULL,
 @ToDate         VARCHAR(MAX)	  = NULL,
 @BranchID       UNIQUEIDENTIFIER	  = NULL
 )
AS
			IF Object_id('TempDB.dbo.#Top5ItemWiseSale') IS NOT NULL
				BEGIN
					DROP TABLE #Top5ItemWiseSale
			END
			SELECT Product,SUM(QUANTITY)QUANTITY,SUM(BillTotal)BillTotal
			INTO #Top5ItemWiseSale
			FROM (
			SELECT PM.[Name] Product,SUM(Quantity)QUANTITY ,ROUND(SUM(((SD.unitRate* SD.Quantity)-SD.Discount)+(SD.Tax)+(SD.CessAmount)),2) BillTotal
			FROM R_SalesTempMaster SM
			LEFT OUTER JOIN R_SalesTempDetail SD ON SM.[GuID] = SD.MasterID
			LEFT OUTER JOIN restaurant.Product PM ON SD.ProductID = PM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND SM.Cancelled=0 and SM.Deleted=0 AND Refund=0 --AND IsComplementary = 0
			AND SM.BranchID = @BranchID
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))
			GROUP BY PM.[Name]

			UNION ALL

			SELECT PM.[Name] Product,SUM(Quantity)QUANTITY ,ROUND(SUM(((SD.unitRate* SD.Quantity)-SD.Discount)+(SD.Tax)+(SD.CessAmount)),2) BillTotal
			FROM R_SalesMaster SM
			LEFT OUTER JOIN R_SalesDetail SD ON SM.[GuID] = SD.MasterID
			LEFT OUTER JOIN restaurant.Product PM ON SD.ProductID = PM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND SM.Cancelled=0 and SM.Deleted=0 AND Refund=0 --AND IsComplementary = 0
			AND SM.BranchID = @BranchID
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))
			GROUP BY PM.[Name]
			) AS T
			GROUP BY Product

			SELECT TOP 5 Product,BillTotal
			FROM #Top5ItemWiseSale
			ORDER BY BillTotal DESC
GO
PRINT 'Created or altered SP GetTop5ItemWiseSale.';
GO


CREATE OR ALTER PROCEDURE [restaurant].[GetLeast5ItemWiseSale]
(
 @IsLiveSale     BIT              = NULL,
 @UserID         VARCHAR(MAX)     = NULL,
 @FromDate       VARCHAR(MAX)	  = NULL,
 @ToDate         VARCHAR(MAX)	  = NULL,
 @BranchID       UNIQUEIDENTIFIER	  = NULL
 )
AS
			IF Object_id('TempDB.dbo.#Top5ItemWiseSale') IS NOT NULL
				BEGIN
					DROP TABLE #Top5ItemWiseSale
			END
			SELECT Product,SUM(QUANTITY)QUANTITY,SUM(BillTotal)BillTotal
			INTO #Top5ItemWiseSale
			FROM
			(
			SELECT PM.[Name] Product,SUM(Quantity)QUANTITY ,ROUND(SUM(((SD.unitRate* SD.Quantity)-SD.Discount)+(SD.Tax)+(SD.CessAmount)),2) BillTotal
			FROM R_SalesTempMaster SM
			LEFT OUTER JOIN R_SalesTempDetail SD ON SM.[GuID] = SD.MasterID
			LEFT OUTER JOIN restaurant.Product PM ON SD.ProductID = PM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND SM.Cancelled=0 and SM.Deleted=0 AND Refund=0 --AND IsComplementary = 0
			AND SM.BranchID = @BranchID
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))
			GROUP BY PM.[Name]

			UNION ALL

			SELECT PM.[Name] Product,SUM(Quantity)QUANTITY ,ROUND(SUM(((SD.unitRate* SD.Quantity)-SD.Discount)+(SD.Tax)+(SD.CessAmount)),2) BillTotal
			FROM R_SalesMaster SM
			LEFT OUTER JOIN R_SalesDetail SD ON SM.[GuID] = SD.MasterID
			LEFT OUTER JOIN restaurant.Product PM ON SD.ProductID = PM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND SM.Cancelled=0 and SM.Deleted=0 AND Refund=0 --AND IsComplementary = 0
			AND SM.BranchID = @BranchID
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))
			GROUP BY PM.[Name]
			) AS T
			GROUP BY Product

			SELECT TOP 5 Product,BillTotal
			FROM #Top5ItemWiseSale
			ORDER BY BillTotal ASC
GO
PRINT 'Created or altered SP GetLeast5ItemWiseSale.';
GO


CREATE OR ALTER PROCEDURE [restaurant].[GetTop5CategoryWiseSale]
(
 @IsLiveSale     BIT              = NULL,
 @UserID         VARCHAR(MAX)     = NULL,
 @FromDate       VARCHAR(MAX)	  = NULL,
 @ToDate         VARCHAR(MAX)	  = NULL,
 @BranchID       UNIQUEIDENTIFIER	  = NULL
 )
AS
		IF Object_id('TempDB.dbo.#Top5CategoryWiseSale') IS NOT NULL
			BEGIN
				DROP TABLE #Top5CategoryWiseSale
		END

		SELECT Category,SUM(QUANTITY)QUANTITY,SUM(BillTotal)BillTotal
		INTO #Top5CategoryWiseSale
		FROM
		(
		SELECT C.[Name] Category,SUM(Quantity)QUANTITY ,ROUND(SUM(((SD.unitRate* SD.Quantity)-SD.Discount)+(SD.Tax)+(SD.CessAmount)),2) BillTotal
		FROM R_SalesTempMaster SM
		INNER JOIN R_SalesTempDetail SD ON SM.[GuID] = SD.MasterID
		INNER JOIN restaurant.Product PM ON SD.ProductID = PM.[GuID]
		INNER JOIN restaurant.ProductPriceDetail PPD ON PPD.MasterID = PM.[GuID]
		INNER JOIN R_Category C ON PPD.CategoryID = C.[GuID]
		WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
		AND SM.Cancelled=0 and SM.Deleted=0 AND Refund=0 --AND IsComplementary = 0
		AND SM.BranchID = @BranchID
		AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))
		GROUP BY C.[Name]

		UNION ALL

		SELECT C.[Name] Category,SUM(Quantity)QUANTITY ,ROUND(SUM(((SD.unitRate* SD.Quantity)-SD.Discount)+(SD.Tax)+(SD.CessAmount)),2) BillTotal
		FROM R_SalesMaster SM
		INNER JOIN R_SalesDetail SD ON SM.[GuID] = SD.MasterID
		INNER JOIN restaurant.Product PM ON SD.ProductID = PM.[GuID]
		INNER JOIN restaurant.ProductPriceDetail PPD ON PPD.MasterID = PM.[GuID]
		INNER JOIN R_Category C ON PPD.CategoryID = C.[GuID]
		WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
		AND SM.Cancelled=0 and SM.Deleted=0 AND Refund=0 --AND IsComplementary = 0
		AND SM.BranchID = @BranchID
		AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))
		GROUP BY  C.[Name]
	)
	AS T
	GROUP BY Category

	SELECT TOP 5 Category,BillTotal
	FROM #Top5CategoryWiseSale
	ORDER BY BillTotal DESC
GO
PRINT 'Created or altered SP GetTop5CategoryWiseSale.';
GO


CREATE OR ALTER PROCEDURE [restaurant].[GetLeast5CategoryWiseSale]
(
 @IsLiveSale     BIT              = NULL,
 @UserID         VARCHAR(MAX)     = NULL,
 @FromDate       VARCHAR(MAX)	  = NULL,
 @ToDate         VARCHAR(MAX)	  = NULL,
 @BranchID       UNIQUEIDENTIFIER	  = NULL
 )
AS

			IF Object_id('TempDB.dbo.#Top5CategoryWiseSale') IS NOT NULL
				BEGIN
					DROP TABLE #Top5CategoryWiseSale
			END

			SELECT Category,SUM(QUANTITY) QUANTITY,SUM(BillTotal)BillTotal
			INTO #Top5CategoryWiseSale
			FROM
			(
			SELECT C.[Name] Category,SUM(Quantity)QUANTITY ,ROUND(SUM(((SD.unitRate* SD.Quantity)-SD.Discount)+(SD.Tax)+(SD.CessAmount)),2) BillTotal
			FROM R_SalesTempMaster SM
			INNER JOIN R_SalesTempDetail SD ON SM.[GuID] = SD.MasterID
			INNER JOIN restaurant.Product PM ON SD.ProductID = PM.[GuID]
			INNER JOIN restaurant.ProductPriceDetail PPD ON PPD.MasterID = PM.[GuID]
			INNER JOIN R_Category C ON PPD.CategoryID = C.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND SM.Cancelled=0 and SM.Deleted=0 AND Refund=0 --AND IsComplementary = 0
			AND SM.BranchID = @BranchID
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))
			GROUP BY C.[Name]

			UNION ALL

			SELECT C.[Name] Category,SUM(Quantity)QUANTITY ,ROUND(SUM(((SD.unitRate* SD.Quantity)-SD.Discount)+(SD.Tax)+(SD.CessAmount)),2) BillTotal
			FROM R_SalesMaster SM
			INNER JOIN R_SalesDetail SD ON SM.[GuID] = SD.MasterID
			INNER JOIN restaurant.Product PM ON SD.ProductID = PM.[GuID]
			INNER JOIN restaurant.ProductPriceDetail PPD ON PPD.MasterID = PM.[GuID]
			INNER JOIN R_Category C ON PPD.CategoryID = C.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND SM.Cancelled=0 and SM.Deleted=0 AND Refund=0 --AND IsComplementary = 0
			AND SM.BranchID = @BranchID
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))
			GROUP BY  C.[Name]
			)
			AS T
			GROUP BY Category


			SELECT TOP 5 Category,BillTotal
			FROM #Top5CategoryWiseSale
			ORDER BY BillTotal ASC
GO
PRINT 'Created or altered SP GetLeast5CategoryWiseSale.';
GO


CREATE OR ALTER PROCEDURE [restaurant].[GetBranchWiseSale]
(
 @IsLiveSale     BIT				  = NULL,
 @FromDate       VARCHAR(MAX)		  = NULL,
 @ToDate         VARCHAR(MAX)		  = NULL,
 @UserGuID         UNIQUEIDENTIFIER	  = NULL
 )
AS
DECLARE @UserID BIGINT = (SELECT [ID] FROM R_User WHERE [GuID] =@UserGuID )

		IF Object_id('TempDB.dbo.#BranchWiseSaleUserID') IS NOT NULL
			BEGIN
				DROP TABLE #BranchWiseSaleUserID
			END

			SELECT ULM.BranchID AS BranchID
			INTO #BranchWiseSaleUserID
			FROM R_User U
			INNER JOIN restaurant.UserLocationMapping ULM ON ULM.UserID = U.[GuID] AND ULM.IsActive = 1
			INNER JOIN R_Branch B ON B.[GuID] = ULM.BranchID
			WHERE U.[GuID] = @UserGuID

			IF Object_id('TempDB.dbo.#BranchWiseSale') IS NOT NULL
				BEGIN
					DROP TABLE #BranchWiseSale
			END

			SELECT Branch,SUM(BillTotal)BillTotal,BranchID
			INTO #BranchWiseSale
			FROM (

			SELECT B.[Name] Branch,(SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff+DelAmount+ContAmount+OtherAmount) BillTotal,BranchID
			FROM R_SalesTempMaster SM
			INNER JOIN R_Branch B ON SM.BranchID = B.[GuID]
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND Cancelled=0 and SM.Deleted=0 AND Refund=0 AND IsComplementary = 0
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))

			UNION ALL

			SELECT B.[Name] Branch,(SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff+DelAmount+ContAmount+OtherAmount) BillTotal,BranchID
			FROM R_SalesMaster SM
			INNER JOIN R_Branch B ON SM.BranchID = B.[GuID]
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND Cancelled=0 and SM.Deleted=0 AND Refund=0 AND IsComplementary = 0
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))
			) AS T
			GROUP BY Branch,BranchID

			IF @UserID = 1
			BEGIN
				SELECT Branch,BillTotal,CAST(IIF(BillTotal=0,0,ROUND((BillTotal*100)/SUM(BillTotal) OVER(),2)) AS DECIMAL(18,2)) AS [Percentage]
				FROM #BranchWiseSale
			END
			ELSE
			BEGIN
				SELECT Branch,BillTotal,CAST(IIF(BillTotal=0,0,ROUND((BillTotal*100)/SUM(BillTotal) OVER(),2)) AS DECIMAL(18,2)) AS [Percentage]
				FROM #BranchWiseSale
				WHERE BranchID IN (SELECT BranchID FROM #BranchWiseSaleUserID)
			END
GO
PRINT 'Created or altered SP GetBranchWiseSale.';
GO


CREATE OR ALTER PROCEDURE [restaurant].[GetBranchWiseSaleTableReport]
(
 @IsLiveSale     BIT				  = NULL,
 @FromDate       VARCHAR(MAX)		  = NULL,
 @ToDate         VARCHAR(MAX)		  = NULL,
 @UserGuID         UNIQUEIDENTIFIER	  = NULL
 )
AS
DECLARE @UserID BIGINT = (SELECT [ID] FROM R_User WHERE [GuID] =@UserGuID )

			IF Object_id('TempDB.dbo.#BranchWiseSaleUserID') IS NOT NULL
			BEGIN
				DROP TABLE #BranchWiseSaleUserID
			END

			SELECT ULM.BranchID AS BranchID
			INTO #BranchWiseSaleUserID
			FROM R_User U
			INNER JOIN restaurant.UserLocationMapping ULM ON ULM.UserID = U.[GuID] AND ULM.IsActive = 1
			INNER JOIN R_Branch B ON B.[GuID] = ULM.BranchID
			WHERE U.[GuID] = @UserGuID


IF Object_id('TempDB.dbo.#BranchWiseSale') IS NOT NULL
				BEGIN
					DROP TABLE #BranchWiseSale
			END

			SELECT TransactionDate,Branch,SUM(BillTotal)BillTotal,SUM([Card])[Card],SUM(Cash)Cash,SUM(Pending)Pending,BranchID
			INTO #BranchWiseSale
			FROM(
			SELECT SM.TransactionDate,B.[Name] Branch,(SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff+DelAmount+ContAmount+OtherAmount) BillTotal
			,SM.[Card],SM.Cash
			,CASE WHEN SM.IsPending  = 1 THEN (SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff)
			ELSE 0 END AS Pending,BranchID
			FROM R_SalesTempMaster SM
			LEFT OUTER JOIN R_Branch B ON SM.BranchID = B.[GuID]
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND Cancelled=0 and SM.Deleted=0 AND Refund=0 AND IsComplementary = 0
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))

			UNION ALL

			SELECT SM.TransactionDate,B.[Name] Branch,(SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff+DelAmount+ContAmount+OtherAmount) BillTotal
			,SM.[Card],SM.Cash,CASE WHEN SM.IsPending  = 1 THEN (SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff)
			ELSE 0 END AS Pending,BranchID
			FROM R_SalesMaster SM
			LEFT OUTER JOIN R_Branch B ON SM.BranchID = B.[GuID]
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID]
			WHERE  CAST(TransactionDate AS DATE) BETWEEN COALESCE(@FromDate,TransactionDate) AND COALESCE(@ToDate,TransactionDate)
			AND Cancelled=0 and SM.Deleted=0 AND Refund=0 AND IsComplementary = 0
			AND (@IsLiveSale IS NULL OR (@IsLiveSale = 1 AND SM.IsPending = 1) OR (@IsLiveSale = 0 AND SM.IsPending = 0))
			) AS T
			GROUP BY TransactionDate,Branch,BranchID

			IF @UserID = 1
			BEGIN
				SELECT TransactionDate,Branch,BillTotal,[Card],Cash,Pending,SUM(BillTotal)TotalBillAmount,CAST(IIF(BillTotal=0,0,ROUND((BillTotal*100)/SUM(BillTotal) OVER(),2)) AS DECIMAL(18,2))
				PERCENTAGE
				INTO #BranchWiseSaleSystem
				FROM #BranchWiseSale
				GROUP BY TransactionDate,Branch,BillTotal,[Card],Cash,Pending

				SELECT TransactionDate,Branch,BillTotal,[Card],Cash,Pending,(SELECT SUM(TotalBillAmount) FROM #BranchWiseSaleSystem)TotalBillAmount
				,CAST(IIF(BillTotal=0,0,ROUND((BillTotal*100)/SUM(BillTotal) OVER(),2)) AS DECIMAL(18,2))
				[PERCENTAGE]
				FROM #BranchWiseSale
				GROUP BY TransactionDate,Branch,BillTotal,[Card],Cash,Pending
				ORDER BY TransactionDate
			END
			ELSE
			BEGIN
				SELECT TransactionDate,Branch,BillTotal,[Card],Cash,Pending,SUM(BillTotal)TotalBillAmount,CAST(IIF(BillTotal=0,0,ROUND((BillTotal*100)/SUM(BillTotal) OVER(),2)) AS DECIMAL(18,2))
				[PERCENTAGE]
				INTO #BranchWiseSaleUser
				FROM #BranchWiseSale
				WHERE BranchID IN (SELECT BranchID FROM #BranchWiseSaleUserID)
				GROUP BY TransactionDate,Branch,BillTotal,[Card],Cash,Pending
				ORDER BY TransactionDate

				SELECT TransactionDate,Branch,BillTotal,[Card],Cash,Pending,(SELECT SUM(TotalBillAmount) FROM #BranchWiseSaleUser)TotalBillAmount
				,CAST(IIF(BillTotal=0,0,ROUND((BillTotal*100)/SUM(BillTotal) OVER(),2)) AS DECIMAL(18,2))
				[PERCENTAGE]
				FROM #BranchWiseSale
				GROUP BY TransactionDate,Branch,BillTotal,[Card],Cash,Pending
				ORDER BY TransactionDate
			END
GO
PRINT 'Created or altered SP GetBranchWiseSaleTableReport.';
GO

-- ============================================================
-- Phase 1 fix (continued): @StatusType was computed per-row but
-- silently discarded by a hardcoded final WHERE clause in these
-- three procs. Restoring it as a real filter, NULL = today's
-- default (unchanged: RunningOrder+Completed / Not Deleted).
-- ============================================================

CREATE OR ALTER PROCEDURE [restaurant].[Report_SalesReport]
(
 @IsDayClosed    INT		  = NULL,
 @CounterID      VARCHAR(MAX) = NULL,
 @SectionID      VARCHAR(MAX) = NULL,
 @UserID         VARCHAR(MAX) = NULL,
 @PaymentType    VARCHAR(MAX) = NULL,
 @PaymentCardID  VARCHAR(MAX) = NULL,
 @FromDate       DATE	  = NULL,
 @ToDate         DATE	  = NULL,
 @StatusType     VARCHAR(MAX) = NULL

 --@FinYearID    VARCHAR(MAX) = NULL,
 --@BranchID     VARCHAR(MAX) = NULL
 )
AS
BEGIN
---RE DECLARING---
	DECLARE
	     @R_IsDayClosed     INT					 = @IsDayClosed,
		 @R_CounterID       VARCHAR(MAX)		 = @CounterID,
		 @R_SectionID       VARCHAR(MAX)		 = @SectionID,
		 @R_UserID          VARCHAR(MAX)		 = @UserID,
		 @R_PaymentType       VARCHAR(MAX)		 = @PaymentType,
		 @R_PaymentCardID      VARCHAR(MAX)		 = @PaymentCardID,
		 @R_FromDate        DATE				 = @FromDate,
		 @R_ToDate          DATE				 = @ToDate,
		 @R_StatusType         VARCHAR(MAX)		 = @StatusType,
         @VatEnabled bit = (Select CASE WHEN Value = 'True' THEN 1 ELSE 0 END AS Value from R_Settings where [Key] = 'IsVATEnabled')
	DECLARE @Format VARCHAR(50)= (Select Value from R_Settings where [Key] = 'CurrencyFormat')

	SET ARITHABORT ON
	SET XACT_ABORT ON

	SET NOCOUNT ON

	SET @R_ToDate = DATEADD(D, 1, @R_ToDate);

	IF Object_id('TempDB.dbo.#SalesReport') IS NOT NULL
	BEGIN
		DROP TABLE #SalesReport
	END
	------BEGIN OF DETAIL SECTION-----
	SELECT *
	INTO #SalesReport
	FROM
	(
	SELECT SM.[No],SM.BillNo BillNo,SM.TransactionDate, SM.BillTime AS BillDate
	,CASE WHEN [Card]>0.00 AND [Cash]=0.00 AND CustomerCredit = 0 THEN 'Card'
	      WHEN CustomerCredit > 0 AND [Card] =0.00 AND [Cash]=0.00 THEN 'Credit'
		  WHEN [Cash]>0.00 AND [Card]>0.00 OR [Cash]>0.00 AND CustomerCredit>0.00 OR [Card]>0.00 AND CustomerCredit>0.00 THEN 'MultiPayment'
		  WHEN ComplementaryTotal>0 THEN 'Complementary' when IsPending=1 then 'None'
		  ELSE 'Cash' END AS PaymentType
   ,CASE WHEN CardID IS NOT NULL THEN PC.CardName
		WHEN CardID IS NULL AND Cash=0.00 THEN 'Card'
		ELSE 'Cash' END AS PaymentCard
	,SM.RTotal AS RateTotal
	,CASE WHEN @VatEnabled = 0 THEN 0 ELSE SM.Tax  END AS VatAmount
	,CASE WHEN @VatEnabled = 1 THEN 0 ELSE SM.Tax END AS TaxAmount
	,(SM.Discount+ISNULL(SM.ProdDiscount,0)) [Discount]
	,SM.RoundOff RoundOff
	,CASE WHEN ComplementaryTotal>0 THEN '0.00'
	ELSE ((SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff + ISNULL(DelAmount+ContAmount+OtherAmount,0)))END AS NetTotal
	,SM.Cash AS CashTotal
	,SM.[Card]AS CardTotal,C.Name [Counter], S.Name Section, B.Name AS Location
	,U.Name AS Waiter
	,CASE WHEN SM.Deleted= 1 AND SM.Merged= 0 THEN 'Deleted'
			WHEN Refund = 1 THEN 'Refund'
			WHEN Cancelled = 1 AND SM.Merged = 0 THEN 'Cancelled'
			WHEN SM.Merged = 1 THEN 'Merged'
			--WHEN IsComplementary = 1 THEN 'Complementary'
			WHEN IsPending = 0 AND SM.Deleted= 0 AND Refund = 0 AND Cancelled = 0 AND SM.Merged = 0 THEN 'Completed'
			ELSE 'RunningOrder' END AS [Status]
    ,CancelReason,CardNo,CM.[Name] as Customer
	,ISNULL(DelAmount+ContAmount+OtherAmount,0) AS OtherCharges
	FROM R_SalesMaster SM
		LEFT OUTER JOIN R_Section S on S.[GuID] = SM.SectionID
		LEFT OUTER JOIN R_Counter C on C.[GuID] = SM.CounterID
		LEFT OUTER JOIN R_Branch B ON B.[GuID] = SM.BranchID
		LEFT OUTER JOIN R_PaymentCards PC ON SM.CardID = PC.[GuID]
		LEFT OUTER JOIN R_User U on U.[GuID]= SM.WaiterID
		LEFT OUTER JOIN R_Customer CM ON CM.[GuID] = SM.CustomerID
		LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID] AND MSA.Merged = 0
	WHERE (SM.CounterID=@R_CounterID OR @R_CounterID IS NULL)
		AND (S.[GuID]= @R_SectionID OR @R_SectionID IS NULL)
		AND (SM.WaiterID = @R_UserID OR @R_UserID IS NULL)
		AND (SM.CardID = @R_PaymentCardID OR @R_PaymentCardID IS NULL)
		AND (SM.TransactionDate>=@R_FromDate OR @R_FromDate IS NULL) and (SM.TransactionDate<@R_ToDate OR @R_ToDate IS NULL)

		UNION ALL

		SELECT SM.[No],SM.BillNo BillNo,SM.TransactionDate, SM.BillTime AS BillDate
	,CASE WHEN [Card]>0.00 AND [Cash]=0.00 AND CustomerCredit = 0 THEN 'Card'
	      WHEN CustomerCredit > 0 AND [Card] =0.00 AND [Cash]=0.00 THEN 'Credit'
		  WHEN [Cash]>0.00 AND [Card]>0.00 OR [Cash]>0.00 AND CustomerCredit>0.00 OR [Card]>0.00 AND CustomerCredit>0.00 THEN 'MultiPayment'
		  WHEN ComplementaryTotal>0 THEN 'Complementary' when IsPending=1 then 'None'
		  ELSE 'Cash' END AS PaymentType
   ,CASE WHEN CardID IS NOT NULL THEN PC.CardName
		WHEN CardID IS NULL AND Cash=0.00 THEN 'Card'
		ELSE 'Cash' END AS PaymentCard
	,SM.RTotal AS RateTotal
	,CASE WHEN @VatEnabled = 0 THEN 0 ELSE SM.Tax  END AS VatAmount
	,CASE WHEN @VatEnabled = 1 THEN 0 ELSE SM.Tax END AS TaxAmount
	,(SM.Discount+ISNULL(SM.ProdDiscount,0)) [Discount]
	,SM.RoundOff RoundOff
	,CASE WHEN ComplementaryTotal>0 THEN '0.00'
	ELSE ((SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff + ISNULL(DelAmount+ContAmount+OtherAmount,0)))END AS NetTotal
	,SM.Cash AS CashTotal
	,SM.[Card]AS CardTotal,C.Name [Counter], S.Name Section, B.Name AS Location
	,U.Name AS Waiter
	,CASE WHEN SM.Deleted= 1 AND SM.Merged= 0 THEN 'Deleted'
			WHEN Refund = 1 THEN 'Refund'
			WHEN Cancelled = 1 AND SM.Merged = 0 THEN 'Cancelled'
			WHEN SM.Merged = 1 THEN 'Merged'
			--WHEN IsComplementary = 1 THEN 'Complementary'
			WHEN IsPending = 0 AND SM.Deleted= 0 AND Refund = 0 AND Cancelled = 0 AND SM.Merged = 0  THEN 'Completed'
			ELSE 'RunningOrder' END AS [Status]
    ,CancelReason,CardNo,CM.[Name] as Customer
	,ISNULL(DelAmount+ContAmount+OtherAmount,0) AS OtherCharges
	FROM R_SalesTempMaster SM
		LEFT OUTER JOIN R_Section S on S.[GuID] = SM.SectionID
		LEFT OUTER JOIN R_Counter C on C.[GuID] = SM.CounterID
		LEFT OUTER JOIN R_Branch B ON B.[GuID] = SM.BranchID
		LEFT OUTER JOIN R_PaymentCards PC ON SM.CardID = PC.[GuID]
		LEFT OUTER JOIN R_User U on U.[GuID]= SM.WaiterID
		LEFT OUTER JOIN R_Customer CM ON CM.[GuID] = SM.CustomerID
		LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID] AND MSA.Merged = 0
	WHERE (SM.CounterID=@R_CounterID OR @R_CounterID IS NULL)
	    AND (S.[GuID]= @R_SectionID OR @R_SectionID IS NULL)
		AND (SM.WaiterID = @R_UserID OR @R_UserID IS NULL)
	    AND (SM.CardID = @R_PaymentCardID OR @R_PaymentCardID IS NULL)
		AND (SM.TransactionDate>=@R_FromDate OR @R_FromDate IS NULL) and (SM.TransactionDate<@R_ToDate OR @R_ToDate IS NULL)
		) AS SalesDetail
		WHERE ([Status] = @R_StatusType OR (ISNULL(@R_StatusType,'') = '' AND [Status] in ('RunningOrder','Completed'))) AND (PaymentType= @R_PaymentType OR @R_PaymentType IS NULL)

	SELECT * FROM #SalesReport AS ReportDetail
	ORDER BY TransactionDate,[No]
	------END OF DETAIL SECTION-----

	SELECT '' AS [No],'' AS BillNo,'' AS TransactionDate,'' AS BillDate,'Cash' AS PaymentType,'Cash' AS PaymentCard
	,FORMAT(SUM(RateTotal),@Format)RateTotal
	,FORMAT(SUM(VatAmount),@Format)VatAmount
	,FORMAT(SUM(TaxAmount),@Format)TaxAmount
	,FORMAT(SUM(Discount),@Format)Discount
	,FORMAT(SUM(RoundOff),@Format)RoundOff
	,FORMAT(SUM(NetTotal),@Format)NetTotal
	,FORMAT(SUM(CashTotal),@Format)CashTotal
	,FORMAT(SUM(CardTotal),@Format)CardTotal
	,SUM(OtherCharges)OtherCharges
	,'' AS [Counter],'' AS Section,'' AS [Location],'' AS Waiter,'Completed' AS [Status],'' AS CancelReason,'' AS CardNo,'' AS Customer
	FROM #SalesReport

	IF Object_id('TempDB.dbo.#SalesReport') IS NOT NULL
	BEGIN
		DROP TABLE #SalesReport
	END

	SET NOCOUNT OFF

END
GO
PRINT 'Created or altered SP Report_SalesReport.';
GO


CREATE OR ALTER PROCEDURE [restaurant].[Report_SalesReportPaging]
(
 @IsDayClosed			 INT		  = NULL,
 @CounterID				 VARCHAR(MAX) = NULL,
 @SectionID				 VARCHAR(MAX) = NULL,
 @UserID				 VARCHAR(MAX) = NULL,
 @PaymentType			 VARCHAR(MAX) = NULL,
 @PaymentCardID			 VARCHAR(MAX) = NULL,
 @FromDate				 DATE		  = NULL,
 @ToDate				 DATE		  = NULL,
 @StatusType			 VARCHAR(MAX) = NULL,
 @PageNumber			 INT          = NULL,
 @PageSize				 INT          = NULL,
 @SortingColumn			 VARCHAR(MAX) = NULL,
 @SortingDirection		 VARCHAR(MAX) = NULL,
 @BranchID				 VARCHAR(MAX) = NULL

 )
AS
BEGIN
---RE DECLARING---
	DECLARE
	     @R_IsDayClosed      INT				 = @IsDayClosed,
		 @R_CounterID        VARCHAR(MAX)		 = @CounterID,
		 @R_SectionID        VARCHAR(MAX)		 = @SectionID,
		 @R_UserID           VARCHAR(MAX)		 = @UserID,
		 @R_PaymentType      VARCHAR(MAX)		 = @PaymentType,
		 @R_PaymentCardID    VARCHAR(MAX)		 = @PaymentCardID,
		 @R_FromDate         DATE				 = @FromDate,
		 @R_ToDate           DATE				 = @ToDate,
		 @R_StatusType       VARCHAR(MAX)		 = @StatusType,
         @VatEnabled		 BIT = (Select CASE WHEN Value = 'True' THEN 1 ELSE 0 END AS Value from R_Settings where [Key] = 'IsVATEnabled'),
		 @R_PageNumber		 INT				 = @PageNumber,
         @R_PageSize		 INT				 = @PageSize,
         @R_SortingColumn    VARCHAR(MAX)        = @SortingColumn,
         @R_SortingDirection VARCHAR(MAX)        = @SortingDirection,
		 @R_BranchID        VARCHAR(MAX)		 = @BranchID
	DECLARE @SortingCmd VARCHAR(MAX)

	SET ARITHABORT ON
	SET XACT_ABORT ON

	SET NOCOUNT ON


	SET @R_ToDate = DATEADD(D, 1, @R_ToDate);

	IF Object_id('TempDB.dbo.#SalesReport') IS NOT NULL
	BEGIN
		DROP TABLE #SalesReport
	END

	IF Object_id('TempDB.dbo.#SalesReportCount') IS NOT NULL
	BEGIN
		DROP TABLE #SalesReportCount
	END

	------BEGIN SELECT FOR SALES REPORT-----
SELECT *
	INTO #SalesReport
	FROM
	(
		 SELECT SM.[No],SM.BillNo BillNo,SM.TransactionDate, SM.BillTime AS BillDate
		,CASE WHEN [Card]>0.00 AND [Cash]=0.00 AND CustomerCredit = 0 THEN 'Card'
			  WHEN CustomerCredit > 0 AND [Card] =0.00 AND [Cash]=0.00 THEN 'Credit'
			  WHEN [Cash]>0.00 AND [Card]>0.00 OR [Cash]>0.00 AND CustomerCredit>0.00 OR [Card]>0.00 AND CustomerCredit>0.00 THEN 'MultiPayment'
			  WHEN ComplementaryTotal>0 THEN 'Complementary' when IsPending=1 then 'None'
			  ELSE 'Cash' END AS PaymentType
	   ,CASE WHEN CardID IS NOT NULL THEN PC.CardName
			 WHEN [Cash]>0.00 AND [Card]=0.00 AND CustomerCredit = 0 THEN 'Cash'
			 WHEN [Card]>0.00 AND [Cash]=0.00 AND CustomerCredit = 0 THEN 'Card'
			 WHEN CustomerCredit > 0 AND [Card] =0.00 AND [Cash]=0.00 THEN 'Credit'
			  WHEN [Cash]>0.00 AND [Card]>0.00 OR [Cash]>0.00 AND CustomerCredit>0.00 OR [Card]>0.00 AND CustomerCredit>0.00 THEN 'MultiPayment'
			 ELSE 'None' END AS PaymenCardType
		,SM.RTotal AS RateTotal
		,CASE WHEN @VatEnabled = 0 THEN 0 ELSE SM.Tax  END AS VatAmount
		,CASE WHEN @VatEnabled = 1 THEN 0 ELSE SM.Tax END AS TaxAmount
		,(SM.Discount+ISNULL(SM.ProdDiscount,0)) [Discount]
		,SM.RoundOff RoundOff
		,CASE WHEN ComplementaryTotal>0 THEN '0.00'
		ELSE ((SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff + ISNULL(DelAmount+ContAmount+OtherAmount,0)))END AS NetTotal
		,SM.Cash AS CashTotal
		,SM.[Card]AS CardTotal,C.Name [Counter], S.Name Section, B.Name AS Branch
		,U.Name AS [User]
		,CASE WHEN SM.Deleted= 1 AND SM.Merged= 0 THEN 'Deleted'
				WHEN Refund = 1 THEN 'Refund'
				WHEN Cancelled = 1 AND SM.Merged = 0 THEN 'Cancelled'
				WHEN SM.Merged = 1 THEN 'Merged'
				--WHEN IsComplementary = 1 THEN 'Complementary'
				WHEN IsPending = 0 AND SM.Deleted= 0 AND Refund = 0 AND Cancelled = 0 AND SM.Merged = 0 THEN 'Completed'
				ELSE 'RunningOrder' END AS [SalesStatus]
		,CancelReason AS Reason,CardNo,CM.[Name] as Customer
		,ISNULL(DelAmount+ContAmount+OtherAmount,0) AS OtherCharges
		FROM R_SalesMaster SM
			LEFT OUTER JOIN restaurant.Section S on S.[GuID] = SM.SectionID
			LEFT OUTER JOIN R_Counter C on C.[GuID] = SM.CounterID
			LEFT OUTER JOIN R_Branch B ON B.[GuID] = SM.BranchID
			LEFT OUTER JOIN R_PaymentCards PC ON SM.CardID = PC.[GuID]
			LEFT OUTER JOIN R_User U on U.[GuID]= SM.WaiterID
			LEFT OUTER JOIN R_Customer CM ON CM.[GuID] = SM.CustomerID
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID] AND MSA.Merged = 0
		WHERE (SM.CounterID=@R_CounterID OR @R_CounterID IS NULL)
			AND (S.[GuID]= @R_SectionID OR @R_SectionID IS NULL)
			AND (SM.WaiterID = @R_UserID OR @R_UserID IS NULL)
			AND (SM.CardID = @R_PaymentCardID OR @R_PaymentCardID IS NULL)
			AND (SM.TransactionDate>=@R_FromDate OR @R_FromDate IS NULL) and (SM.TransactionDate<@R_ToDate OR @R_ToDate IS NULL)
			AND (SM.BranchID = @R_BranchID OR @R_BranchID IS NULL)

			UNION ALL

		SELECT SM.[No],SM.BillNo BillNo,SM.TransactionDate, SM.BillTime AS BillDate
		,CASE WHEN [Card]>0.00 AND [Cash]=0.00 AND CustomerCredit = 0 THEN 'Card'
			  WHEN CustomerCredit > 0 AND [Card] =0.00 AND [Cash]=0.00 THEN 'Credit'
			  WHEN [Cash]>0.00 AND [Card]>0.00 OR [Cash]>0.00 AND CustomerCredit>0.00 OR [Card]>0.00 AND CustomerCredit>0.00 THEN 'MultiPayment'
			  WHEN ComplementaryTotal>0 THEN 'Complementary' when IsPending=1 then 'None'
			  ELSE 'Cash' END AS PaymentType
	   ,CASE WHEN CardID IS NOT NULL THEN PC.CardName
			WHEN CardID IS NULL AND Cash=0.00 THEN 'Card'
			ELSE 'Cash' END AS PaymenCardType
		,SM.RTotal AS RateTotal
		,CASE WHEN @VatEnabled = 0 THEN 0 ELSE SM.Tax  END AS VatAmount
		,CASE WHEN @VatEnabled = 1 THEN 0 ELSE SM.Tax END AS TaxAmount
		,(SM.Discount+ISNULL(SM.ProdDiscount,0)) [Discount]
		,SM.RoundOff RoundOff
		,CASE WHEN ComplementaryTotal>0 THEN '0.00'
		ELSE ((SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff + ISNULL(DelAmount+ContAmount+OtherAmount,0)))END AS NetTotal
		,SM.Cash AS CashTotal
		,SM.[Card]AS CardTotal,C.Name [Counter], S.Name Section, B.Name AS Branch
		,U.Name AS [User]
		,CASE WHEN SM.Deleted= 1 AND SM.Merged= 0 THEN 'Deleted'
				WHEN Refund = 1 THEN 'Refund'
				WHEN Cancelled = 1 AND SM.Merged = 0 THEN 'Cancelled'
				WHEN SM.Merged = 1 THEN 'Merged'
				--WHEN IsComplementary = 1 THEN 'Complementary'
				WHEN IsPending = 0 AND SM.Deleted= 0 AND Refund = 0 AND Cancelled = 0 AND SM.Merged = 0 THEN 'Completed'
				ELSE 'RunningOrder' END AS [SalesStatus]
		,CancelReason AS Reason,CardNo,CM.[Name] as Customer
		,ISNULL(DelAmount+ContAmount+OtherAmount,0) AS OtherCharges
		FROM R_SalesTempMaster SM
			LEFT OUTER JOIN restaurant.Section S on S.[GuID] = SM.SectionID
			LEFT OUTER JOIN R_Counter C on C.[GuID] = SM.CounterID
			LEFT OUTER JOIN R_Branch B ON B.[GuID] = SM.BranchID
			LEFT OUTER JOIN R_PaymentCards PC ON SM.CardID = PC.[GuID]
			LEFT OUTER JOIN R_User U on U.[GuID]= SM.WaiterID
			LEFT OUTER JOIN R_Customer CM ON CM.[GuID] = SM.CustomerID
			LEFT OUTER JOIN [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID] AND MSA.Merged = 0
		WHERE (SM.CounterID=@R_CounterID OR @R_CounterID IS NULL)
			AND (S.[GuID]= @R_SectionID OR @R_SectionID IS NULL)
			AND (SM.WaiterID = @R_UserID OR @R_UserID IS NULL)
			AND (SM.CardID = @R_PaymentCardID OR @R_PaymentCardID IS NULL)
			AND (SM.TransactionDate>=@R_FromDate OR @R_FromDate IS NULL) and (SM.TransactionDate<@R_ToDate OR @R_ToDate IS NULL)
			AND (SM.BranchID = @R_BranchID OR @R_BranchID IS NULL)

		) AS SalesDetail
		WHERE ([SalesStatus] = @R_StatusType OR (ISNULL(@R_StatusType,'') = '' AND [SalesStatus] in ('RunningOrder','Completed'))) AND (PaymentType= @R_PaymentType OR @R_PaymentType IS NULL)

	SELECT COUNT(*) AS SalesCount
		INTO #SalesReportCount
		FROM #SalesReport

	IF @PageSize = -1
	BEGIN
		IF @R_SortingColumn IS NULL
			BEGIN
				SELECT @SortingCmd = '
					SELECT *,(SELECT SalesCount FROM #SalesReportCount)[RowCount]
					FROM #SalesReport
					ORDER BY TransactionDate '+ @R_SortingDirection+',Section '+ @R_SortingDirection+',[No] '+ @R_SortingDirection+''
				EXEC (@SortingCmd)
			END
		ELSE
			BEGIN
				SELECT @SortingCmd = '
					SELECT *,(SELECT SalesCount FROM #SalesReportCount)[RowCount] ,[No] AS [No1], TransactionDate AS TransactionDate1,Section AS Section1
					FROM #SalesReport
					ORDER BY  ' + @R_SortingColumn +' '+ @R_SortingDirection+',TransactionDate1 asc,Section1 asc,[No1] asc'
				EXEC (@SortingCmd)
			END
		END

	ELSE
	BEGIN
		IF @R_SortingColumn IS NULL
			BEGIN
				SELECT @SortingCmd = '
					SELECT *,(SELECT SalesCount FROM #SalesReportCount)[RowCount]
					FROM #SalesReport
					ORDER BY TransactionDate '+ @R_SortingDirection+',Section '+ @R_SortingDirection+',[No] '+ @R_SortingDirection+'
					OFFSET (' + CAST(@R_PageNumber - 1 AS NVARCHAR(MAX)) + ')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS
					FETCH NEXT ' + CAST(@R_PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY'
				EXEC (@SortingCmd)
			END
		ELSE
			BEGIN
				SELECT @SortingCmd = '
					SELECT *,(SELECT SalesCount FROM #SalesReportCount)[RowCount] ,[No] AS [No1], TransactionDate AS TransactionDate1,Section AS Section1
					FROM #SalesReport
					ORDER BY  ' + @R_SortingColumn +' '+ @R_SortingDirection+',TransactionDate1 asc,Section1 asc,[No1] asc
					OFFSET (' + CAST(@R_PageNumber - 1 AS NVARCHAR(MAX)) + ')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS
					FETCH NEXT ' + CAST(@R_PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY'
				EXEC (@SortingCmd)
		END
		END

		------ FOR GETTING FOOTER TOTAL---------------------
		SELECT '' AS [No],'' AS BillNo,'' AS TransactionDate,'' AS BillDate,'Cash' AS PaymentType,'Cash' AS PaymenCardType
		,SUM(RateTotal)RateTotal,SUM(VatAmount)VatAmount,SUM(TaxAmount)TaxAmount,SUM(Discount)Discount
		,SUM(RoundOff)RoundOff,SUM(NetTotal)NetTotal,SUM(CashTotal)CashTotal,SUM(CardTotal)CardTotal
		,'' AS [Counter],'' AS Section,'' AS [Branch],'' AS [User],'Completed' AS [SalesStatus],'' AS Reason,'' AS CardNo,'' AS Customer
		,SUM(OtherCharges)OtherCharges
		FROM #SalesReport

	------END OF DETAIL SECTION-----

	IF Object_id('TempDB.dbo.#SalesReport') IS NOT NULL
	BEGIN
		DROP TABLE #SalesReport
	END

	IF Object_id('TempDB.dbo.#SalesReportCount') IS NOT NULL
	BEGIN
		DROP TABLE #SalesReportCount
	END

	SET NOCOUNT OFF

	END
GO
PRINT 'Created or altered SP Report_SalesReportPaging.';
GO


CREATE OR ALTER PROCEDURE [restaurant].[Report_SalesReportConsolPaging]
(
 @IsDayClosed			 INT		  = NULL,
 @CounterID				 VARCHAR(MAX) = NULL,
 @SectionID				 VARCHAR(MAX) = NULL,
 @UserID				 VARCHAR(MAX) = NULL,
 @PaymentType			 VARCHAR(MAX) = NULL,
 @PaymentCardID			 VARCHAR(MAX) = NULL,
 @FromDate				 DATE		  = NULL,
 @ToDate				 DATE		  = NULL,
 @StatusType			 VARCHAR(MAX) = NULL,
 @PageNumber			 INT          = NULL,
 @PageSize				 INT          = NULL,
 @SortingColumn			 VARCHAR(MAX) = NULL,
 @SortingDirection		 VARCHAR(MAX) = NULL,
 @BranchID				 VARCHAR(MAX) = NULL

 )
AS
BEGIN
---RE DECLARING---
	DECLARE
	     @R_IsDayClosed      INT				 = @IsDayClosed,
		 @R_CounterID        VARCHAR(MAX)		 = @CounterID,
		 @R_SectionID        VARCHAR(MAX)		 = @SectionID,
		 @R_UserID           VARCHAR(MAX)		 = @UserID,
		 @R_PaymentType      VARCHAR(MAX)		 = @PaymentType,
		 @R_PaymentCardID    VARCHAR(MAX)		 = @PaymentCardID,
		 @R_FromDate         DATE				 = @FromDate,
		 @R_ToDate           DATE				 = @ToDate,
		 @R_StatusType       VARCHAR(MAX)		 = @StatusType,
         @VatEnabled		 BIT = (Select CASE WHEN Value = 'True' THEN 1 ELSE 0 END AS Value from R_Settings where [Key] = 'IsVATEnabled'),
		 @R_PageNumber		 INT				 = @PageNumber,
         @R_PageSize		 INT				 = @PageSize,
         @R_SortingColumn    VARCHAR(MAX)        = @SortingColumn,
         @R_SortingDirection VARCHAR(MAX)        = @SortingDirection,
		 @R_BranchID        VARCHAR(MAX)		 = @BranchID
	DECLARE @SortingCmd VARCHAR(MAX)

	SET ARITHABORT ON
	SET XACT_ABORT ON

	SET NOCOUNT ON

		 SET @R_ToDate = DATEADD(D, 1, @R_ToDate);


	IF Object_id('TempDB.dbo.#SalesReportCons') IS NOT NULL
	BEGIN
		DROP TABLE #SalesReportCons
	END

	IF Object_id('TempDB.dbo.#SalesReportCountCons') IS NOT NULL
	BEGIN
		DROP TABLE #SalesReportCountCons
	END

	------BEGIN SELECT FOR SALES REPORT-----
SELECT *
	INTO #SalesReportCons
	FROM
	(
		SELECT      restaurant.Section.Name AS SectionName, dbo.R_Branch.Name AS BranchName, SM.TransactionDate AS TransactionDate,
				SUM(SM.Total) AS Total, SUM(SM.RTotal) AS R_Total, Sum(SM.Tax) AS TaxAmount, SUM(SM.Cash) AS CashTotal, SUM(SM.Card) as CardTotal,
				SUM(SM.CustomerCredit) as Credit, SUM(SM.Discount) as Discount,
								 SM.Refund, SM.Cancelled, SUM(ISNULL(DelAmount+ContAmount+OtherAmount,0)) as Extra,
								 SUM(SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff + ISNULL(DelAmount+ContAmount+OtherAmount,0)) as NETTOTAL,
			  CASE WHEN [Card]>0.00 AND [Cash]=0.00 AND CustomerCredit = 0 THEN 'Card'
			  WHEN CustomerCredit > 0 AND [Card] =0.00 AND [Cash]=0.00 THEN 'Credit'
			  WHEN [Cash]>0.00 AND [Card]>0.00 OR [Cash]>0.00 AND CustomerCredit>0.00 OR [Card]>0.00 AND CustomerCredit>0.00 THEN 'MultiPayment'
			  WHEN ComplementaryTotal>0 THEN 'Complementary' when IsPending=1 then 'None'
			  ELSE 'Cash' END AS PaymentType,
			  CASE WHEN SM.Deleted= 1 AND SM.Merged= 0 THEN 'Deleted'
				WHEN Refund = 1 THEN 'Refund'
				WHEN Cancelled = 1 AND SM.Merged = 0 THEN 'Cancelled'
				WHEN SM.Merged = 1 THEN 'Merged'
				--WHEN IsComplementary = 1 THEN 'Complementary'
				WHEN IsPending = 0 AND SM.Deleted= 0 AND Refund = 0 AND Cancelled = 0 AND SM.Merged = 0 THEN 'Completed'
				ELSE 'RunningOrder' END AS [SalesStatus]

		FROM            dbo.R_Branch INNER JOIN
								 dbo.R_SalesTempMaster AS SM ON dbo.R_Branch.GuID = SM.BranchID LEFT OUTER JOIN
								 [dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID] AND MSA.Merged = 0 INNER JOIN
								  restaurant.Section ON SM.SectionID =  restaurant.Section.GuID
			WHERE (SM.TransactionDate>=@R_FromDate) and (SM.TransactionDate<@R_ToDate)
		GROUP BY  restaurant.Section.Name, dbo.R_Branch.Name, SM.TransactionDate, SM.Refund, SM.Cancelled,
		SM.IsPending, ComplementaryTotal, CustomerCredit, Card, Cash, SM.Deleted, SM.Merged
			UNION ALL

		SELECT      restaurant.Section.Name AS SectionName, dbo.R_Branch.Name AS BranchName, SM.TransactionDate AS TransactionDate,
				SUM(SM.Total) AS Total, SUM(SM.RTotal) AS R_Total, Sum(SM.Tax) AS TaxAmount, SUM(SM.Cash) AS CashTotal, SUM(SM.Card) as CardTotal,
				SUM(SM.CustomerCredit) as Credit, SUM(SM.Discount) as Discount,
									SM.Refund, SM.Cancelled, SUM(ISNULL(DelAmount+ContAmount+OtherAmount,0)) as Extra,
									SUM(SM.Total+SM.Tax+SM.CessAmount- SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff + ISNULL(DelAmount+ContAmount+OtherAmount,0)) as NETTOTAL,
			  CASE WHEN [Card]>0.00 AND [Cash]=0.00 AND CustomerCredit = 0 THEN 'Card'
			  WHEN CustomerCredit > 0 AND [Card] =0.00 AND [Cash]=0.00 THEN 'Credit'
			  WHEN [Cash]>0.00 AND [Card]>0.00 OR [Cash]>0.00 AND CustomerCredit>0.00 OR [Card]>0.00 AND CustomerCredit>0.00 THEN 'MultiPayment'
			  WHEN ComplementaryTotal>0 THEN 'Complementary' when IsPending=1 then 'None'
			  ELSE 'Cash' END AS PaymentType,
			  CASE WHEN SM.Deleted= 1 AND SM.Merged= 0 THEN 'Deleted'
				WHEN Refund = 1 THEN 'Refund'
				WHEN Cancelled = 1 AND SM.Merged = 0 THEN 'Cancelled'
				WHEN SM.Merged = 1 THEN 'Merged'
				--WHEN IsComplementary = 1 THEN 'Complementary'
				WHEN IsPending = 0 AND SM.Deleted= 0 AND Refund = 0 AND Cancelled = 0 AND SM.Merged = 0 THEN 'Completed'
				ELSE 'RunningOrder' END AS [SalesStatus]
		FROM            dbo.R_Branch INNER JOIN
									dbo.R_SalesMaster AS SM ON dbo.R_Branch.GuID = SM.BranchID LEFT OUTER JOIN
									[dbo].[R_MiscellaneousSalesAmount] MSA ON MSA.MasterID = SM.[GuID] AND MSA.Merged = 0 INNER JOIN
									 restaurant.Section ON SM.SectionID =  restaurant.Section.GuID
		WHERE (SM.TransactionDate>=@R_FromDate) and (SM.TransactionDate<@R_ToDate)
		GROUP BY  restaurant.Section.Name, dbo.R_Branch.Name, SM.TransactionDate, SM.Refund, SM.Cancelled,
		SM.IsPending, ComplementaryTotal, CustomerCredit, Card, Cash, SM.Deleted, SM.Merged
			) AS SalesDetail
			WHERE ([SalesStatus] = @R_StatusType OR (ISNULL(@R_StatusType,'') = '' AND [SalesStatus] NOT IN ('Deleted')))



	SELECT COUNT(*) AS SalesCount
		INTO #SalesReportCountCons
		FROM #SalesReportCons

	IF @PageSize = -1
	BEGIN
		IF @R_SortingColumn IS NULL
			BEGIN
				SELECT @SortingCmd = '
					SELECT *,(SELECT SalesCount FROM #SalesReportCountCons)[RowCount]
					FROM #SalesReportCons
					ORDER BY TransactionDate '+ @R_SortingDirection+',SectionName '+ @R_SortingDirection+',[BranchName] '+ @R_SortingDirection+''
				EXEC (@SortingCmd)
			END
		ELSE
			BEGIN
				SELECT @SortingCmd = '
					SELECT *,(SELECT SalesCount FROM #SalesReportCountCons)[RowCount] ,[BranchName] AS [BranchName1], TransactionDate AS TransactionDate1,SectionName AS Section1
					FROM #SalesReportCons
					ORDER BY  ' + @R_SortingColumn +' '+ @R_SortingDirection+',TransactionDate1 asc,Section1 asc,[BranchName] asc'
				EXEC (@SortingCmd)
			END
		END

	ELSE
	BEGIN
		IF @R_SortingColumn IS NULL
			BEGIN
				SELECT @SortingCmd = '
					SELECT *,(SELECT SalesCount FROM #SalesReportCountCons)[RowCount]
					FROM #SalesReportCons
					ORDER BY TransactionDate '+ @R_SortingDirection+',SectionName '+ @R_SortingDirection+',[BranchName] '+ @R_SortingDirection+'
					OFFSET (' + CAST(@R_PageNumber - 1 AS NVARCHAR(MAX)) + ')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS
					FETCH NEXT ' + CAST(@R_PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY'
				EXEC (@SortingCmd)
			END
		ELSE
			BEGIN
				SELECT @SortingCmd = '
					SELECT *,(SELECT SalesCount FROM #SalesReportCountCons)[RowCount] ,[BranchName] AS [BranchName1], TransactionDate AS TransactionDate1,SectionName AS Section1
					FROM #SalesReportCons
					ORDER BY  ' + @R_SortingColumn +' '+ @R_SortingDirection+',TransactionDate1 asc,Section1 asc,[BranchName1] asc
					OFFSET (' + CAST(@R_PageNumber - 1 AS NVARCHAR(MAX)) + ')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS
					FETCH NEXT ' + CAST(@R_PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY'
				EXEC (@SortingCmd)
		END
		END

		------ FOR GETTING FOOTER TOTAL---------------------
		SELECT SUM(NETTOTAL) AS GrandTotal
		,'' AS Section,'' AS [Branch] FROM #SalesReportCons

	------END OF DETAIL SECTION-----

	IF Object_id('TempDB.dbo.#SalesReportCons') IS NOT NULL
	BEGIN
		DROP TABLE #SalesReportCons
	END

	IF Object_id('TempDB.dbo.#SalesReportCountCons') IS NOT NULL
	BEGIN
		DROP TABLE #SalesReportCountCons
	END

	SET NOCOUNT OFF

	END
GO
PRINT 'Created or altered SP Report_SalesReportConsolPaging.';
GO


-- ============================================================
-- SECTION G: DROP OBSOLETE/UNUSED OBJECTS
-- ============================================================
PRINT 'Section G: Dropping obsolete/unused objects...';
GO

-- Drop obsolete triggers
-- UpdateSalesMasterIsPending: legacy trigger present on some older databases
-- only. IsPending is computed by the application itself (see SalesMaster
-- Insert/Update/DeleteAndMerge in the WinApp); the trigger is redundant,
-- uses a less complete formula than the app, and was found to incorrectly
-- revert IsPending back to 1 for merged-away bills. Not needed anywhere.
IF OBJECT_ID('dbo.UpdateSalesMasterIsPending', 'TR') IS NOT NULL DROP TRIGGER dbo.UpdateSalesMasterIsPending;
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
        [No]              VARCHAR(50)      NULL,
        [Date]            DATETIME         NULL,
        [Type]            VARCHAR(50)      NULL,
        [LedgerID]        UNIQUEIDENTIFIER NULL,
        [IsDebit]         BIT              NULL,
        [Amount]          DECIMAL(18,8)    NULL,
        [IsPrimary]       BIT              NULL,
        [IsDayBook]       BIT              NULL,
        [Narration]       VARCHAR(50)      NULL,
        [FinancialYearID] INT              NULL,
        [BranchID]        UNIQUEIDENTIFIER NULL,
        [CompanyID]       UNIQUEIDENTIFIER NULL,
        [CreatedUser]     UNIQUEIDENTIFIER NULL,
        [CreatedDate]     DATETIME         NULL,
        [UpdatedUser]     UNIQUEIDENTIFIER NULL,
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
        [GuID]            UNIQUEIDENTIFIER NOT NULL DEFAULT (newid()),
        [No]              VARCHAR(50)      NOT NULL,
        [Date]            DATETIME         NOT NULL,
        [Type]            VARCHAR(50)      NOT NULL,
        [LedgerID]        UNIQUEIDENTIFIER NOT NULL,
        [IsDebit]         BIT              NOT NULL,
        [Amount]          DECIMAL(18,8)    NOT NULL,
        [IsPrimary]       BIT              NOT NULL DEFAULT 0,
        [IsDayBook]       BIT              NOT NULL DEFAULT 0,
        [Narration]       VARCHAR(50)      NOT NULL,
        [FinancialYearID] INT              NOT NULL,
        [CompanyID]       UNIQUEIDENTIFIER NOT NULL,
        [BranchID]        UNIQUEIDENTIFIER NULL,
        [CreatedUser]     UNIQUEIDENTIFIER NOT NULL,
        [CreatedDate]     DATETIME         NOT NULL DEFAULT GETDATE(),
        [UpdatedUser]     UNIQUEIDENTIFIER NOT NULL,
        [UpdatedDate]     DATETIME         NOT NULL
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

-- ============================================================
-- SECTION K: Missing stored procedures / functions / table types
-- (found missing vs. defaultDB reference during ArafaArabic_CITY audit)
-- ============================================================
PRINT 'Section K: Create missing table types...';
GO

IF TYPE_ID(N'dbo.LedgerBranchOpening_UDT') IS NULL
CREATE TYPE dbo.LedgerBranchOpening_UDT AS TABLE (
    LedgerID uniqueidentifier NULL,
    Credit decimal(18,8) NULL,
    Debit decimal(18,8) NULL,
    RefNo varchar(50) NULL,
    Remarks varchar(150) NULL
);
GO

IF TYPE_ID(N'restaurant.UDT_R_Category') IS NULL
CREATE TYPE restaurant.UDT_R_Category AS TABLE (
    GuID uniqueidentifier NULL,
    Name varchar(100) NULL,
    OtherLanguageName nvarchar(100) NULL,
    BranchID uniqueidentifier NULL,
    Deleted bit NULL,
    CreatedDate datetime NULL,
    UpdatedDate datetime NULL,
    CreatedUser nvarchar(100) NULL,
    UpdatedUser nvarchar(100) NULL
);
GO

IF TYPE_ID(N'restaurant.UDT_R_Zone') IS NULL
CREATE TYPE restaurant.UDT_R_Zone AS TABLE (
    Guid uniqueidentifier NOT NULL,
    Name varchar(100) NOT NULL,
    OtherLanguageName nvarchar(100) NULL,
    BranchID uniqueidentifier NOT NULL,
    CreatedDate datetime NOT NULL,
    UpdatedDate datetime NULL,
    CreatedUser nvarchar(100) NULL,
    UpdatedUser nvarchar(100) NULL,
    Deleted bit NOT NULL
);
GO

PRINT 'Section K: Create/alter missing stored procedures and functions...';
GO

-- Drop and recreate VoucherSumDateToDateWithOB with a default @userID
-- (Arafa's local copy required @userID with no default, diverging from
-- the defaultDB baseline that GetPandLExpense/GetPandLIncome call with 5 args)
IF OBJECT_ID('dbo.VoucherSumDateToDateWithOB', 'FN') IS NOT NULL
BEGIN
    DROP FUNCTION dbo.VoucherSumDateToDateWithOB;
    PRINT 'Dropped function dbo.VoucherSumDateToDateWithOB.';
END
GO

CREATE FUNCTION [dbo].[VoucherSumDateToDateWithOB]( @LedgerID uniqueidentifier ,@StartDate datetime, @EndDate datetime ,@isDebit  bit,@branchID uniqueidentifier,@userID int = NULL)
RETURNS money
AS
BEGIN
	DECLARE @M money;
    SELECT  @M = isnull(sum(Amount),0) from voucher where Date >= @StartDate and Date <= @EndDate and LedgerID = @LedgerID  and isDebit = @isDebit  and BranchID=@BranchID
	select  @M=@M + (case when (@IsDebit=1) then ISNULL(SUM(LBO.Debit),0) else ISNULL(sum(LBO.Credit),0) end) from LedgerBranchOpeningDetail LBO inner join Ledger L on L.GuID=LBO.LedgerID inner join LedgerBranchOpeningMaster LBM on LBM.GuID=LBO.MasterID where LBO.LedgerID = @LedgerID and LBM.BranchID=@BranchID
RETURN 	 @M
END
GO
PRINT 'Created unified function dbo.VoucherSumDateToDateWithOB.';
GO

CREATE OR ALTER PROCEDURE [dbo].[GetSupplierStatementReport]
    @startDate DATETIME,
    @endDate DATETIME,
    @Supplier VARCHAR(MAX) = NUll,
    @location VARCHAR(MAX) = NULL
AS
BEGIN
    SELECT 
        restaurant.Supplier.Name AS SUPPLIER, 
        restaurant.Supplier.Mobile, 
        L.Name AS LedgerName,
        restaurant.Purchase.EntryDate, 
        restaurant.Purchase.PaymentType,
        restaurant.Purchase.TransType, 
        restaurant.Purchase.EntryNumber,
        restaurant.Purchase.NetTotal, 
        SV.Amount, 
        SV.ISDEBIT,
        ISNULL(BPD.Amount, 0) AS PAID_AMOUNT, 
        ISNULL(BPD.Discount, 0) AS DISC,
		ISNULL(BPM.Date,0) AS PaidDate
    FROM 
        restaurant.Supplier 
    INNER JOIN 
        restaurant.Purchase ON restaurant.Purchase.SupplierID = restaurant.Supplier.GuID 
    LEFT OUTER JOIN 
        restaurant.BillPaymentDetail BPD ON restaurant.Purchase.GuID = BPD.PurchaseMasterID
    LEFT OUTER JOIN 
        restaurant.BillPaymentMaster BPM ON BPM.GuID = BPD.MasterID 
    INNER JOIN 
        restaurant.Voucher SV ON SV.No = restaurant.Purchase.EntryNumber
    INNER JOIN 
        R_Ledger L ON L.GuID = SV.LedgerID
    WHERE 
        restaurant.Purchase.EntryDate BETWEEN @startDate AND @endDate
        AND (@Supplier IS NULL OR restaurant.Supplier.GuID=@Supplier)
        AND (@location IS NULL OR restaurant.Purchase.BranchID = @location);
END;


GO
PRINT 'Created or altered dbo.GetSupplierStatementReport.';
GO

CREATE OR ALTER PROCEDURE [dbo].[Get_CustomerStatement_Report]
    @startDate DATETIME,
    @endDate DATETIME,
    @Customer VARCHAR(MAX) = NUll,
    @location VARCHAR(MAX) = NULL
AS
BEGIN
    SELECT        R_Customer.Name AS Customer, R_Customer.Mobile, L.Name as LedgerName,
			  restaurant.Inv_SalesMaster.EntryNumber, restaurant.Inv_SalesMaster.PAYMENTMODE,
			 restaurant.Inv_SalesMaster.TransType, restaurant.Inv_SalesMaster.INVDATE,restaurant.Inv_SalesMaster.NetTotal,
			 SV.Amount, SV.ISDEBIT,
			  isnull(BPD.Amount,0) AS PAID_AMOUNT, isnull(BPD.Discount,0) DISC 
			  
FROM            R_Customer INNER JOIN
                         restaurant.Inv_SalesMaster ON restaurant.Inv_SalesMaster.CUSTOMER = R_Customer.GuID LEFT OUTER JOIN
						 restaurant.BillReceiptDetail BPD ON restaurant.Inv_SalesMaster.GuID = BPD.SalesMasterID
						 LEFT OUTER JOIN
						 restaurant.BillReceiptMaster BPM On BPM.GuID = BPD.MasterID INNER JOIN
						 restaurant.Voucher SV On SV.No = restaurant.Inv_SalesMaster.EntryNumber
						 Inner Join R_Ledger L on L.GuID = SV.LedgerID
    WHERE 
        restaurant.Inv_SalesMaster.INVDATE BETWEEN @startDate AND @endDate
        AND (@Customer IS NULL OR R_Customer.GuID=@Customer)
        AND (@location IS NULL OR restaurant.Inv_SalesMaster.BranchID = @location);
END;


GO
PRINT 'Created or altered dbo.Get_CustomerStatement_Report.';
GO

CREATE OR ALTER PROCEDURE dbo.[Get_LedgerBranchOpening]      
AS      
BEGIN      
    SELECT       
        LM.[ID] ,      
        LM.[GuID] ,      
        LM.[No],      
        LM.[Date],
		LM.[BranchID], 
        LM.[Remarks] AS Remarks,      
        LM.[FinancialYearID],               
        LM.[CompanyID],               
        LM.[No],     
        LM.[CreatedUser],      
        LM.[CreatedDate],      
        LM.[UpdatedUser],      
        LM.[UpdatedDate]    
    FROM       
        LedgerBranchOpeningMaster LM      
 WHERE LM.Deleted = 0   
   SELECT       
        LD.[ID] ,      
        LD.[GuID] ,       
        LD.[MasterID] ,      
        LD.[LedgerID] ,
		LD.[Credit],
        LD.[Debit] ,      
        LD.[RefNo],    
		LD.[Remarks],
		RL.[Name]
  FROM       
      LedgerBranchOpeningDetail LD     
 INNER JOIN R_Ledger RL ON LD.LedgerID = RL.GuID      
   
END


GO
PRINT 'Created or altered dbo.Get_LedgerBranchOpening.';
GO

CREATE OR ALTER PROCEDURE [dbo].[InsertUpdateLedgerBranchOpening]        
    @GuID uniqueidentifier = NULL,  -- New parameter to identify existing records      
    @Date datetime,        
    @No int,                
    @BranchID uniqueidentifier,        
    @Remarks varchar(150),      
    @FinancialYearID int,    
    @CompanyID int,          
    @UpdatedUser uniqueidentifier,     
    @LedgerBranchOpening_UDT LedgerBranchOpening_UDT READONLY,
			 @VoucherDetails_UDT  [restaurant].[VoucherDetail_UDT]		READONLY
   
AS        

BEGIN        
    DECLARE @NewMasterGuID uniqueidentifier        
  BEGIN TRY
  BEGIN TRANSACTION            
    IF @GuID IS NULL        
    BEGIN        
        -- Insert operation        
        SET @NewMasterGuID = NEWID()        
        
        INSERT INTO LedgerBranchOpeningMaster      
        (        
            [GuID],                       
            [Date],                       
            [BranchID],
			[Remarks],
			[FinancialYearID],    
            [CompanyID], 
			[No],  
            [CreatedUser],        
            [CreatedDate],        
            [UpdatedUser],        
            [UpdatedDate],
			[Deleted]
        )        
        VALUES        
        (        
            @NewMasterGuID, 
			@Date,
			@BranchID,
			@Remarks,
			@FinancialYearID,    
            @CompanyID,
            @No,                                         
            @UpdatedUser,        
            GETDATE(),        
            @UpdatedUser,        
            GETDATE(),
			0
        );        
    END        
    ELSE        
    BEGIN        
        -- Update operation        
        SET @NewMasterGuID = @GuID        
        
        UPDATE LedgerBranchOpeningMaster        
        SET      
            [No]=@No,    
            [Date] = @Date,        
            [Remarks]=@Remarks,
            [BranchID] = @BranchID,                     
            [UpdatedUser] = @UpdatedUser,        
            [UpdatedDate] = GETDATE(),
			[Deleted] = 0
   
        WHERE        
            [GuID] = @GuID;        
        
        -- Delete existing details to replace them with updated details        
        DELETE FROM LedgerBranchOpeningDetail        
        WHERE        
            [MasterID] = @GuID;        

		DELETE FROM [restaurant].[Voucher]        
        WHERE        
            [Type] = 'OB' AND [NO] IN (select Distinct [NO] from @VoucherDetails_UDT) ;
  
	END 
    -- Insert into the detail table        
    INSERT INTO LedgerBranchOpeningDetail      
    (        
        [GuID],        
        [MasterID],        
        [LedgerID],        
        [Credit],
		[Debit],
		[RefNo],
        [Remarks]        
            
    )        
    SELECT        
        NEWID(),  -- Generate new GuID for each detail row        
        @NewMasterGuID,        
        [LedgerID],        
        [Credit],
		[Debit],
		[RefNo],
        [Remarks]      
           
    FROM         
       @LedgerBranchOpening_UDT
    
	INSERT INTO [restaurant].[Voucher]
                        ([No], [Date], [Type], [LedgerID], [IsDebit], [Amount], [IsPrimary], 
                         [IsDayBook], [Narration], [FinancialYearID], [CompanyID], [BranchID], 
                         [CreatedUser], [CreatedDate], [UpdatedUser], [UpdatedDate])
	SELECT 
                        [No], [Date], [Type], [LedgerID], [IsDebit], [Amount], 
                        [IsPrimary], [IsDayBook], [Narration], [FinancialYearID], 
                        [CompanyID], @BranchID, [CreatedUser], GETDATE(), 
                        [UpdatedUser], GETDATE()
	FROM @VoucherDetails_UDT
         
 	COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
		ROLLBACK Transaction;
		THROW 51000, 'SOME ERROR', 1;
  END CATCH

 END


GO
PRINT 'Created or altered dbo.InsertUpdateLedgerBranchOpening.';
GO


CREATE OR ALTER PROCEDURE [dbo].[LedgerBranchOpening_Delete]        
(        
 @Guid UNIQUEIDENTIFIER = NULL,        
 @BranchID VARCHAR(50) = NULL,        
 @UpdatedUser UNIQUEIDENTIFIER = NULL        
)        
AS        
BEGIN        
  UPDATE LedgerBranchOpeningMaster        
  SET Deleted = 1        
  ,UpdatedUser = @UpdatedUser        
  ,UpdatedDate = GETDATE()        
  WHERE [GuID] = @Guid AND BranchID = @BranchID       
  
     delete RV from restaurant.Voucher RV INNER JOIN LedgerBranchOpeningMaster JM
	ON RV.No =  JM.No AND RV.Date = JM.Date AND RV.Type = 'OB'
	WHERE JM.GuID = @Guid AND JM.BranchID = @BranchID
          
END

GO
PRINT 'Created or altered dbo.LedgerBranchOpening_Delete.';
GO


CREATE OR ALTER PROCEDURE [dbo].[R_Ledger_Delete]
(
		   @Name varchar(100),
           @GroupID uniqueidentifier,
           @IsDebit bit,
           @Amount money,
           @CompanyID int,
           @IsFixed bit,
           @GuID uniqueidentifier
	
)
AS
DECLARE @NewGuid UNIQUEIDENTIFIER	= NULL
BEGIN
	IF @Guid IS NOT NULL
	 BEGIN
		IF NOT EXISTS(select * From restaurant.Voucher WHERE [LedgerID] = @Guid )
			BEGIN 
			 IF NOT EXISTS(SELECT * FROM [dbo].[R_Ledger] WHERE [Guid] = @Guid AND [IsFixed] = 1)
			  BEGIN	
				Delete From [dbo].[R_Ledger] WHERE [Guid]=@Guid
			  END
			 ELSE THROW 51000, 'CANNOT DELETE FIXED LEDGERS ', 1
			 END
		 ELSE THROW 51000, 'Reference Exists, Cannot Delete This Ledger', 1
		END
END




GO
PRINT 'Created or altered dbo.R_Ledger_Delete.';
GO


CREATE OR ALTER PROCEDURE [restaurant].[BillPayment_Delete]      
(      
 @Guid UNIQUEIDENTIFIER = NULL,      
 @BranchID VARCHAR(50) = NULL,      
 @UpdatedUser UNIQUEIDENTIFIER = NULL      
)      
AS      
BEGIN      
  UPDATE restaurant.BillPaymentMaster      
  SET Deleted = 1      
  ,UpdatedUser = @UpdatedUser      
  ,UpdatedDate = GETDATE()      
  WHERE [GuID] = @Guid AND BranchID = @BranchID      
  
  delete RV from restaurant.Voucher RV INNER JOIN restaurant.BillPaymentMaster JM
	ON RV.No =  JM.No AND RV.Date = JM.Date AND RV.Type = 'BP'
	WHERE JM.GuID = @Guid AND JM.BranchID = @BranchID
END 

GO
PRINT 'Created or altered restaurant.BillPayment_Delete.';
GO


CREATE OR ALTER PROCEDURE [restaurant].[BillReceipt_Delete]      
(      
 @Guid UNIQUEIDENTIFIER = NULL,      
 @BranchID VARCHAR(50) = NULL,      
 @UpdatedUser UNIQUEIDENTIFIER = NULL      
)      
AS      
BEGIN      
  UPDATE restaurant.BillReceiptMaster      
  SET Deleted = 1      
  ,UpdatedUser = @UpdatedUser      
  ,UpdatedDate = GETDATE()      
  WHERE [GuID] = @Guid AND BranchID = @BranchID      
       
  delete RV from restaurant.Voucher RV INNER JOIN restaurant.BillReceiptMaster JM
	ON RV.No =  JM.No AND RV.Date = JM.Date AND RV.Type = 'BR'
	WHERE JM.GuID = @Guid AND JM.BranchID = @BranchID
END

GO
PRINT 'Created or altered restaurant.BillReceipt_Delete.';
GO

CREATE OR ALTER PROCEDURE [restaurant].[CategoryMaster_GetAll]
    @BranchID UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        GuID,
        Name,
        OtherLanguageName,
        BranchID,
        Deleted,
        CreatedDate,
        UpdatedDate,
		CreatedUser,
		UpdatedUser
    FROM
        restaurant.CategoryMaster
    WHERE
        Deleted = 0 AND (@BranchID IS NULL OR BranchID = @BranchID)
    ORDER BY CreatedDate DESC;
END


GO
PRINT 'Created or altered restaurant.CategoryMaster_GetAll.';
GO

CREATE OR ALTER PROCEDURE [restaurant].[CategoryMaster_Insert]
    @UDT_R_Category [restaurant].[UDT_R_Category] READONLY
AS
BEGIN
 BEGIN TRY
    BEGIN TRANSACTION

    MERGE [restaurant].[CategoryMaster] AS Target
    USING @UDT_R_Category AS Source
    ON Target.GuID = Source.GuID
    WHEN MATCHED THEN
        UPDATE SET
            Target.Name = Source.Name,
            Target.OtherLanguageName = Source.OtherLanguageName,
            Target.BranchID = Source.BranchID,
            Target.Deleted = Source.Deleted,
            Target.UpdatedDate = Source.UpdatedDate,
            Target.UpdatedUser = Source.UpdatedUser
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (GuID, Name, OtherLanguageName, BranchID, Deleted, CreatedUser, CreatedDate)
        VALUES (Source.GuID, Source.Name, Source.OtherLanguageName, Source.BranchID, Source.Deleted, Source.CreatedUser, Source.CreatedDate);
			 COMMIT TRANSACTION
     END TRY
   BEGIN CATCH
        ROLLBACK TRANSACTION
        RETURN -1
   END CATCH
 RETURN 1
END


GO
PRINT 'Created or altered restaurant.CategoryMaster_Insert.';
GO

CREATE OR ALTER PROCEDURE [restaurant].[CategoryMaster_InsertUpdateDelete]
    @Action VARCHAR(10),
    @GuID UNIQUEIDENTIFIER = NULL OUTPUT,
    @Name VARCHAR(100) = NULL,
    @OtherLanguageName NVARCHAR(100) = NULL,
    @BranchID UNIQUEIDENTIFIER = NULL,
	@CreatedDate DATETIME = GetDate,
    @CreatedUser NVARCHAR(100) = NULL,
	@UpdatedUser NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'DELETE'
    BEGIN
        IF @GuID IS NOT NULL
        BEGIN


            UPDATE restaurant.CategoryMaster
            SET Deleted = 1,
                UpdatedDate = @CreatedDate,
								UpdatedUser = @CreatedUser
            WHERE GuID = @GuID;

            SELECT 1 AS Result;
        END
        ELSE
            RAISERROR('GuID is required for DELETE operation.', 16, 1);
    END
    ELSE IF @Action = 'INSERT'
    BEGIN
        IF @GuID IS NULL
            SET @GuID = NEWID();

			IF EXISTS (
        SELECT 1 FROM [restaurant].[CategoryMaster]
        WHERE UPPER(Name) = UPPER(@Name)
          AND BranchID = @BranchID
          AND Deleted = 0
    )
    BEGIN
        THROW 51000, 'Same data already exists...', 1;
    END

        INSERT INTO restaurant.CategoryMaster (GuID, Name, OtherLanguageName, BranchID, Deleted, CreatedDate, UpdatedDate, CreatedUser)
        VALUES (@GuID, @Name, @OtherLanguageName, @BranchID, 0,@CreatedDate ,GETDATE(),@CreatedUser);

        SELECT 1 AS Result;
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        IF @GuID IS NOT NULL
        BEGIN

				IF EXISTS (
        SELECT 1 FROM [restaurant].[CategoryMaster]
        WHERE UPPER(Name) = UPPER(@Name)
          AND BranchID = @BranchID
          AND Deleted = 0 AND  GuID != @GuID
    )
    BEGIN
        THROW 51000, 'Same data already exists...', 1;
    END
            UPDATE restaurant.CategoryMaster
            SET Name = @Name,
                OtherLanguageName = @OtherLanguageName,
                BranchID = @BranchID,
                UpdatedDate = @CreatedDate,
				UpdatedUser = @CreatedUser
            WHERE GuID = @GuID;

            SELECT 1 AS Result;
        END
        ELSE
            RAISERROR('GuID is required for UPDATE operation.', 16, 1);
    END
    ELSE
        RAISERROR('Invalid Action', 16, 1);
END



GO
PRINT 'Created or altered restaurant.CategoryMaster_InsertUpdateDelete.';
GO

CREATE OR ALTER PROCEDURE [restaurant].[FinancialYear_GetAll]  
AS  
BEGIN  
 SET NOCOUNT ON;       
 SELECT   
    Id,GuID,Name,StartDate,EndDate
 FROM  
     R_FinancialYear   
    ORDER BY  
     Name  
END


GO
PRINT 'Created or altered restaurant.FinancialYear_GetAll.';
GO

CREATE OR ALTER PROCEDURE [restaurant].[GETSUPPLIERBILLS] (
	@BranchId				UNIQUEIDENTIFIER = NULL,
	@SupplierID				UNIQUEIDENTIFIER = NULL
	)
AS
BEGIN

SELECT 
P.ID,
P.GuID,
P.GRNNo,
P.InvoiceDate,
P.EntryDate,
P.InvoiceNo,
P.EntryNumber,
1 Position,
P.TransType,
P.NetTotal
FROM restaurant.Purchase P
WHERE P.PaymentType = 3
AND P.TransType = 'PI'
AND P.SupplierID=@SupplierID
AND P.BranchID=@BranchId
AND P.NetTotal !=
(dbo.GetBillPaymentSum(P.GuID)+dbo.GetBillPaymentDiscountSum(P.GuID))
END


GO
PRINT 'Created or altered restaurant.GETSUPPLIERBILLS.';
GO

CREATE OR ALTER FUNCTION restaurant.[GetCreditBalanceForDayBook_Report](
    @ToDate datetime,
    @CompanyID uniqueidentifier,
    @location uniqueidentifier, -- Matches BranchID type
    @userID int
) 
RETURNS Decimal  
AS  
BEGIN  
    DECLARE @DebitBalance money;  

    IF (@location IS NOT NULL AND @location != '00000000-0000-0000-0000-000000000000')  
    BEGIN  
        SELECT @DebitBalance = SUM(CASE WHEN R.IsDebit = 'True' THEN R.Amount ELSE 0 END)  
                              - SUM(CASE WHEN R.IsDebit = 'False' THEN R.Amount ELSE 0 END)  
        FROM restaurant.Voucher AS R  
        INNER JOIN restaurant.Voucher AS A  
            ON R.No = A.No AND R.Type = A.Type AND R.LedgerID <> A.LedgerID AND A.IsDayBook = 'True'     
            AND R.IsDebit <> A.IsDebit  
        INNER JOIN R_Ledger  
            ON R_Ledger.GuID = R.LedgerID  
        WHERE A.Date < @ToDate  
          AND A.CompanyID = @CompanyID  
          AND A.BranchID = @location;  
    END  
    ELSE  
    BEGIN  
        SELECT @DebitBalance = SUM(CASE WHEN R.IsDebit = 'True' THEN R.Amount ELSE 0 END)  
                              - SUM(CASE WHEN R.IsDebit = 'False' THEN R.Amount ELSE 0 END)  
        FROM restaurant.Voucher AS R  
        INNER JOIN restaurant.Voucher AS A  
            ON R.No = A.No AND R.Type = A.Type AND R.LedgerID <> A.LedgerID AND A.IsDayBook = 'True'     
            AND R.IsDebit <> A.IsDebit  
        INNER JOIN R_Ledger  
            ON R_Ledger.GuID = R.LedgerID  
        WHERE A.Date < @ToDate  
          AND A.CompanyID = @CompanyID  
          AND A.BranchID IS NULL;  
    END  

    RETURN ISNULL(@DebitBalance, 0);  
END;


GO
PRINT 'Created or altered restaurant.GetCreditBalanceForDayBook_Report.';
GO

CREATE OR ALTER PROCEDURE [restaurant].[GetDayBook] 
(@FromDate datetime,
@ToDate datetime,
@FinancialYearID int,
@BranchID varchar(max))
AS
BEGIN
  declare @SQLString nvarchar(max), @PARAMDEF NVARCHAR(MAX);
SET NOCOUNT ON;

	BEGIN
		set @SQLString='SELECT distinct R.ID,R.Date as Date, R_Ledger.Name as Particulars ,  R.Type, R.No,  
		Debit = case when R.isDebit=''True''  then  R.Amount else 0 end , 
		Credit = case when R.isDebit=''False'' then R.Amount else 0 end ,Isnull(R.Narration,'''') as Narration
		FROM restaurant.voucher as R inner join restaurant.voucher as A on R.No = A.No 
		and R.Type = A.Type and R.LedgerID <> A.LedgerID and  A.isDaybook=''True''   
		and R.isDebit <> A.isDebit inner join R_Ledger on R_Ledger.GuID = R.LedgerID 
		where 1=1';

		set @SQLString=@SQLString+ ' and A.Date  between  @FromDate  and @ToDate  and R.Date  between  @FromDate  and @ToDate'

		IF (@BranchID !='' and @BranchID != '00000000-0000-0000-0000-000000000000')
		begin
			set @SQLString= @SQLString + ' and A.BranchID = '+''''+ @BranchID +'''';
		end

		/**IF (@FinancialYearID !=0 )
		BEGIN
			set @SQLString= @SQLString + ' and A.FinancialYearID = '+ convert(varchar(10), @FinancialYearID);
		END **/

		set @SQLString= @SQLString + '  order by Date, R.Type,R.No,Particulars,R.ID';
		
      SET @PARAMDEF=N' @FromDate Date, @ToDate Date, @FinancialYearID int,@BranchID varchar(max)';


    EXEC sp_executesql @SQLString, @PARAMDEF, @FromDate=@FromDate, @ToDate=@ToDate,  @BranchID= @BranchID , @FinancialYearID= @FinancialYearID ;

END 
END


GO
PRINT 'Created or altered restaurant.GetDayBook.';
GO

CREATE OR ALTER PROCEDURE restaurant.GetLedgerReport
AS
BEGIN

SELECT        dbo.R_Ledger.Name LedgerName, dbo.R_Group.Name AS GroupName, restaurant.Voucher.No, restaurant.Voucher.Date, 
			restaurant.Voucher.Type, restaurant.Voucher.Amount AS DEBIT, 0 as CREDIT, restaurant.Voucher.IsDebit, restaurant.Voucher.BranchID
FROM            restaurant.Voucher INNER JOIN
                         dbo.R_Ledger ON restaurant.Voucher.LedgerID = dbo.R_Ledger.GuID AND restaurant.Voucher.IsDebit = 1
						 LEFT OUTER JOIN 
                         dbo.R_Group ON dbo.R_Ledger.GroupID = dbo.R_Group.GuID
UNION ALL
SELECT        dbo.R_Ledger.Name LedgerName, dbo.R_Group.Name AS GroupName, restaurant.Voucher.No, restaurant.Voucher.Date, 
			restaurant.Voucher.Type, 0 AS DEBIT, restaurant.Voucher.Amount as CREDIT, restaurant.Voucher.IsDebit, restaurant.Voucher.BranchID
FROM            restaurant.Voucher INNER JOIN
                         dbo.R_Ledger ON restaurant.Voucher.LedgerID = dbo.R_Ledger.GuID AND restaurant.Voucher.IsDebit = 0
						 LEFT OUTER JOIN 
                         dbo.R_Group ON dbo.R_Ledger.GroupID = dbo.R_Group.GuID


						 END


GO
PRINT 'Created or altered restaurant.GetLedgerReport.';
GO

CREATE OR ALTER PROCEDURE [restaurant].[GetLedgerReportDetail] 
    (@LedgerID varchar(max) = '00000000-0000-0000-0000-000000000000', 
     @FromDate datetime, 
     @ToDate datetime, 
     @FinancialYearID int, 
     @BranchID varchar(max), 
	 @PageNumber   INT = NULL,
	 @PageSize    INT = NULL,
	 @SortingColumn   VARCHAR(MAX) = NULL,
	 @SortingDirection  VARCHAR(MAX) = NULL)  
AS  
BEGIN  
    DECLARE @OBM Money;  
    DECLARE @CBM Money;  
    DECLARE @OB decimal(18,2);  
    DECLARE @CB decimal(18,2);  
    DECLARE @IsDebitOB bit;  
    DECLARE @IsDebitCB bit;  
	DECLARE @location varchar(max)   = @BranchID;
    DECLARE @SQLString nvarchar(max), @PARAMDEF NVARCHAR(MAX);  
    DECLARE @R_PageNumber   INT      = @PageNumber;
	DECLARE @R_PageSize   INT      = @PageSize;
	DECLARE @R_SortingColumn    VARCHAR(MAX)   = @SortingColumn;
	DECLARE @R_SortingDirection VARCHAR(MAX)   = @SortingDirection;
    SET @OBM = dbo.LedgerOB(@LedgerID, @FromDate, 1, @location, DEFAULT)
             - dbo.LedgerOB(@LedgerID, @FromDate, 0, @location, DEFAULT);
    SET @CBM = dbo.LedgerOB(@LedgerID, @ToDate + 1, 1, @location, DEFAULT)
             - dbo.LedgerOB(@LedgerID, @ToDate + 1, 0, @location, DEFAULT);

    IF @OBM < 0  
    BEGIN  
        SET @IsDebitOB = 0;  
        SET @OBM = ABS(@OBM);  
    END  
    ELSE  
        SET @IsDebitOB = 1;  
  
    IF @CBM < 0   
    BEGIN  
        SET @IsDebitCB = 0;  
        SET @CBM = ABS(@CBM);  
    END  
    ELSE  
        SET @IsDebitCB = 1;  
  
    SET @OB = CONVERT(decimal(18,2), @OBM);  
    SET @CB = CONVERT(decimal(18,2), @CBM);  

    SET @SQLString = '
    SELECT DISTINCT 
        0 AS SLNO,   
        R.Date AS Date,  
        R_Ledger.Name AS Particulars,  
        R.Type, 
        R.No,    
        Debit = CASE 
                    WHEN A.isDebit = ''TRUE'' 
                    THEN R.Amount  
                    ELSE 0 
                END,   
        Credit = CASE 
                    WHEN A.isDebit = ''FALSE'' 
                    THEN R.Amount  
                    ELSE 0 
                 END,
        R.Narration AS Narration,
        R_Group.Name AS GroupName, 
        @OB AS OB,
        @IsDebitOB AS IsDebitOB,
        @CB AS CB,
        @IsDebitCB AS IsDebitCB   
    FROM restaurant.Voucher AS R 
    INNER JOIN restaurant.Voucher AS A 
        ON R.No = A.No   
        AND R.Type = A.Type 
        AND R.LedgerID <> A.LedgerID      
        AND R.BranchID = A.BranchID 
        AND R.CompanyID = A.CompanyID 
        AND R.FinancialYearID = A.FinancialYearID  
    INNER JOIN R_Ledger 
        ON R_Ledger.GuID = A.LedgerID
    INNER JOIN R_Group
        ON R_Ledger.GroupID = R_Group.GuID 
    WHERE 1 = 1'
	set @SQLString=@SQLString+ ' and A.Date>= @FromDate  and A.Date <= @ToDate '
  
    IF (@LedgerID != '' AND @LedgerID != '00000000-0000-0000-0000-000000000000')  
    BEGIN  
        SET @SQLString = @SQLString + ' AND R.LedgerID = ' + '''' + @LedgerID + '''';  
    END  
    
    IF (@location != '' AND @location != '00000000-0000-0000-0000-000000000000')  
    BEGIN  
        SET @SQLString = @SQLString + ' AND R.BranchID = ' + '''' + @location + '''';  
    END  
    
	/**IF (@FinancialYearID !=0 )
		BEGIN
			set @SQLString= @SQLString + ' and R.FinancialYearID = '+ convert(varchar(10), @FinancialYearID)
		END**/

	SET @SQLString = @SQLString + 
	'UNION ALL
		SELECT DISTINCT 
        0 AS SLNO,   
        R.Date AS Date,  
        SUP.FullName AS Particulars,  
        R.Type, 
        R.No,    
        Debit = CASE 
                    WHEN A.isDebit = ''TRUE'' 
                    THEN R.Amount  
                    ELSE 0 
                END,   
        Credit = CASE 
                    WHEN A.isDebit = ''FALSE''
                    THEN R.Amount  
                    ELSE 0 
                 END,
        R.Narration AS Narration,
        ''SUNDRY CREDITORS'' AS GroupName, 
        @OB AS OB,
        @IsDebitOB AS IsDebitOB,
        @CB AS CB,
        @IsDebitCB AS IsDebitCB     
    FROM restaurant.Voucher AS R 
    INNER JOIN restaurant.Voucher AS A 
        ON R.No = A.No   
        AND R.Type = A.Type 
        AND R.LedgerID <> A.LedgerID      
        AND R.BranchID = A.BranchID 
        AND R.CompanyID = A.CompanyID 
        AND R.FinancialYearID = A.FinancialYearID  
    INNER JOIN restaurant.Supplier SUP
        ON SUP.GuID = A.LedgerID
    WHERE 1 = 1'
		set @SQLString=@SQLString+ ' and A.Date>= @FromDate  and A.Date <= @ToDate '
  
    IF (@LedgerID != '' AND @LedgerID != '00000000-0000-0000-0000-000000000000')  
    BEGIN  
        SET @SQLString = @SQLString + ' AND R.LedgerID = ' + '''' + @LedgerID + '''';  
    END  
    
    IF (@location != '' AND @location != '00000000-0000-0000-0000-000000000000')  
    BEGIN  
        SET @SQLString = @SQLString + ' AND R.BranchID = ' + '''' + @location + '''';  
    END  
    
	/**IF (@FinancialYearID !=0 )
		BEGIN
			set @SQLString= @SQLString + ' and R.FinancialYearID = '+ convert(varchar(10), @FinancialYearID)
		END**/

	SET @SQLString = @SQLString + 
	'UNION ALL
	SELECT DISTINCT 
        0 AS SLNO,   
        R.Date AS Date,  
        CUST.Name AS Particulars,  
        R.Type, 
        R.No,    
        Debit = CASE 
                    WHEN A.isDebit = ''TRUE'' 
                    THEN R.Amount  
                    ELSE 0 
                END,   
        Credit = CASE 
                    WHEN A.isDebit = ''FALSE''
                    THEN R.Amount  
                    ELSE 0 
                 END,
        R.Narration AS Narration,
        ''SUNDRY DEBTORS'' AS GroupName, 
        @OB AS OB,
        @IsDebitOB AS IsDebitOB,
        @CB AS CB,
        @IsDebitCB AS IsDebitCB     
    FROM restaurant.Voucher AS R 
    INNER JOIN restaurant.Voucher AS A 
        ON R.No = A.No   
        AND R.Type = A.Type 
        AND R.LedgerID <> A.LedgerID      
        AND R.BranchID = A.BranchID 
        AND R.CompanyID = A.CompanyID 
        AND R.FinancialYearID = A.FinancialYearID  
    INNER JOIN R_Customer CUST
        ON CUST.GuID = A.LedgerID
    WHERE 1 = 1';  
  
    SET @SQLString = @SQLString + '  
    AND R.Type = A.Type 
    AND R.LedgerID <> A.LedgerID 
    AND A.isPrimary = ''True'' 
    AND R.isDebit <> A.isDebit'; 
      

	set @SQLString=@SQLString+ ' and A.Date>= @FromDate  and A.Date <= @ToDate '
  
    IF (@LedgerID != '' AND @LedgerID != '00000000-0000-0000-0000-000000000000')  
    BEGIN  
        SET @SQLString = @SQLString + ' AND R.LedgerID = ' + '''' + @LedgerID + '''';  
    END  
    
    IF (@location != '' AND @location != '00000000-0000-0000-0000-000000000000')  
    BEGIN  
        SET @SQLString = @SQLString + ' AND R.BranchID = ' + '''' + @location + '''';  
    END  
    
	/**IF (@FinancialYearID !=0 )
		BEGIN
			set @SQLString= @SQLString + ' and R.FinancialYearID = '+ convert(varchar(10), @FinancialYearID)
		END**/

    SET @SQLString = @SQLString + ' ORDER BY R.Date, R.Type, R.No';  
    
    SET @PARAMDEF = N'@FromDate Date, @ToDate Date, @OB decimal, @CB decimal, @OBM decimal, @CBM decimal, @IsDebitOB bit, @IsDebitCB bit, @FinancialYearID decimal';  
    
    EXEC sp_executesql 
        @SQLString,  
        @PARAMDEF,  
        @FromDate = @FromDate, 
        @ToDate = @ToDate, 
        @OB = @OB, 
        @CB = @CB, 
        @OBM = @OBM, 
        @CBM = @CBM, 
        @IsDebitCB = @IsDebitCB, 
        @IsDebitOB = @IsDebitOB,
		@FinancialYearID = @FinancialYearID;
		
END;


GO
PRINT 'Created or altered restaurant.GetLedgerReportDetail.';
GO

CREATE OR ALTER PROCEDURE [restaurant].[GetPandLExpense] 
    (
     @FromDate datetime, 
     @ToDate datetime, 
     @FinancialYearID int, 
     @BranchID varchar(max),
	 @GroupID  int,
	 @GroupGuid Uniqueidentifier)
AS  
BEGIN  
    
	select [R_Group].Name as [Group],R_Ledger.Name as Ledger,Expense =
dbo.VoucherSumDateToDateWithOB( R_Ledger.GuID,@FromDate,@ToDate,'True',@branchID,DEFAULT)-
dbo.VoucherSumDateToDateWithOB( R_Ledger.GuID,@FromDate,@ToDate,'False',@branchID,DEFAULT)
from R_Ledger,[R_Group] where R_Ledger.GroupID = [R_Group].GuID and ([R_Group].ID=@GroupID OR R_Group.ParentGroupID = @GroupGuid)
order by R_Ledger.GuID

END;


GO
PRINT 'Created or altered restaurant.GetPandLExpense.';
GO

CREATE OR ALTER PROCEDURE [restaurant].[GetPandLIncome] 
    (
     @FromDate datetime, 
     @ToDate datetime, 
     @FinancialYearID int, 
     @BranchID varchar(max),
	 @GroupID  int,
	 @GroupGuid Uniqueidentifier)
AS  
BEGIN  
    
	select [R_Group].Name as [Group],R_Ledger.Name as Ledger,Expense =
dbo.VoucherSumDateToDateWithOB( R_Ledger.GuID,@FromDate,@ToDate,'True',@branchID,DEFAULT)-
dbo.VoucherSumDateToDateWithOB( R_Ledger.GuID,@FromDate,@ToDate,'False',@branchID,DEFAULT)
from R_Ledger,[R_Group] where R_Ledger.GroupID = [R_Group].GuID and ([R_Group].ID=@GroupID OR R_Group.ParentGroupID = @GroupGuid)
order by R_Ledger.GuID

END;


GO
PRINT 'Created or altered restaurant.GetPandLIncome.';
GO


CREATE OR ALTER PROCEDURE restaurant.[Get_LedgerBranchOpening]      
AS      
BEGIN      
    SELECT       
        LM.[ID] ,      
        LM.[GuID] ,      
        LM.[No],      
        LM.[Date],
		LM.[BranchID], 
        LM.[Remarks] AS Remarks,      
        LM.[FinancialYearID],               
        LM.[CompanyID],               
        LM.[No],     
        LM.[CreatedUser],      
        LM.[CreatedDate],      
        LM.[UpdatedUser],      
        LM.[UpdatedDate]    
    FROM       
        LedgerBranchOpeningMaster LM      
 WHERE LM.Deleted = 0   
   SELECT       
        LD.[ID] ,      
        LD.[GuID] ,       
        LD.[MasterID] ,      
        LD.[LedgerID] ,
		LD.[Credit],
        LD.[Debit] ,      
        LD.[RefNo],    
		LD.[Remarks],
		RL.[Name]
  FROM       
      LedgerBranchOpeningDetail LD     
 INNER JOIN R_Ledger RL ON LD.LedgerID = RL.GuID      
   
END


GO
PRINT 'Created or altered restaurant.Get_LedgerBranchOpening.';
GO


CREATE OR ALTER PROCEDURE [restaurant].[Journal_Delete]      
(      
 @Guid UNIQUEIDENTIFIER = NULL,      
 @BranchID VARCHAR(50) = NULL,      
 @UpdatedUser UNIQUEIDENTIFIER = NULL      
)      
AS      
BEGIN      
  UPDATE restaurant.JournalMaster      
  SET Deleted = 1      
  ,UpdatedUser = @UpdatedUser      
  ,UpdatedDate = GETDATE()      
  WHERE [GuID] = @Guid AND BranchID = @BranchID ;    
 
 
	DELETE RV from restaurant.Voucher RV INNER JOIN restaurant.JournalMaster JM
	ON RV.No =  JM.No AND RV.Date = JM.Date AND RV.Type = 'JR'
	WHERE JM.GuID = @Guid and JM.BranchID = @BranchID
END

GO
PRINT 'Created or altered restaurant.Journal_Delete.';
GO


CREATE OR ALTER PROCEDURE [restaurant].[Payment_Delete]      
(      
 @Guid UNIQUEIDENTIFIER = NULL,      
 @BranchID VARCHAR(50) = NULL,      
 @UpdatedUser UNIQUEIDENTIFIER = NULL      
)      
AS      
BEGIN      
  UPDATE restaurant.PaymentMaster      
  SET Deleted = 1      
  ,UpdatedUser = @UpdatedUser      
  ,UpdatedDate = GETDATE()      
  WHERE [GuID] = @Guid AND BranchID = @BranchID      
 
   delete RV from restaurant.Voucher RV INNER JOIN restaurant.PaymentMaster JM
	ON RV.No =  JM.No AND RV.Date = JM.Date AND RV.Type = 'P'
	WHERE JM.GuID = @Guid AND JM.BranchID = @BranchID
END

GO
PRINT 'Created or altered restaurant.Payment_Delete.';
GO

CREATE OR ALTER PROCEDURE [restaurant].[Product_GetModifiers]
(
    @ProductGuid UNIQUEIDENTIFIER
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        pm.ModifierID AS Guid,
        m.Name,
        ISNULL(pm.ExtraCharge, m.Rate) AS ExtraCharge,
        pm.IsDefault
    FROM dbo.R_ProductModifiers pm
    INNER JOIN dbo.R_Modifiers m ON pm.ModifierID = m.GUID
    WHERE pm.ProductID = @ProductGuid
      AND m.Deleted = 0;
END


GO
PRINT 'Created or altered restaurant.Product_GetModifiers.';
GO


CREATE OR ALTER PROCEDURE [restaurant].[Receipt_Delete]      
(      
 @Guid UNIQUEIDENTIFIER = NULL,      
 @BranchID VARCHAR(50) = NULL,      
 @UpdatedUser UNIQUEIDENTIFIER = NULL      
)      
AS      
BEGIN      
  UPDATE restaurant.ReceiptMaster      
  SET Deleted = 1      
  ,UpdatedUser = @UpdatedUser      
  ,UpdatedDate = GETDATE()      
  WHERE [GuID] = @Guid AND BranchID = @BranchID      
       

  delete RV from restaurant.Voucher RV INNER JOIN restaurant.ReceiptMaster JM
	ON RV.No =  JM.No AND RV.Date = JM.Date AND RV.Type = 'R'
	WHERE JM.GuID = @Guid AND JM.BranchID = @BranchID
END

GO
PRINT 'Created or altered restaurant.Receipt_Delete.';
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE [restaurant].[Report_StockOutPaging]
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
	 @R_BranchID         VARCHAR(MAX)   = @BranchID 

	 DECLARE @SortingCmd VARCHAR(MAX)

	 SET ARITHABORT ON
	 SET XACT_ABORT ON
	 SET NOCOUNT ON

	 SET @R_ToDate = DATEADD(D, 1, @R_ToDate);

	 IF Object_id('TempDB.dbo.#StockInReportSummary') IS NOT NULL
	BEGIN
		DROP TABLE #StockInReportSummary
	END
		IF Object_id('TempDB.dbo.#StockInReportSummaryCount') IS NOT NULL
	BEGIN
		DROP TABLE #StockInReportSummaryCount
	END

	BEGIN
		------BEGIN SELECT FOR Item Wise Sales Report Summary-----
-- CTE: Stock Adjustments
WITH StockAdjustments AS (
    SELECT 
        SAD.ProductID, 
        SAD.AdjQuantity, 
        SAM.BranchID,
        SAM.Date
    FROM restaurant.Inv_StcokAdjustmentDetail SAD
    INNER JOIN restaurant.Inv_StcokAdjustmentMaster SAM 
        ON SAD.MasterID = SAM.GUID
    WHERE SAM.Deleted = 0
        AND (@R_FromDate IS NULL OR SAM.Date >= @R_FromDate)
        AND (@R_ToDate IS NULL OR SAM.Date < @R_ToDate)
),
-- CTE: Production
ProductionData AS (
    SELECT 
        PRD.ProductID, 
        PRD.ProdQauntity, 
        PRM.BranchID,
        PRM.Date
    FROM restaurant.Inv_ProductionDetail PRD
    INNER JOIN restaurant.Inv_ProductionMaster PRM 
        ON PRD.MasterID = PRM.GUID
    WHERE PRM.Deleted = 0
        AND (@R_FromDate IS NULL OR PRM.Date >= @R_FromDate)
        AND (@R_ToDate IS NULL OR PRM.Date < @R_ToDate)
),
-- CTE: POS Sales
PosSales AS (
    SELECT 
        PD.ProductID, 
        PD.QTY, 
        ISM.BranchID,
        ISM.INVDATE
    FROM restaurant.Inv_SalesDetail PD
    INNER JOIN restaurant.Inv_SalesMaster ISM 
        ON PD.MasterID = ISM.GUID
    WHERE ISM.Deleted = 0 
        AND ISM.TransType NOT IN ('SR', 'SQ') 
        AND ISM.RefType = 0
        AND (@R_FromDate IS NULL OR ISM.INVDATE >= @R_FromDate)
        AND (@R_ToDate IS NULL OR ISM.INVDATE < @R_ToDate)
),
-- CTE: Regular Sales
SalesData AS (
    SELECT 
        SD.ProductID, 
        SD.Quantity, 
        SM.BranchID,
        SM.TransactionDate
    FROM R_SalesDetail SD
    INNER JOIN R_SalesMaster SM 
        ON SD.MasterID = SM.GUID
    WHERE SM.Deleted = 0
        AND (@R_FromDate IS NULL OR SM.TransactionDate >= @R_FromDate)
        AND (@R_ToDate IS NULL OR SM.TransactionDate < @R_ToDate)
),
-- CTE: Stock Transfers
StockTransfers AS (
    SELECT 
        STDTO.ProductID, 
        STDTO.Quantity, 
        STM.BranchID,
        STM.Date
    FROM restaurant.Inv_StcokTransferDetail STDTO
    INNER JOIN restaurant.Inv_StcokTransferMaster STM 
        ON STDTO.MasterID = STM.GUID
    WHERE STM.Deleted = 0 
        AND STDTO.FromBranch = STM.BranchID
        AND (@R_FromDate IS NULL OR STM.Date >= @R_FromDate)
        AND (@R_ToDate IS NULL OR STM.Date < @R_ToDate)
)

-- Final Query
SELECT *
INTO #StockInReportSummary
FROM (
    SELECT 
        P.Name AS Product,
        R_Branch.Name AS BranchName,
        CT.Name AS CategoryName,
        TP.Name AS TypeName,
        SUM(ISNULL(SA.AdjQuantity, 0)) AS StockAdjustment,
        ISNULL(PRD.ProdQauntity, 0) AS Production,
        SUM(ISNULL(PD.QTY, 0) + ISNULL(SD.Quantity, 0)) AS SALES,
        SUM(ISNULL(ST.Quantity, 0)) AS StockTransfer,
        (
            ISNULL(SA.AdjQuantity, 0) + 
            ISNULL(PRD.ProdQauntity, 0) + 
            ISNULL(PD.QTY, 0) + 
            ISNULL(SD.Quantity, 0) + 
            ISNULL(ST.Quantity, 0)
        ) AS TOTSTOCKOUT
    FROM restaurant.ProductLocationMapping PLM
    INNER JOIN restaurant.Product P ON PLM.ProductID = P.GUID
    LEFT JOIN restaurant.ProductPriceDetail PPD ON PPD.MasterID = P.GUID AND PPD.Deleted = 0
    LEFT JOIN dbo.R_Type TP ON TP.GUID = PPD.TypeID
    LEFT JOIN dbo.R_Category CT ON CT.GUID = PPD.CategoryID
    LEFT JOIN R_Branch ON R_Branch.GUID = PPD.BranchID

    LEFT JOIN StockAdjustments SA 
        ON SA.ProductID = PPD.MasterID AND SA.BranchID = R_Branch.GUID
    LEFT JOIN ProductionData PRD 
        ON PRD.ProductID = PLM.ProductID AND PRD.BranchID = R_Branch.GUID
    LEFT JOIN PosSales PD 
        ON PD.ProductID = PLM.ProductID AND PD.BranchID = R_Branch.GUID
    LEFT JOIN SalesData SD 
        ON SD.ProductID = PLM.ProductID AND SD.BranchID = R_Branch.GUID
    LEFT JOIN StockTransfers ST 
        ON ST.ProductID = PLM.ProductID AND ST.BranchID = R_Branch.GUID

    GROUP BY 
        P.Name, 
        R_Branch.Name, 
        CT.Name, 
        TP.Name, 
		PRD.ProdQauntity,
		SA.AdjQuantity,
		PD.QTY,
        SD.Quantity,
        ST.Quantity


	HAVING 
		SUM(ISNULL(SA.AdjQuantity, 0) + 
        ISNULL(PRD.ProdQauntity, 0) + 
        ISNULL(PD.QTY, 0) + 
        ISNULL(SD.Quantity, 0) + 
        ISNULL(ST.Quantity, 0)) > 0

) AS ItemWiseSalesReportDetail
END

	SELECT COUNT(*) AS ItemWiseSalesReportSummaryCount
		INTO #StockInReportSummaryCount
		FROM #StockInReportSummary

		IF @PageSize = -1
	BEGIN
		IF @R_SortingColumn IS NULL
			BEGIN
				SELECT @SortingCmd = '
					SELECT *,(SELECT ItemWiseSalesReportSummaryCount FROM #StockInReportSummaryCount)[RowCount] 
					FROM #StockInReportSummary
					ORDER BY Product '+ @R_SortingDirection+''
				EXEC (@SortingCmd)
			END
		ELSE
			BEGIN
				SELECT @SortingCmd = '
					SELECT *,(SELECT ItemWiseSalesReportSummaryCount FROM #StockInReportSummaryCount)[RowCount] ,Product as Product1
					FROM #StockInReportSummary
					ORDER BY  ' + @R_SortingColumn +' '+ @R_SortingDirection+',Product1 asc'
				EXEC (@SortingCmd)
			END
		END

	ELSE
	BEGIN
		IF @R_SortingColumn IS NULL
			BEGIN
				SELECT @SortingCmd = '
					SELECT *,(SELECT ItemWiseSalesReportSummaryCount FROM #StockInReportSummaryCount)[RowCount] 
					FROM #StockInReportSummary
					ORDER BY Product '+ @R_SortingDirection+'
					OFFSET (' + CAST(@R_PageNumber - 1 AS NVARCHAR(MAX)) + ')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS
					FETCH NEXT ' + CAST(@R_PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY'
				EXEC (@SortingCmd)
			END
		ELSE
			BEGIN
				SELECT @SortingCmd = '
					SELECT *,(SELECT ItemWiseSalesReportSummaryCount FROM #StockInReportSummaryCount)[RowCount] ,Product as Product1
					FROM #StockInReportSummary
					ORDER BY  ' + @R_SortingColumn +' '+ @R_SortingDirection+',Product1 asc
					OFFSET (' + CAST(@R_PageNumber - 1 AS NVARCHAR(MAX)) + ')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS
					FETCH NEXT ' + CAST(@R_PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY'
				EXEC (@SortingCmd)
		END
	END

		------ FOR GETTING FOOTER TOTAL---------------------
		SELECT ''AS Product,
		       ''AS [Group],
			   ''AS [Category],

			   SUM(TOTSTOCKOUT) Total,
			   ''AS [Section],
			   ''AS [Counter] 
		FROM #StockInReportSummary
     
	------END OF DETAIL SECTION-----
	
	IF Object_id('TempDB.dbo.#StockInReportSummary') IS NOT NULL
	BEGIN
		DROP TABLE #StockInReportSummary
	END

	IF Object_id('TempDB.dbo.#StockInReportSummaryCount') IS NOT NULL
	BEGIN
		DROP TABLE #StockInReportSummaryCount
	END


	SET NOCOUNT OFF

END

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS ON


GO
PRINT 'Created or altered restaurant.Report_StockOutPaging.';
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE [restaurant].[Report_StockValuePaging]
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
	 @R_BranchID         VARCHAR(MAX)   = @BranchID 

	 DECLARE @SortingCmd VARCHAR(MAX)

	 SET ARITHABORT ON
	 SET XACT_ABORT ON
	 SET NOCOUNT ON

	 SET @R_ToDate = DATEADD(D, 1, @R_ToDate);

	 IF Object_id('TempDB.dbo.#StockInReportSummary') IS NOT NULL
	BEGIN
		DROP TABLE #StockInReportSummary
	END
		IF Object_id('TempDB.dbo.#StockInReportSummaryCount') IS NOT NULL
	BEGIN
		DROP TABLE #StockInReportSummaryCount
	END

-- Assuming procedure context and variable declarations already exist
-- Step 1: Create #StockLedger

IF OBJECT_ID('tempdb..#StockLedger') IS NOT NULL DROP TABLE #StockLedger;

CREATE TABLE #StockLedger (
	ID INT IDENTITY(1,1),
    ProductID UNIQUEIDENTIFIER,
    BranchID UNIQUEIDENTIFIER,
    EntryDate DATETIME,
    TransType VARCHAR(50),
    InQty DECIMAL(18,4),
    OutQty DECIMAL(18,4),
    Rate DECIMAL(18,4),
    Value DECIMAL(18,4),
    RunningQty DECIMAL(18,4) NULL,
    RunningValue DECIMAL(18,4) NULL,
    WAC DECIMAL(18,4) NULL
);

-- Step 2: Populate stock-in entries
-- Opening Stock
INSERT INTO #StockLedger (ProductID, BranchID, EntryDate, TransType, InQty, Rate, Value)
SELECT 
    OPD.ProductID,
    OPM.BranchID,
    OPM.Date,
    'OPENING',
    OPD.Quantity,
    ISNULL(OPD.UnitPrice, 0),
    OPD.Quantity * ISNULL(OPD.UnitPrice, 0)
FROM dbo.OpeningStockMaster OPM
JOIN dbo.OpeningStockDetail OPD ON OPD.MasterID = OPM.GUID
WHERE (@R_FromDate IS NULL OR OPM.Date >= @R_FromDate)
  AND (@R_ToDate IS NULL OR OPM.Date < @R_ToDate)
  AND (@R_BranchID IS NULL OR OPM.BranchID = @R_BranchID);

-- Purchase
INSERT INTO #StockLedger (ProductID, BranchID, EntryDate, TransType, InQty, Rate, Value)
SELECT 
    PD.ProductID,
    PR.BranchID,
    PR.EntryDate,
    'PURCHASE',
    PD.Quantity,
    ROUND(
        (ISNULL(PD.Rate, ISNULL(PPD.Cost, 0)) * (1 - ISNULL(PD.DiscPercentage, 0)/100.0)) 
        * (1 + ISNULL(PD.TaxPercentage, 0)/100.0), 4),
    -- Value = Qty * full adjusted rate
    ROUND(
        PD.Quantity *
        (ISNULL(PD.Rate, ISNULL(PPD.Cost, 0)) * (1 - ISNULL(PD.DiscPercentage, 0)/100.0)) 
        * (1 + ISNULL(PD.TaxPercentage, 0)/100.0), 4)
FROM restaurant.Purchase PR
JOIN restaurant.PurchaseDetail PD ON PR.GUID = PD.MasterID
LEFT JOIN restaurant.ProductPriceDetail PPD ON PPD.MasterID = PD.ProductID AND PPD.Deleted = 0 AND PPD.BranchID = @R_BranchID
WHERE PR.Deleted = 0
  --AND PR.TransType NOT IN ('PR', 'PO', 'GR')
  --AND PR.ReferenceType = 0
  AND PR.TransTypeID = 2
  AND (@R_FromDate IS NULL OR PR.EntryDate >= @R_FromDate)
  AND (@R_ToDate IS NULL OR PR.EntryDate < @R_ToDate)
  AND (@R_BranchID IS NULL OR PR.BranchID = @R_BranchID);

-- Production IN (Produced products)
INSERT INTO #StockLedger (ProductID, BranchID, EntryDate, TransType, InQty, Rate, Value)
SELECT 
    PRM.ProductID,
    PRM.BranchID,
    PRM.Date,
    'PRODUCTION-IN',
    PRM.Quantity,
    ISNULL(PRM.Cost, 0),
    PRM.Quantity * ISNULL(PRM.Cost, 0)
FROM restaurant.Inv_ProductionMaster PRM
WHERE PRM.Deleted = 0
  AND (@R_FromDate IS NULL OR PRM.Date >= @R_FromDate)
  AND (@R_ToDate IS NULL OR PRM.Date < @R_ToDate)
  AND (@R_BranchID IS NULL OR PRM.BranchID = @R_BranchID);

-- Transfer In
INSERT INTO #StockLedger (ProductID, BranchID, EntryDate, TransType, InQty, Rate, Value)
SELECT 
    STDTO.ProductID,
    STM.ToBranchID,
    STM.Date,
    'TRANSFER-IN',
    STDTO.Quantity,
    0,
    0
FROM restaurant.Inv_StcokTransferMaster STM
JOIN restaurant.Inv_StcokTransferDetail STDTO ON STDTO.MasterID = STM.GUID
WHERE STM.Deleted = 0
  AND (@R_FromDate IS NULL OR STM.Date >= @R_FromDate)
  AND (@R_ToDate IS NULL OR STM.Date < @R_ToDate)
  AND (@R_BranchID IS NULL OR STM.BranchID = @R_BranchID);

-- Adjustment IN
INSERT INTO #StockLedger (ProductID, BranchID, EntryDate, TransType, InQty, Rate, Value)
SELECT 
    SAD.ProductID,
    SAM.BranchID,
    SAM.Date,
    'ADJUSTMENT-IN',
    SAD.AdjQuantity,
    0,
    0
FROM restaurant.Inv_StcokAdjustmentMaster SAM
JOIN restaurant.Inv_StcokAdjustmentDetail SAD ON SAD.MasterID = SAM.GUID
WHERE SAM.Deleted = 0 AND SAD.AdjQuantity > 0
  AND (@R_FromDate IS NULL OR SAM.Date >= @R_FromDate)
  AND (@R_ToDate IS NULL OR SAM.Date < @R_ToDate)
  AND (@R_BranchID IS NULL OR SAM.BranchID = @R_BranchID);

-- Step 3: Populate stock-out entries
-- Sales
INSERT INTO #StockLedger (ProductID, BranchID, EntryDate, TransType, OutQty)
SELECT 
    SD.ProductID,
    SM.BranchID,
    SM.INVDATE,
    'SALE',
    SD.QTY
FROM restaurant.Inv_SalesMaster SM
JOIN restaurant.Inv_SalesDetail SD ON SD.MasterID = SM.GUID
WHERE SM.Deleted = 0 AND SM.TransType NOT IN ('SR', 'SQ')
  AND (@R_FromDate IS NULL OR SM.INVDATE >= @R_FromDate)
  AND (@R_ToDate IS NULL OR SM.INVDATE < @R_ToDate)
  AND (@R_BranchID IS NULL OR SM.BranchID = @R_BranchID);

-- Production OUT (consumed raw material)
INSERT INTO #StockLedger (ProductID, BranchID, EntryDate, TransType, OutQty)
SELECT 
    PRD.ProductID,
    PRM.BranchID,
    PRM.Date,
    'PRODUCTION-OUT',
    PRD.ProdQauntity
FROM restaurant.Inv_ProductionMaster PRM
JOIN restaurant.Inv_ProductionDetail PRD ON PRD.MasterID = PRM.GUID
WHERE PRM.Deleted = 0
  AND (@R_FromDate IS NULL OR PRM.Date >= @R_FromDate)
  AND (@R_ToDate IS NULL OR PRM.Date < @R_ToDate)
  AND (@R_BranchID IS NULL OR PRM.BranchID = @R_BranchID);

-- Transfer OUT
INSERT INTO #StockLedger (ProductID, BranchID, EntryDate, TransType, OutQty)
SELECT 
    STDTO.ProductID,
    STM.BranchID,
    STM.Date,
    'TRANSFER-OUT',
    STDTO.Quantity
FROM restaurant.Inv_StcokTransferMaster STM
JOIN restaurant.Inv_StcokTransferDetail STDTO ON STDTO.MasterID = STM.GUID
WHERE STM.Deleted = 0
  AND (@R_FromDate IS NULL OR STM.Date >= @R_FromDate)
  AND (@R_ToDate IS NULL OR STM.Date < @R_ToDate)
  AND (@R_BranchID IS NULL OR STM.BranchID = @R_BranchID);

-- Adjustment OUT
INSERT INTO #StockLedger (ProductID, BranchID, EntryDate, TransType, OutQty, Rate, Value)
SELECT 
    SAD.ProductID,
    SAM.BranchID,
    SAM.Date,
    'ADJUSTMENT-OUT',
    ABS(SAD.AdjQuantity),
    0,
    0
FROM restaurant.Inv_StcokAdjustmentMaster SAM
JOIN restaurant.Inv_StcokAdjustmentDetail SAD ON SAD.MasterID = SAM.GUID
WHERE SAM.Deleted = 0 AND SAD.AdjQuantity < 0
  AND (@R_FromDate IS NULL OR SAM.Date >= @R_FromDate)
  AND (@R_ToDate IS NULL OR SAM.Date < @R_ToDate)
  AND (@R_BranchID IS NULL OR SAM.BranchID = @R_BranchID);

-- Step 4: Running WAC Calculation
DECLARE @LoopProductID UNIQUEIDENTIFIER, @LoopBranchID UNIQUEIDENTIFIER;
DECLARE cur CURSOR FOR
SELECT DISTINCT ProductID, BranchID FROM #StockLedger;

OPEN cur;
FETCH NEXT FROM cur INTO @LoopProductID, @LoopBranchID;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @RQ DECIMAL(18,4) = 0;
    DECLARE @RV DECIMAL(18,4) = 0;
    DECLARE @WAC DECIMAL(18,4) = 0;

    DECLARE @ID INT, @InQty DECIMAL(18,4), @OutQty DECIMAL(18,4), @Rate DECIMAL(18,4);

    DECLARE ledger_cursor CURSOR FOR
    SELECT ID, InQty, OutQty, Rate
    FROM #StockLedger
    WHERE ProductID = @LoopProductID AND BranchID = @LoopBranchID
    ORDER BY EntryDate ASC, 
         CASE WHEN InQty > 0 THEN 0 ELSE 1 END, -- process IN before OUT on same day
         ID ASC;


    OPEN ledger_cursor;
    FETCH NEXT FROM ledger_cursor INTO @ID, @InQty, @OutQty, @Rate;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @RQ = @RQ + ISNULL(@InQty, 0) - ISNULL(@OutQty, 0);
        SET @RV = @RV + ISNULL(@InQty, 0) * ISNULL(@Rate, 0) - ISNULL(@OutQty, 0) * ISNULL(@WAC, 0);
        --SET @WAC = CASE WHEN @RQ = 0 THEN 0 ELSE @RV / NULLIF(@RQ, 0) END;
		IF @RQ > 0
			SET @WAC = @RV / NULLIF(@RQ, 0);
-- else: keep previous @WAC unchanged


        UPDATE #StockLedger
        SET RunningQty = @RQ, RunningValue = @RV, WAC = @WAC
        WHERE ID = @ID;

        FETCH NEXT FROM ledger_cursor INTO @ID, @InQty, @OutQty, @Rate;
    END

    CLOSE ledger_cursor;
    DEALLOCATE ledger_cursor;

    FETCH NEXT FROM cur INTO @LoopProductID, @LoopBranchID;
END

CLOSE cur;
DEALLOCATE cur;

-- Step 5: Summary Output
;WITH FinalStock AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ProductID, BranchID ORDER BY EntryDate DESC, ID DESC) AS rn
    FROM #StockLedger
)
SELECT 
    P.Name AS Product,
    B.Name AS BranchName,
    C.Name AS CategoryName,
    T.Name AS TypeName,
    ISNULL(SUM(F.InQty), 0) AS TOTSTOCKIN,
    ISNULL(SUM(F.OutQty), 0) AS TOTSTOCKOUT,
    ISNULL(SUM(F.Value), 0) AS TOTPURCOST,
    ISNULL(FS.RunningQty, 0) AS CURSTOCK,
    ISNULL(FS.WAC, 0) AS WAC
FROM FinalStock F
JOIN (
    SELECT ProductID, BranchID, RunningQty, WAC
    FROM FinalStock WHERE rn = 1
) FS ON F.ProductID = FS.ProductID AND F.BranchID = FS.BranchID
JOIN restaurant.Product P ON F.ProductID = P.GuID
LEFT JOIN (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY MasterID 
                   ORDER BY CreatedDate DESC
               ) AS rn
        FROM restaurant.ProductPriceDetail
        WHERE Deleted = 0
    ) AS RankedPPD
    WHERE rn = 1
) AS PPD ON PPD.MasterID = P.GuID AND PPD.BranchID = @R_BranchID

LEFT JOIN dbo.R_Category C ON PPD.CategoryID = C.GUID
LEFT JOIN dbo.R_Type T ON PPD.TypeID = T.GUID
JOIN dbo.R_Branch B ON F.BranchID = B.GuID
GROUP BY P.GuID, P.Name, B.Name, C.Name, T.Name, FS.RunningQty, FS.WAC
ORDER BY P.Name, B.Name


		SELECT ''AS Product,
		       ''AS [Group],
			   ''AS [Category],
			    
			   0 as Total,
			   ''AS [Section], 
			   ''AS [Counter] 
		FROM #StockLedger

DROP TABLE IF EXISTS #StockLedger;


---- Output with Pagination
--DECLARE @TotalRows INT = (SELECT COUNT(*) FROM #WACSummary);

--SELECT *, @TotalRows AS TotalRowCount
--FROM #WACSummary
--WHERE RowNum > ((@R_PageNumber - 1) * @R_PageSize)
--  AND RowNum <= (@R_PageNumber * @R_PageSize)
--ORDER BY RowNum;

DROP TABLE IF EXISTS #WACSummary;
END

GO
PRINT 'Created or altered restaurant.Report_StockValuePaging.';
GO

-- Stored Procedure: StockLedger_WithWAC
-- Purpose: Generate a detailed stock ledger with Perpetual Weighted Average Cost (WAC) per transaction

CREATE OR ALTER PROCEDURE [restaurant].[StockLedger_WithWAC]
(
    @FromDate DATE = NULL,
    @ToDate DATE = NULL,
    @ProductID UNIQUEIDENTIFIER = NULL,
    @BranchID UNIQUEIDENTIFIER = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET ARITHABORT ON;
    SET XACT_ABORT ON;

    IF OBJECT_ID('tempdb..#StockLedger') IS NOT NULL DROP TABLE #StockLedger;

    CREATE TABLE #StockLedger (
        RowID INT IDENTITY(1,1),
        ProductID UNIQUEIDENTIFIER,
        BranchID UNIQUEIDENTIFIER,
        EntryDate DATETIME,
        RefNo NVARCHAR(100),
        MovementType VARCHAR(10), -- IN or OUT
        Quantity DECIMAL(18, 4),
        UnitCost DECIMAL(18, 4),
        TotalCost DECIMAL(18, 4),
        RunningStock DECIMAL(18, 4),
        RunningCost DECIMAL(18, 4),
        WAC DECIMAL(18, 4)
    );

    -- Insert transactions: Purchases
    INSERT INTO #StockLedger (ProductID, BranchID, EntryDate, RefNo, MovementType, Quantity, UnitCost, TotalCost)
    SELECT PD.ProductID, PR.BranchID, PR.EntryDate, PR.EntryNumber, 'IN', PD.Quantity,
           ISNULL(PD.Rate, 0), ISNULL(PD.Rate, 0) * PD.Quantity
    FROM restaurant.Purchase PR
    JOIN restaurant.PurchaseDetail PD ON PD.MasterID = PR.GuID
    WHERE PR.Deleted = 0 AND PR.ReferenceType = 0
      AND (@FromDate IS NULL OR PR.EntryDate >= @FromDate)
      AND (@ToDate IS NULL OR PR.EntryDate < DATEADD(DAY, 1, @ToDate))
      AND (@BranchID IS NULL OR PR.BranchID = @BranchID)
      AND (@ProductID IS NULL OR PD.ProductID = @ProductID);

    -- Insert transactions: Sales
    INSERT INTO #StockLedger (ProductID, BranchID, EntryDate, RefNo, MovementType, Quantity, UnitCost, TotalCost)
    SELECT SD.ProductID, SM.BranchID, SM.INVDATE, SM.EntryNumber, 'OUT', SD.QTY,
           0, 0
    FROM restaurant.Inv_SalesMaster SM
    JOIN restaurant.Inv_SalesDetail SD ON SD.MasterID = SM.GuID
    WHERE SM.Deleted = 0
      AND (@FromDate IS NULL OR SM.INVDATE >= @FromDate)
      AND (@ToDate IS NULL OR SM.INVDATE < DATEADD(DAY, 1, @ToDate))
      AND (@BranchID IS NULL OR SM.BranchID = @BranchID)
      AND (@ProductID IS NULL OR SD.ProductID = @ProductID);

    -- Additional transactions like Adjustment, Transfers can be added similarly

    -- Recalculate WAC
    DECLARE @LoopProductID UNIQUEIDENTIFIER;
    DECLARE ProductCursor CURSOR FOR SELECT DISTINCT ProductID FROM #StockLedger;
    OPEN ProductCursor;
    FETCH NEXT FROM ProductCursor INTO @LoopProductID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @CurrentStock DECIMAL(18, 4) = 0,
                @CurrentCost DECIMAL(18, 4) = 0,
                @WAC DECIMAL(18, 4) = 0,
                @RowID INT,
                @Qty DECIMAL(18,4),
                @Cost DECIMAL(18,4),
                @MoveType VARCHAR(10);

        DECLARE RowCursor CURSOR FOR
        SELECT RowID, Quantity, UnitCost, MovementType
        FROM #StockLedger
        WHERE ProductID = @LoopProductID
        ORDER BY EntryDate, RowID;

        OPEN RowCursor;
        FETCH NEXT FROM RowCursor INTO @RowID, @Qty, @Cost, @MoveType;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @MoveType = 'IN'
            BEGIN
                SET @CurrentCost += (@Qty * @Cost);
                SET @CurrentStock += @Qty;
                IF @CurrentStock > 0 SET @WAC = @CurrentCost / @CurrentStock;
            END
            ELSE
            BEGIN
                SET @CurrentCost -= (@Qty * @WAC);
                SET @CurrentStock -= @Qty;
                IF @CurrentStock < 0 SET @CurrentStock = 0;
            END

            UPDATE #StockLedger
            SET 
                RunningStock = @CurrentStock,
                RunningCost = @CurrentCost,
                WAC = @WAC,
                UnitCost = CASE WHEN @MoveType = 'OUT' THEN @WAC ELSE UnitCost END,
                TotalCost = CASE WHEN @MoveType = 'OUT' THEN @Qty * @WAC ELSE TotalCost END
            WHERE RowID = @RowID;

            FETCH NEXT FROM RowCursor INTO @RowID, @Qty, @Cost, @MoveType;
        END

        CLOSE RowCursor;
        DEALLOCATE RowCursor;
        FETCH NEXT FROM ProductCursor INTO @LoopProductID;
    END

    CLOSE ProductCursor;
    DEALLOCATE ProductCursor;

    -- Output
    SELECT * FROM #StockLedger ORDER BY ProductID, EntryDate, RowID;

    DROP TABLE #StockLedger;
END

GO
PRINT 'Created or altered restaurant.StockLedger_WithWAC.';
GO

CREATE OR ALTER PROCEDURE [restaurant].[Sync_INVProductionBOQ_Insert]    
@UDT_INVProductionBOQ [restaurant].[Sync_INVProductionBOQMaster_UDT]     READONLY,    
@UDT_INVProductionBOQDetail [restaurant].[Sync_INVProductionBOQDetail_UDT]     READONLY    
AS    
BEGIN TRY    
    BEGIN TRANSACTION    
     MERGE restaurant.Inv_ProductBOQMaster AS BM USING
     (
    SELECT
    [GuID],[BOQdate],Totalqty,ProductID,BranchID,AvgCost,NetCost,Deleted,
    CreatedUser,CreatedDate,UpdatedUser,UpdatedDate
    FROM @UDT_INVProductionBOQ
     )UBM ON UBM.[GuID] = BM.[GuID]
     WHEN MATCHED THEN
           UPDATE SET
      [GuID] = UBM.[GuID]
     ,[BOQdate] = UBM.[BOQdate]
     ,Totalqty = UBM.Totalqty
     ,ProductID = UBM.ProductID
     ,BranchID = UBM.BranchID
     ,AvgCost = UBM.AvgCost
     ,NetCost= UBM.NetCost
     ,Deleted= UBM.Deleted
     ,CreatedUser = UBM.CreatedUser
     ,CreatedDate = UBM.CreatedDate
     ,UpdatedUser=UBM.UpdatedUser
     ,UpdatedDate=UBM.UpdatedDate
     WHEN NOT MATCHED THEN
     INSERT
     (
    [GuID],[BOQdate],Totalqty,ProductID,BranchID,AvgCost,NetCost,Deleted,
    CreatedUser,CreatedDate,UpdatedUser,UpdatedDate)
     VALUES
     (
    UBM.[GuID],UBM.[BOQdate],UBM.Totalqty,UBM.ProductID,UBM.BranchID,UBM.AvgCost,UBM.NetCost,UBM.Deleted,
    UBM.CreatedUser,UBM.CreatedDate,UBM.UpdatedUser,UBM.UpdatedDate
     );

     MERGE restaurant.Inv_ProductBOQDetail AS BD USING    
     (    
     SELECT [GuID],MasterID,ProductID,Quantity,Cost,Deleted,WastagePercentage,CFactor,Unit   
     FROM @UDT_INVProductionBOQDetail    
     )UBD ON UBD.[GuID] = BD.[GuID]    
     WHEN MATCHED THEN    
      UPDATE SET    
          [GuID] = UBD.[GuID]    
      ,MasterID= UBD.MasterID         
      ,ProductID= UBD.ProductID       
      ,Quantity= UBD.Quantity    
      ,Cost= UBD.Cost    
      ,Deleted= UBD.Deleted    
      ,WastagePercentage= UBD.WastagePercentage    
      ,CFactor= UBD.CFactor     
      ,UnitId=UBD.Unit    
     WHEN NOT MATCHED THEN     
     INSERT     
     (    
    [GuID],MasterID,ProductID,Quantity,Cost,Deleted,WastagePercentage,CFactor,UnitId    
     )    
     VALUES    
     (    
    UBD.[GuID],UBD.MasterID,UBD.ProductID,UBD.Quantity,UBD.Cost,UBD.Deleted,UBD.WastagePercentage,UBD.CFactor,UBD.Unit    
     );    
   COMMIT TRANSACTION    
     END TRY    
   BEGIN CATCH    
        ROLLBACK TRANSACTION    
        RETURN -1    
   END CATCH    
RETURN 1      

GO
PRINT 'Created or altered restaurant.Sync_INVProductionBOQ_Insert.';
GO

CREATE OR ALTER PROCEDURE [restaurant].[Sync_ZoneMaster_Insert]
    @UDT_R_Zone [restaurant].[UDT_R_Zone] READONLY
AS
BEGIN
 BEGIN TRY
    BEGIN TRANSACTION

    MERGE [restaurant].[ZoneMaster] AS target
    USING @UDT_R_Zone AS source
        ON target.Guid = source.Guid
    WHEN MATCHED THEN
        UPDATE SET 
            target.Name = source.Name,
            target.OtherLanguageName = source.OtherLanguageName,
            target.BranchID = source.BranchID,
            target.UpdatedDate = source.UpdatedDate,
            target.UpdatedUser = source.UpdatedUser,
            target.Deleted = source.Deleted
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            Guid, Name, OtherLanguageName, BranchID, CreatedDate, UpdatedDate,
            CreatedUser, UpdatedUser, Deleted
        )
        VALUES (
            source.Guid, source.Name, source.OtherLanguageName, source.BranchID,
            source.CreatedDate, source.UpdatedDate, source.CreatedUser, source.UpdatedUser, source.Deleted
        );
	 COMMIT TRANSACTION
     END TRY
   BEGIN CATCH
        ROLLBACK TRANSACTION
        RETURN -1
   END CATCH
 RETURN 1
END

GO
PRINT 'Created or altered restaurant.Sync_ZoneMaster_Insert.';
GO

CREATE OR ALTER PROCEDURE [restaurant].[Update_WAC_ForProduct]
    @ProductID UNIQUEIDENTIFIER,
    @BranchID UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET ARITHABORT ON;
    SET XACT_ABORT ON;

    -- Step 1: Create temporary stock ledger for this product
    IF OBJECT_ID('tempdb..#StockLedger') IS NOT NULL DROP TABLE #StockLedger;

    CREATE TABLE #StockLedger (
        ID INT IDENTITY(1,1),
        ProductID UNIQUEIDENTIFIER,
        BranchID UNIQUEIDENTIFIER,
        EntryDate DATETIME,
        TransType VARCHAR(50),
        InQty DECIMAL(18,4),
        OutQty DECIMAL(18,4),
        Rate DECIMAL(18,4),
        Value DECIMAL(18,4),
        RunningQty DECIMAL(18,4) NULL,
        RunningValue DECIMAL(18,4) NULL,
        WAC DECIMAL(18,4) NULL
    );

    -- Step 2: Populate Inward and Outward stock data for this product only

    -- Opening Stock
    INSERT INTO #StockLedger (ProductID, BranchID, EntryDate, TransType, InQty, Rate, Value)
    SELECT 
        OPD.ProductID,
        OPM.BranchID,
        OPM.Date,
        'OPENING',
        OPD.Quantity,
        ISNULL(OPD.UnitPrice, 0),
        OPD.Quantity * ISNULL(OPD.UnitPrice, 0)
    FROM dbo.OpeningStockMaster OPM
    JOIN dbo.OpeningStockDetail OPD ON OPD.MasterID = OPM.GUID
    WHERE OPD.ProductID = @ProductID AND OPM.BranchID = @BranchID;

    -- Purchase
INSERT INTO #StockLedger (ProductID, BranchID, EntryDate, TransType, InQty, Rate, Value)
SELECT 
    PD.ProductID,
    PR.BranchID,
    PR.EntryDate,
    'PURCHASE',
    PD.Quantity,
    ROUND(
        (ISNULL(PD.Rate, ISNULL(PPD.Cost, 0)) * (1 - ISNULL(PD.DiscPercentage, 0)/100.0)) 
        * (1 + ISNULL(PD.TaxPercentage, 0)/100.0), 4),
    -- Value = Qty * full adjusted rate
    ROUND(
        PD.Quantity *
        (ISNULL(PD.Rate, ISNULL(PPD.Cost, 0)) * (1 - ISNULL(PD.DiscPercentage, 0)/100.0)) 
        * (1 + ISNULL(PD.TaxPercentage, 0)/100.0), 4)
FROM restaurant.Purchase PR
JOIN restaurant.PurchaseDetail PD ON PR.GUID = PD.MasterID
LEFT JOIN restaurant.ProductPriceDetail PPD ON PPD.MasterID = PD.ProductID AND PPD.Deleted = 0
WHERE PD.ProductID = @ProductID AND PR.BranchID = @BranchID AND PR.Deleted = 0 AND PR.TransType = 'PI';


    -- Production IN
    INSERT INTO #StockLedger (ProductID, BranchID, EntryDate, TransType, InQty, Rate, Value)
    SELECT 
        PRM.ProductID,
        PRM.BranchID,
        PRM.Date,
        'PRODUCTION-IN',
        PRM.Quantity,
        ISNULL(PRM.Cost, 0),
        PRM.Quantity * ISNULL(PRM.Cost, 0)
    FROM restaurant.Inv_ProductionMaster PRM
    WHERE PRM.ProductID = @ProductID AND PRM.BranchID = @BranchID AND PRM.Deleted = 0;

    -- Sales
    INSERT INTO #StockLedger (ProductID, BranchID, EntryDate, TransType, OutQty)
    SELECT 
        SD.ProductID,
        SM.BranchID,
        SM.INVDATE,
        'SALE',
        SD.QTY
    FROM restaurant.Inv_SalesMaster SM
    JOIN restaurant.Inv_SalesDetail SD ON SD.MasterID = SM.GUID
    WHERE SD.ProductID = @ProductID AND SM.BranchID = @BranchID AND SM.Deleted = 0;

    -- Production OUT
    INSERT INTO #StockLedger (ProductID, BranchID, EntryDate, TransType, OutQty)
    SELECT 
        PRD.ProductID,
        PRM.BranchID,
        PRM.Date,
        'PRODUCTION-OUT',
        PRD.ProdQauntity
    FROM restaurant.Inv_ProductionMaster PRM
    JOIN restaurant.Inv_ProductionDetail PRD ON PRD.MasterID = PRM.GUID
    WHERE PRD.ProductID = @ProductID AND PRM.BranchID = @BranchID AND PRM.Deleted = 0;

   -- Step 3: Calculate Running WAC with Negative Stock Handling
DECLARE @RQ DECIMAL(18,4) = 0;  -- Running Quantity
DECLARE @RV DECIMAL(18,4) = 0;  -- Running Value
DECLARE @WAC DECIMAL(18,4) = 0; -- Weighted Average Cost

DECLARE @ID INT, 
        @InQty DECIMAL(18,4), 
        @OutQty DECIMAL(18,4), 
        @Rate DECIMAL(18,4);

DECLARE ledger_cursor CURSOR FOR
SELECT ID, InQty, OutQty, Rate
FROM #StockLedger
ORDER BY EntryDate ASC, 
         CASE WHEN InQty > 0 THEN 0 ELSE 1 END, -- IN before OUT
         ID ASC;

OPEN ledger_cursor;
FETCH NEXT FROM ledger_cursor INTO @ID, @InQty, @OutQty, @Rate;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Update running quantity and value
    SET @RQ = @RQ + ISNULL(@InQty, 0) - ISNULL(@OutQty, 0);
    SET @RV = @RV + ISNULL(@InQty, 0) * ISNULL(@Rate, 0) 
                   - ISNULL(@OutQty, 0) * ISNULL(@WAC, 0);

    -- Preserve previous WAC if stock is zero or negative
    IF @RQ <= 0
    BEGIN
        SET @RQ = @RQ;  -- just keep the value
        SET @RV = @RV;
        -- WAC remains unchanged
        -- Optional: log it or set a flag if you want to track negative stock
    END
    ELSE
    BEGIN
        SET @WAC = @RV / NULLIF(@RQ, 0);
    END

    UPDATE #StockLedger
    SET RunningQty = @RQ, 
        RunningValue = @RV, 
        WAC = @WAC
    WHERE ID = @ID;

    FETCH NEXT FROM ledger_cursor INTO @ID, @InQty, @OutQty, @Rate;
END

CLOSE ledger_cursor;
DEALLOCATE ledger_cursor;


    -- Step 4: Get latest WAC and update product price table
    DECLARE @LatestWAC DECIMAL(18,4);

    SELECT TOP 1 @LatestWAC = WAC
    FROM #StockLedger
    ORDER BY EntryDate DESC, ID DESC;

    IF @LatestWAC IS NOT NULL
    BEGIN
        UPDATE restaurant.ProductPriceDetail
        SET Cost = @LatestWAC
        WHERE MasterID = @ProductID AND Deleted = 0;
    END

    DROP TABLE IF EXISTS #StockLedger;
END


GO
PRINT 'Created or altered restaurant.Update_WAC_ForProduct.';
GO


CREATE OR ALTER PROCEDURE [restaurant].[Update_WAC_For_BOQ]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ProductID UNIQUEIDENTIFIER;
    DECLARE @BranchID UNIQUEIDENTIFIER;
    DECLARE @WAC DECIMAL(18, 8);

    -- Cursor to loop through each unique ProductID + BranchID in BOQ
    DECLARE BOQCursor CURSOR FOR
    SELECT DISTINCT D.ProductID, M.BranchID
    FROM restaurant.Inv_ProductBOQDetail D
    INNER JOIN restaurant.Inv_ProductBOQMaster M ON D.MasterID = M.GuID
    WHERE D.Deleted = 0 AND M.Deleted = 0;

    OPEN BOQCursor;
    FETCH NEXT FROM BOQCursor INTO @ProductID, @BranchID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Step 1: Update WAC for the current product and branch
        EXEC restaurant.Update_WAC_ForProduct 
            @ProductID = @ProductID, 
            @BranchID = @BranchID;

        -- Step 2: Get latest WAC value
        SELECT @WAC = Cost
        FROM restaurant.ProductPriceDetail
        WHERE MasterID = @ProductID AND BranchID = @BranchID AND Deleted = 0;

        -- Step 3: Update BOQDetail cost using the fetched WAC
        IF @WAC IS NOT NULL
        BEGIN
            UPDATE D
            SET D.Cost = @WAC
            FROM restaurant.Inv_ProductBOQDetail D
            INNER JOIN restaurant.Inv_ProductBOQMaster M ON D.MasterID = M.GuID
            WHERE D.ProductID = @ProductID 
              AND M.BranchID = @BranchID
              AND D.Deleted = 0 
              AND M.Deleted = 0;
        END

        FETCH NEXT FROM BOQCursor INTO @ProductID, @BranchID;
    END

    CLOSE BOQCursor;
    DEALLOCATE BOQCursor;
END


GO
PRINT 'Created or altered restaurant.Update_WAC_For_BOQ.';
GO

CREATE OR ALTER PROCEDURE [restaurant].[ZoneMaster_GetAll]
    @BranchID UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        GuID,
        Name,
        OtherLanguageName,
        BranchID,
        Deleted,
        CreatedDate,
        UpdatedDate,
		CreatedUser
    FROM 
        [restaurant].[ZoneMaster]
    WHERE 
        Deleted = 0 AND (@BranchID IS NULL OR BranchID = @BranchID)
    ORDER BY 
        Name;
END


GO
PRINT 'Created or altered restaurant.ZoneMaster_GetAll.';
GO

CREATE OR ALTER PROCEDURE [restaurant].[ZoneMaster_InsertUpdateDelete]
    @Action VARCHAR(10),                -- 'INSERT', 'UPDATE', 'DELETE'
    @GuID UNIQUEIDENTIFIER = NULL OUTPUT,
    @Name VARCHAR(100) = NULL,
    @OtherLanguageName NVARCHAR(100) = NULL,
    @BranchID UNIQUEIDENTIFIER = NULL,
	@CreatedUser NVARCHAR(100)	= NULL,
	@CreatedDate DATETIME = Getdate
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'DELETE'
    BEGIN
        IF @GuID IS NOT NULL
        BEGIN
		
            UPDATE [restaurant].[ZoneMaster]
            SET Deleted = 1,
                UpdatedDate = @CreatedDate,
								UpdatedUser = @CreatedUser
            WHERE GuID = @GuID;

            SELECT 1 AS Result;
        END
        ELSE
        BEGIN
            RAISERROR('GuID is required for DELETE operation.', 16, 1);
        END
    END

    ELSE IF @Action = 'INSERT'
    BEGIN
        IF @GuID IS NULL
            SET @GuID = NEWID();
			IF EXISTS (
        SELECT 1 FROM [restaurant].[ZoneMaster]
        WHERE UPPER(Name) = UPPER(@Name)
          AND BranchID = @BranchID
          AND Deleted = 0
    )
    BEGIN
        THROW 51000, 'Same data already exists...', 1;
    END

        INSERT INTO [restaurant].[ZoneMaster] 
            (GuID, Name, OtherLanguageName, BranchID, Deleted, CreatedDate, UpdatedDate, CreatedUser)
        VALUES 
            (@GuID, @Name, @OtherLanguageName, @BranchID, 0, @CreatedDate, GETDATE(), @CreatedUser);

        SELECT 1 AS Result;
    END

    ELSE IF @Action = 'UPDATE'
    BEGIN
        IF @GuID IS NOT NULL
        BEGIN
            IF EXISTS (SELECT 1 FROM [restaurant].[ZoneMaster] WHERE GuID = @GuID)
            BEGIN

			IF EXISTS (
        SELECT 1 FROM [restaurant].[ZoneMaster]
        WHERE UPPER(Name) = UPPER(@Name)
          AND BranchID = @BranchID
          AND Deleted = 0 AND GuID != @GuID
    )
    BEGIN
        THROW 51000, 'Same data already exists...', 1;
    END
                UPDATE [restaurant].[ZoneMaster]
                SET Name = @Name,
                    OtherLanguageName = @OtherLanguageName,
                    BranchID = @BranchID,
                    UpdatedDate = GETDATE(),
					UpdatedUser = @CreatedUser
                WHERE GuID = @GuID;

                SELECT 1 AS Result;
            END
            ELSE
            BEGIN
                RAISERROR('Zone with provided GuID does not exist.', 16, 1);
            END
        END
        ELSE
        BEGIN
            RAISERROR('GuID is required for UPDATE operation.', 16, 1);
        END
    END

    ELSE
    BEGIN
        RAISERROR('Invalid action specified. Use INSERT, UPDATE, or DELETE.', 16, 1);
    END
END


GO
PRINT 'Created or altered restaurant.ZoneMaster_InsertUpdateDelete.';
GO

PRINT 'Section K complete.';
GO

-- ============================================================
-- SECTION L: restaurant.Sale / restaurant.SaleDetail table types
-- (TVP shapes consumed by sale_temp_insert / Sync_Sales_Insert /
-- Sync_SalesTemp_Insert on the Windows POS -> central Web DB sales
-- upload sync path. Structure taken directly from defaultDB / the
-- known-working alsafwah and lavanya customer DBs, column-for-column.)
--
-- 2026-07-12: rewritten from a guarded "IF TYPE_ID(...) IS NULL CREATE TYPE" to an
-- unconditional drop-and-recreate. The guard silently did nothing on any DB that
-- already had an old-shape type (this is exactly what happened on the "arafa" central
-- DB — it had a 67-column restaurant.Sale predating OrderType, the guard skipped it,
-- and every Sale/SalesTemp upload failed with a TVP column-count SqlException, swallowed
-- by a blanket catch in SaleDataAccess.Upload() with zero diagnostic anywhere). A SQL
-- Server table type can't be ALTERed, so the only correct fix is drop dependent procs,
-- drop type, recreate, recreate procs — every time this script runs, unconditionally.
-- This is idempotent (IF EXISTS guards on the drops) and safe to re-run.
--
-- Also fixes a real latent bug in the previous version of this section: SaleDetail's
-- ChairNo/CourseNo columns were declared CourseNo-then-ChairNo, the REVERSE of what the
-- live C# (Axobis.Restaurant.Core/Constants/SqlTableTypeColumns.cs, SALE_DETAIL_COLUMNS)
-- actually sends (ChairNo-then-CourseNo). SQL Server matches table-valued parameters by
-- ORDINAL POSITION, not name, so if this guard had ever fired on a customer with no
-- prior type, it would NOT have thrown — it would have silently swapped chair and course
-- numbers on every sale line. Confirmed via direct code read: ChairNo = physical seat
-- number (frmMultiPaymetEntry.cs "Chair No" grid column, SalesMaster.cs ChairPositions,
-- IsChairEnabled-gated), CourseNo = KOT/kitchen course sequencing (DataSetKOT.xsd).
-- ============================================================
PRINT 'Section L: recreating restaurant.Sale / restaurant.SaleDetail table types and their dependent procedures...';
GO

IF OBJECT_ID('restaurant.sale_temp_insert', 'P') IS NOT NULL
    DROP PROCEDURE [restaurant].[sale_temp_insert];
GO
IF OBJECT_ID('restaurant.Sync_Sales_Insert', 'P') IS NOT NULL
    DROP PROCEDURE [restaurant].[Sync_Sales_Insert];
GO
IF OBJECT_ID('restaurant.Sync_SalesTemp_Insert', 'P') IS NOT NULL
    DROP PROCEDURE [restaurant].[Sync_SalesTemp_Insert];
GO
IF TYPE_ID(N'restaurant.Sale') IS NOT NULL
    DROP TYPE [restaurant].[Sale];
GO
IF TYPE_ID(N'restaurant.SaleDetail') IS NOT NULL
    DROP TYPE [restaurant].[SaleDetail];
GO

CREATE TYPE [restaurant].[Sale] AS TABLE (
    [GuID]                uniqueidentifier NOT NULL,
    [No]                  int              NOT NULL,
    [Date]                datetime         NOT NULL,
    [SectionID]           uniqueidentifier NOT NULL,
    [CounterID]           uniqueidentifier NOT NULL,
    [BillTime]            datetime         NOT NULL,
    [CustomerID]          uniqueidentifier NULL,
    [Total]               decimal(18,8)    NOT NULL,
    [RTotal]              decimal(18,8)    NOT NULL,
    [Tax]                 decimal(18,8)    NOT NULL,
    [Cash]                decimal(18,8)    NULL,
    [Card]                decimal(18,8)    NULL,
    [CardNo]              varchar(50)      NULL,
    [FxPaid]              decimal(18,8)    NULL,
    [FxTypeID]            uniqueidentifier NULL,
    [FxRate]              decimal(18,2)    NULL,
    [FxAmount]            decimal(18,8)    NULL,
    [CustomerCredit]      decimal(18,8)    NOT NULL,
    [Discount]            decimal(18,2)    NULL,
    [DiscountPercentage]  decimal(18,2)    NULL,
    [RoundOff]            decimal(18,8)    NULL,
    [FinancialYearID]     int              NOT NULL,
    [UserID]              int              NOT NULL,
    [CreatedBy]           uniqueidentifier NOT NULL,
    [Remarks]             varchar(250)     NULL,
    [CompanyID]           int              NOT NULL,
    [LastUpdate]          datetime         NOT NULL,
    [BranchID]            uniqueidentifier NULL,
    [Deleted]             bit              NULL,
    [Refund]              bit              NULL,
    [TransactionDate]     datetime         NULL,
    [Cancelled]           bit              NULL,
    [WaiterID]            uniqueidentifier NULL,
    [IsPending]           bit              NULL,
    [ProdDiscount]        decimal(18,8)    NULL,
    [CustomerGSTNo]       varchar(50)      NULL,
    [BillNo]              varchar(50)      NULL,
    [SeriesType]          int              NULL,
    [TableID]             uniqueidentifier NULL,
    [CancelReason]        varchar(250)     NULL,
    [TokenNo]             int              NULL,
    [IsDespatched]        bit              NULL,
    [IsSettled]           bit              NULL,
    [DeliveryDate]        datetime         NULL,
    [DeliveryTime]        datetime         NULL,
    [DeliveryRemarks]     varchar(50)      NULL,
    [IsShiftClosed]       bit              NULL,
    [Merged]              bit              NULL,
    [TabBillNo]           varchar(50)      NULL,
    [ChairPositions]      varchar(50)      NULL,
    [NoOfChairs]          int              NULL,
    [RedeemPoints]        int              NULL,
    [Redeem]              decimal(18,2)    NULL,
    [TabID]               varchar(100)     NULL,
    [Pax]                 int              NULL,
    [ShiftNumber]         int              NULL,
    [CardID]              varchar(100)     NULL,
    [CessAmount]          decimal(18,2)    NOT NULL,
    [IsComplementary]     bit              NULL,
    [ComplementaryTotal]  decimal(18,8)    NULL,
    [IsprintedFromPay]    bit              NULL,
    [WaiterRemarks]       nvarchar(100)    NULL,
    [IsSaved]             bit              NOT NULL,
    [IsTakenForUpload]    bit              NULL,
    [EditedAfterUpload]   bit              NULL,
    [VehicleNo]           varchar(100)     NULL,
    [UpdatedUser]         uniqueidentifier NULL,
    [OrderType]           varchar(20)      NULL
);
GO

CREATE TYPE [restaurant].[SaleDetail] AS TABLE (
    [GuID]                  uniqueidentifier NULL,
    [MasterID]              uniqueidentifier NULL,
    [ProductID]             uniqueidentifier NOT NULL,
    [Quantity]              decimal(18,2)    NOT NULL,
    [BaseQuantity]          decimal(18,2)    NOT NULL,
    [UnitRate]              decimal(18,8)    NOT NULL,
    [TaxID]                 uniqueidentifier NULL,
    [TaxPercentage]         decimal(18,2)    NOT NULL,
    [Tax]                   decimal(18,8)    NOT NULL,
    [DiscPercentage]        decimal(18,2)    NOT NULL,
    [Discount]              decimal(18,8)    NOT NULL,
    [UnitID]                uniqueidentifier NULL,
    [ItemTypeID]            uniqueidentifier NULL,
    [Deleted]               bit              NULL,
    [IsTaxIncludedInPrice]  bit              NULL,
    [Cancelled]             bit              NULL,
    [IsStockUpdated]        bit              NULL,
    [Remarks]               varchar(MAX)     NULL,
    [R_ProductUpdated]      bit              NULL,
    [Merged]                bit              NOT NULL,
    [CessAmount]            decimal(18,8)    NOT NULL,
    [ChairNo]               int              NOT NULL,
    [CourseNo]              int              NOT NULL
);
GO

PRINT 'Recreating restaurant.Sync_Sales_Insert...';
GO
CREATE PROCEDURE [restaurant].[Sync_Sales_Insert]

	@sale Restaurant.Sale READONLY,
	@saleDetail Restaurant.SaleDetail READONLY,
	@saleComboDetail Restaurant.SaleComboDetail READONLY,
	@saleDelivery Restaurant.SaleDelivery READONLY,
	--@saleDeliveryDetail Restaurant.SaleDeliveryDetail READONLY,
	@saleProductModifierDetail Restaurant.SaleProductModifierDetail READONLY,
	@salePaymentDetail Restaurant.SalePaymentDetail READONLY,
	@miscellaneousSalesAmount Restaurant.MiscellaneousSalesAmount READONLY
AS

 BEGIN TRY
    BEGIN TRANSACTION

    MERGE dbo.[R_SalesMaster] AS trg
    USING @sale AS s
      ON s.[Guid] = trg.Guid AND s.BranchID = trg.BranchID
     WHEN MATCHED THEN
       update  set
	   [GuID] = s.[GuID],
       [No] = s.[No],
       [Date] = s.[Date],
       SectionID = s.SectionID,
       CounterID = s.CounterID,
       BillTime =s.BillTime,
       CustomerID = s.CustomerID,
       Total = s.Total,
       RTotal = s.RTotal,
       Tax = s.Tax,
       Cash = s.Cash,
       [Card] = s.[Card],
       CardNo = s.CardNo,
       FxPaid = s.FxPaid,
       FxTypeID = s.FxTypeID,
       FxRate = s.FxRate,
       FxAmount = s.FxAmount,
       CustomerCredit = s.CustomerCredit,
       Discount = s.Discount,
	   DiscountPercentage = s.DiscountPercentage,
	   RoundOff = s.RoundOff,
       FinancialYearID = s.FinancialYearID,
       UserID = s.UserID,
       CreatedBy = s.CreatedBy,
       Remarks = s.Remarks,
       CompanyID = s.CompanyID,
       BranchID = s.BranchID,
       Deleted = s.Deleted,
       Refund = s.Refund,
       TransactionDate = s.TransactionDate,
       Cancelled = s.Cancelled,
       WaiterID = s.WaiterID,
       IsPending = s.IsPending,
       ProdDiscount = s.ProdDiscount,
       CustomerGSTNo = s.CustomerGSTNo,
       BillNo = s.BillNo,
       SeriesType = s.SeriesType,
       TableID =s. TableID,
       TokenNo = s.TokenNo,
       IsDespatched = s.IsDespatched,
       IsSettled = s.IsSettled,
       DeliveryDate = s.DeliveryDate,
       DeliveryTime = s.DeliveryTime,
       DeliveryRemarks =s. DeliveryRemarks,
       IsShiftClosed = s.IsShiftClosed,
       TabBillNo = s.TabBillNo,
       ChairPositions = s.ChairPositions,
       NoOfChairs = s.NoOfChairs,
       RedeemPoints =s. RedeemPoints,
       Redeem = s.Redeem,
       TabID = s.TabID,
       Pax = s.Pax,
       ShiftNumber = s.ShiftNumber,
       CardID = s.CardID,
       CessAmount = s.CessAmount,
       IsComplementary = s.IsComplementary,
       ComplementaryTotal = s.ComplementaryTotal,
       WaiterRemarks = s.WaiterRemarks,
       IsSaved = s.IsSaved,
       IsTakenForUpload = s.IsTakenForUpload,
       EditedAfterUpload = s.EditedAfterUpload,
	   VehicleNo = s.VehicleNo,
	   Merged = s.Merged,
	   LastUpdate = s.LastUpdate,
	   CancelReason = s.CancelReason,
	   IsPrintedFromPay = s.IsPrintedFromPay,
	   UpdatedUser = s.UpdatedUser,
		OrderType= s.OrderType
     WHEN NOT MATCHED BY TARGET THEN
      INSERT
	(
			[GuID],
            [No]
           ,[Date]
           ,[SectionID]
           ,[CounterID]
           ,[BillTime]
           ,[CustomerID]
           ,[Total]
           ,[RTotal]
           ,[Tax]
           ,[Cash]
           ,[Card]
           ,[CardNo]
           ,[FxPaid]
           ,[FxTypeID]
           ,[FxRate]
           ,[FxAmount]
           ,[CustomerCredit]
           ,[Discount]
           ,[DiscountPercentage]
           ,[RoundOff]
           ,[FinancialYearID]
           ,[UserID]
           ,[CreatedBy]
           ,[Remarks]
           ,[CompanyID]
           ,[BranchID]
           ,[Deleted]
           ,[Refund]
           ,[TransactionDate]
           ,[Cancelled]
           ,[WaiterID]
           ,[IsPending]
           ,[ProdDiscount]
           ,[CustomerGSTNo]
           ,[BillNo]
           ,[SeriesType]
           ,[TableID]
           ,[TokenNo]
           ,[IsDespatched]
           ,[IsSettled]
           ,[DeliveryDate]
           ,[DeliveryTime]
           ,[DeliveryRemarks]
           ,[IsShiftClosed]
           ,[TabBillNo]
           ,[ChairPositions]
           ,[NoOfChairs]
           ,[RedeemPoints]
           ,[Redeem]
           ,[TabID]
           ,[Pax]
           ,[ShiftNumber]
           ,[CardID]
           ,[CessAmount]
           ,[IsComplementary]
           ,[ComplementaryTotal]
           ,[WaiterRemarks]
           ,[IsSaved]
           ,[IsTakenForUpload]
           ,[EditedAfterUpload]
		   ,[VehicleNo]
		   ,Merged
		   ,LastUpdate
		   ,CancelReason
		   ,IsPrintedFromPay
		   ,UpdatedUser,
		   OrderType)
     values
	     ( [GuID],
          [No],
          [Date],
          SectionID,
          CounterID,
          BillTime,
          CustomerID,
          Total,
          RTotal,
          Tax,
          Cash,
          [Card],
          CardNo,
          FxPaid,
          FxTypeID,
          FxRate,
          FxAmount,
          CustomerCredit,
          Discount,
          DiscountPercentage,
          RoundOff,
          FinancialYearID,
          UserID,
          CreatedBy,
          Remarks,
          CompanyID,
          BranchID,
          Deleted,
          Refund,
          TransactionDate,
          Cancelled,
          WaiterID,
          IsPending,
          ProdDiscount,
          CustomerGSTNo,
          BillNo,
          SeriesType,
          TableID,
          TokenNo,
          IsDespatched,
          IsSettled,
          DeliveryDate,
          DeliveryTime,
          DeliveryRemarks,
          IsShiftClosed,
          TabBillNo,
          ChairPositions,
          NoOfChairs,
          RedeemPoints,
          Redeem,
          TabID,
          Pax,
          ShiftNumber,
          CardID,
          CessAmount,
          IsComplementary,
          ComplementaryTotal,
          WaiterRemarks,
          IsSaved,
          IsTakenForUpload,
          EditedAfterUpload,
		  VehicleNo,
		  Merged
		  ,LastUpdate
		  ,CancelReason
		  ,IsPrintedFromPay
		  ,UpdatedUser,
		  OrderType) ;


	-------------------SalesDetailInsertion--------------------------------------------------


	DELETE R_SalesDetail WHERE MasterID in (select MasterID from @saleDetail)

	INSERT INTO [dbo].[R_SalesDetail]
           (
		   [GuID],
           [MasterID]
           ,[ProductID]
           ,[Quantity]
           ,[BaseQuantity]
           ,[UnitRate]
           ,[TaxID]
           ,[TaxPercentage]
           ,[Tax]
           ,[DiscPercentage]
           ,[Discount]
           ,[UnitID]
           ,[ItemTypeID]
           ,[Deleted]
           ,[IsTaxIncludedInPrice]
           ,[Cancelled]
           --,[IsStockUpdated]
           ,[Remarks]
           --,[R_ProductUpdated]
           ,[Merged]
           ,[CessAmount], CourseNo, ChairNo)

          select
		  [GuID],
           MasterID,
           ProductID,
           Quantity,
           BaseQuantity,
           UnitRate,
           TaxID,
           TaxPercentage,
           Tax,
           DiscPercentage,
           Discount,
           UnitID,
           ItemTypeID,
           Deleted,
           IsTaxIncludedInPrice,
           Cancelled,
          -- IsStockUpdated,
           Remarks,
          -- R_ProductUpdated,
           Merged,
           CessAmount, CourseNo, ChairNo from @saleDetail


	-------------SaleComboDetailInsertion-----------------------------------


	DELETE R_SalesComboDetail WHERE MasterID in(select MasterID from @saleComboDetail)

	INSERT INTO [dbo].[R_SalesComboDetail]
           (
		    DetailGuID
           ,[ProductID]
           ,[Quantity]
           ,[TypeID]
           ,[MasterProductID]
		   ,MasterID)

          select
          DetailGuID,
           ProductID,
           Quantity,
           TypeID,
           MasterProductID
		   ,MasterID
		   from @saleComboDetail


----	-------------------SalesPaymentDetailInsertion------------------------------------------------------------


	DELETE R_SalesPaymentDetail WHERE MasterID in (select MasterID from @salePaymentDetail)

	INSERT INTO [dbo].[R_SalesPaymentDetail]
           ([MasterID]
           ,[Type]
           ,[Amount]
           ,[CardNo]
           ,[CardTypeID]
           ,[FxTypeID]
           ,[FxPaid]
           ,[FxRate]
           ,[CustomerID]
           ,[deleted]
           ,[Cancelled])

           select
           MasterID,
           Type,
           Amount,
           CardNo,
           CardTypeID,
           FxTypeID,
           FxPaid,
           FxRate,
           CustomerID,
           deleted,
           Cancelled from @salePaymentDetail

----------------------------SalesProductModifierDetail Insertion------------------------------------------


	DELETE R_SalesProductModifierDetail WHERE MasterID in (select MasterID from @saleProductModifierDetail)

	INSERT INTO [dbo].[R_SalesProductModifierDetail]
           ([MasterID]
           ,[ProductID]
           ,[IsVoid]
           ,[Rate]
           ,[Quantity]
           ,[Cancelled]
           ,[Merged]
           ,[ModifierID]
           ,[ParentVoid]
           ,[VoidReason]
           ,[WastedQty])

    select
           MasterID,
           ProductID,
           IsVoid,
           Rate,
           Quantity,
           Cancelled,
           Merged,
           ModifierID,
           ParentVoid,
           VoidReason,
           WastedQty from @saleProductModifierDetail
-- ------------------------SalesMiscellaneousSalesAmount Insertion------------------------------------------
 DELETE [R_MiscellaneousSalesAmount] WHERE MasterID in (select MasterID from @miscellaneousSalesAmount)
 INSERT INTO [dbo].[R_MiscellaneousSalesAmount]
    ([MasterID]
	 ,[DelveryID]
	 ,[ContainerID]
	 ,[OthrchargeID]
	 ,[DelAmount]
	 ,[ContAmount]
	 ,[OtherAmount]
	 ,[DayCloseStatus]
	 ,[Merged])
  select
       MasterID,
	   DelveryID,
       ContainerID,
	   OthrchargeID,
	   DelAmount,
	   ContAmount,
	   OtherAmount,
	   DayCloseStatus,
	   Merged from @miscellaneousSalesAmount

 ------------------------SalesDeliveryDetails Insertion------------------------------------------


 --DELETE [R_SalesDeliveryDetails] WHERE MasterID in(select MasterID from @saleDeliveryDetail)

 --INSERT INTO [dbo].[R_SalesDeliveryDetails]
 --          ([MasterID]
 --          ,[CustomerID]
 --          ,[EmployeeID]
 --          ,[DeliveryDate]
 --          ,[DeliveryTime]
 --          ,[DeliveryRemarks])

	--	select
 --          MasterID,
 --          CustomerID,
 --          EmployeeID,
 --          DeliveryDate,
 --          DeliveryTime,
 --          DeliveryRemarks from @saleDeliveryDetail

-- ------------------------SalesDelivery Insertion------------------------------------------

 DELETE [R_SalesDelivery] WHERE MasterID in (select MasterID from @saleDelivery)

 INSERT INTO [dbo].[R_SalesDelivery]
           (
		   [Guid],
           [MasterID],
           [IsClosed])
    select
		   newid(),
           MasterID,
		   0 from @saleDelivery


	   		 COMMIT TRANSACTION
     END TRY
   BEGIN CATCH
        ROLLBACK TRANSACTION
        RETURN -1
   END CATCH
 RETURN 1
GO

PRINT 'Recreating restaurant.Sync_SalesTemp_Insert...';
GO
Create PROCEDURE [restaurant].[Sync_SalesTemp_Insert]

	@sale Restaurant.Sale READONLY,
	@saleDetail Restaurant.SaleDetail READONLY,
	@saleComboDetail Restaurant.SaleComboDetail READONLY,
	@saleDelivery Restaurant.SaleDelivery READONLY,
	--@saleDeliveryDetail Restaurant.SaleDeliveryDetail READONLY,
	@saleProductModifierDetail Restaurant.SaleProductModifierDetail READONLY,
	@salePaymentDetail Restaurant.SalePaymentDetail READONLY,
	@miscellaneousSalesAmount Restaurant.MiscellaneousSalesAmount READONLY
AS
DECLARE @TransactionDate DATETIME = (SELECT TOP 1 TransactionDate from @sale order by TransactionDate desc)
DECLARE @BranchID UNIQUEIDENTIFIER = (SELECT TOP 1 BranchID from @sale order by TransactionDate desc)

 BEGIN TRY
    BEGIN TRANSACTION

	MERGE dbo.[R_SalesTempMaster] AS trg
    USING @sale AS s
      ON s.[Guid] = trg.Guid
     WHEN MATCHED THEN
       update  set
	   [GuID] = s.[GuID],
       [No] = s.[No],
       [Date] = s.[Date],
       SectionID = s.SectionID,
       CounterID = s.CounterID,
       BillTime =s.BillTime,
       CustomerID = s.CustomerID,
       Total = s.Total,
       RTotal = s.RTotal,
       Tax = s.Tax,
       Cash = s.Cash,
       [Card] = s.[Card],
       CardNo = s.CardNo,
       FxPaid = s.FxPaid,
       FxTypeID = s.FxTypeID,
       FxRate = s.FxRate,
       FxAmount = s.FxAmount,
       CustomerCredit = s.CustomerCredit,
       Discount = s.Discount,
	   DiscountPercentage = s.DiscountPercentage,
	   RoundOff = s.RoundOff,
       FinancialYearID = s.FinancialYearID,
       UserID = s.UserID,
       CreatedBy = s.CreatedBy,
       Remarks = s.Remarks,
       CompanyID = s.CompanyID,
       BranchID = s.BranchID,
       Deleted = s.Deleted,
       Refund = s.Refund,
       TransactionDate = s.TransactionDate,
       Cancelled = s.Cancelled,
       WaiterID = s.WaiterID,
       IsPending = s.IsPending,
       ProdDiscount = s.ProdDiscount,
       CustomerGSTNo = s.CustomerGSTNo,
       BillNo = s.BillNo,
       SeriesType = s.SeriesType,
       TableID =s. TableID,
       TokenNo = s.TokenNo,
       IsDespatched = s.IsDespatched,
       IsSettled = s.IsSettled,
       DeliveryDate = s.DeliveryDate,
       DeliveryTime = s.DeliveryTime,
       DeliveryRemarks =s. DeliveryRemarks,
       IsShiftClosed = s.IsShiftClosed,
       TabBillNo = s.TabBillNo,
       ChairPositions = s.ChairPositions,
       NoOfChairs = s.NoOfChairs,
       RedeemPoints =s. RedeemPoints,
       Redeem = s.Redeem,
       TabID = s.TabID,
       Pax = s.Pax,
       ShiftNumber = s.ShiftNumber,
       CardID = s.CardID,
       CessAmount = s.CessAmount,
       IsComplementary = s.IsComplementary,
       ComplementaryTotal = s.ComplementaryTotal,
       WaiterRemarks = s.WaiterRemarks,
       IsSaved = s.IsSaved,
       IsTakenForUpload = s.IsTakenForUpload,
       EditedAfterUpload = s.EditedAfterUpload,
	   VehicleNo = s.VehicleNo,
	   Merged = s.Merged,
	   LastUpdate = s.LastUpdate,
	   CancelReason = s.CancelReason,
	   IsPrintedFromPay = s.IsPrintedFromPay,
	   UpdatedUser = s.UpdatedUser,
	   OrderType = S.OrderType
     WHEN NOT MATCHED BY TARGET THEN
      INSERT
	(
			[GuID],
            [No]
           ,[Date]
           ,[SectionID]
           ,[CounterID]
           ,[BillTime]
           ,[CustomerID]
           ,[Total]
           ,[RTotal]
           ,[Tax]
           ,[Cash]
           ,[Card]
           ,[CardNo]
           ,[FxPaid]
           ,[FxTypeID]
           ,[FxRate]
           ,[FxAmount]
           ,[CustomerCredit]
           ,[Discount]
           ,[DiscountPercentage]
           ,[RoundOff]
           ,[FinancialYearID]
           ,[UserID]
           ,[CreatedBy]
           ,[Remarks]
           ,[CompanyID]
           ,[BranchID]
           ,[Deleted]
           ,[Refund]
           ,[TransactionDate]
           ,[Cancelled]
           ,[WaiterID]
           ,[IsPending]
           ,[ProdDiscount]
           ,[CustomerGSTNo]
           ,[BillNo]
           ,[SeriesType]
           ,[TableID]
           ,[TokenNo]
           ,[IsDespatched]
           ,[IsSettled]
           ,[DeliveryDate]
           ,[DeliveryTime]
           ,[DeliveryRemarks]
           ,[IsShiftClosed]
           ,[TabBillNo]
           ,[ChairPositions]
           ,[NoOfChairs]
           ,[RedeemPoints]
           ,[Redeem]
           ,[TabID]
           ,[Pax]
           ,[ShiftNumber]
           ,[CardID]
           ,[CessAmount]
           ,[IsComplementary]
           ,[ComplementaryTotal]
           ,[WaiterRemarks]
           ,[IsSaved]
           ,[IsTakenForUpload]
           ,[EditedAfterUpload]
		   ,[VehicleNo]
		   ,Merged
		   ,LastUpdate
		   ,CancelReason
		   ,IsPrintedFromPay
		   ,UpdatedUser,
		   OrderType)
     values
	     ( [GuID],
          [No],
          [Date],
          SectionID,
          CounterID,
          BillTime,
          CustomerID,
          Total,
          RTotal,
          Tax,
          Cash,
          [Card],
          CardNo,
          FxPaid,
          FxTypeID,
          FxRate,
          FxAmount,
          CustomerCredit,
          Discount,
          DiscountPercentage,
          RoundOff,
          FinancialYearID,
          UserID,
          CreatedBy,
          Remarks,
          CompanyID,
          BranchID,
          Deleted,
          Refund,
          TransactionDate,
          Cancelled,
          WaiterID,
          IsPending,
          ProdDiscount,
          CustomerGSTNo,
          BillNo,
          SeriesType,
          TableID,
          TokenNo,
          IsDespatched,
          IsSettled,
          DeliveryDate,
          DeliveryTime,
          DeliveryRemarks,
          IsShiftClosed,
          TabBillNo,
          ChairPositions,
          NoOfChairs,
          RedeemPoints,
          Redeem,
          TabID,
          Pax,
          ShiftNumber,
          CardID,
          CessAmount,
          IsComplementary,
          ComplementaryTotal,
          WaiterRemarks,
          IsSaved,
          IsTakenForUpload,
          EditedAfterUpload,
		  VehicleNo,
		  Merged
		  ,LastUpdate
		  ,CancelReason
		  ,IsPrintedFromPay
		  ,UpdatedUser,
		  OrderType) ;

	-------------------SalesDetailInsertion--------------------------------------------------


	DELETE R_SalesTempDetail WHERE MasterID in (select MasterID from @saleDetail)

	INSERT INTO [dbo].[R_SalesTempDetail]
           (
		   [GuID],
           [MasterID]
           ,[ProductID]
           ,[Quantity]
           ,[BaseQuantity]
           ,[UnitRate]
           ,[TaxID]
           ,[TaxPercentage]
           ,[Tax]
           ,[DiscPercentage]
           ,[Discount]
           ,[UnitID]
           ,[ItemTypeID]
           ,[Deleted]
           ,[IsTaxIncludedInPrice]
           ,[Cancelled]
           ,[IsStockUpdated]
           ,[Remarks]
           ,[R_ProductUpdated]
           ,[Merged]
           ,[CessAmount], ChairNo, CourseNo)

          select
		  [GuID],
           MasterID,
           ProductID,
           Quantity,
           BaseQuantity,
           UnitRate,
           TaxID,
           TaxPercentage,
           Tax,
           DiscPercentage,
           Discount,
           UnitID,
           ItemTypeID,
           Deleted,
           IsTaxIncludedInPrice,
           Cancelled,
           IsStockUpdated,
           Remarks,
           R_ProductUpdated,
           Merged,
           CessAmount, ChairNo, CourseNo from @saleDetail


	-------------SaleComboDetailInsertion-----------------------------------

	DELETE [R_SalesTempComboDetail] WHERE MasterID in(select MasterID from @saleComboDetail)

	INSERT INTO [dbo].[R_SalesTempComboDetail]
           (
		    DetailGuID
           ,[ProductID]
           ,[Quantity]
           ,[TypeID]
           ,[MasterProductID]
		   ,MasterID)

          select
          DetailGuID,
           ProductID,
           Quantity,
           TypeID,
           MasterProductID
		   ,MasterID
		   from @saleComboDetail


--	-------------------SalesPaymentDetailInsertion------------------------------------------------------------


	DELETE R_SalesTempPaymentDetail WHERE MasterID in (select MasterID from @salePaymentDetail)

	INSERT INTO [dbo].[R_SalesTempPaymentDetail]
           ([MasterID]
           ,[Type]
           ,[Amount]
           ,[CardNo]
           ,[CardTypeID]
           ,[FxTypeID]
           ,[FxPaid]
           ,[FxRate]
           ,[CustomerID]
           ,[deleted]
           ,[Cancelled])

           select
           MasterID,
           Type,
           Amount,
           CardNo,
           CardTypeID,
           FxTypeID,
           FxPaid,
           FxRate,
           CustomerID,
           deleted,
           Cancelled from @salePaymentDetail

--------------------------SalesProductModifierDetail Insertion------------------------------------------


	DELETE R_SalesTempProductModifierDetail WHERE MasterID in (select MasterID from @saleProductModifierDetail)

	INSERT INTO [dbo].[R_SalesTempProductModifierDetail]
           ([MasterID]
           ,[ProductID]
           ,[IsVoid]
           ,[Rate]
           ,[Quantity]
           ,[Cancelled]
           ,[Merged]
           ,[ModifierID]
           ,[ParentVoid]
           ,[VoidReason]
           ,[WastedQty])

    select
           MasterID,
           ProductID,
           IsVoid,
           Rate,
           Quantity,
           Cancelled,
           Merged,
           ModifierID,
           ParentVoid,
           VoidReason,
           WastedQty from @saleProductModifierDetail
 -- ------------------------SalesMiscellaneousSalesAmount Insertion------------------------------------------
 DELETE [R_MiscellaneousSalesAmount] WHERE MasterID in (select MasterID from @miscellaneousSalesAmount)
 INSERT INTO [dbo].[R_MiscellaneousSalesAmount]
    ([MasterID]
	 ,[DelveryID]
	 ,[ContainerID]
	 ,[OthrchargeID]
	 ,[DelAmount]
	 ,[ContAmount]
	 ,[OtherAmount]
	 ,[DayCloseStatus]
	 ,[Merged])
  select
       MasterID,
	   DelveryID,
       ContainerID,
	   OthrchargeID,
	   DelAmount,
	   ContAmount,
	   OtherAmount,
	   DayCloseStatus,
	   Merged from @miscellaneousSalesAmount

 ------------------------SalesDeliveryDetails Insertion------------------------------------------


 --DELETE [R_SalesTempDeliveryDetails] WHERE MasterID in(select MasterID from @saleDeliveryDetail)

 --INSERT INTO [dbo].[R_SalesTempDeliveryDetails]
 --          ([MasterID]
 --          ,[CustomerID]
 --          ,[EmployeeID]
 --          ,[DeliveryDate]
 --          ,[DeliveryTime]
 --          ,[DeliveryRemarks])

	--	select
 --          MasterID,
 --          CustomerID,
 --          EmployeeID,
 --          DeliveryDate,
 --          DeliveryTime,
 --          DeliveryRemarks from @saleDeliveryDetail

 ------------------------SalesDelivery Insertion------------------------------------------

 --DELETE [R_SalesTempDelivery] WHERE MasterID in (select MasterID from @saleDelivery)

 --INSERT INTO [dbo].[R_SalesTempDelivery]
 --          (
 --          [IsClosed],
 --          [MasterID])
 --    select
	--	   1,
 --          MasterID from @saleDelivery

------------------------------------

 DELETE [R_SalesTempDelivery] WHERE MasterID in (select MasterID from @saleDelivery)

 INSERT INTO [dbo].[R_SalesTempDelivery]
           (
		   [Guid],
           [MasterID],
           [IsClosed])
    select
		   newid(),
           MasterID,
		   1 from @saleDelivery



	DELETE FROM [R_SalesMaster]
	WHERE TransactionDate<=@TransactionDate AND BranchID = @BranchID

	DELETE FROM [R_SalesDetail]
	WHERE MasterID NOT IN (SELECT [Guid] FROM [R_SalesMaster])

	DELETE FROM [R_SalesComboDetail]
	WHERE DetailGuID NOT IN (SELECT [Guid] FROM [R_SalesDetail])

	DELETE FROM R_SalesPaymentDetail
	WHERE MasterID NOT IN (SELECT [Guid] FROM [R_SalesMaster])

	DELETE FROM R_SalesProductModifierDetail
	WHERE MasterID NOT IN (SELECT [Guid] FROM [R_SalesMaster])

	DELETE FROM [R_SalesDeliveryDetails]
	WHERE MasterID NOT IN (SELECT [Guid] FROM [R_SalesMaster])

	DELETE FROM [R_SalesDelivery]
	WHERE MasterID NOT IN (SELECT [Guid] FROM [R_SalesMaster])

	DELETE FROM R_SalesED
	WHERE MasterID NOT IN (SELECT [Guid] FROM [R_SalesMaster])



	COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        RETURN -1
   END CATCH
 RETURN 1
GO

PRINT 'Recreating restaurant.sale_temp_insert...';
GO
Create PROCEDURE [restaurant].[sale_temp_insert]

	@sale Restaurant.Sale READONLY,
	@saleDetail Restaurant.SaleDetail READONLY,
	@saleComboDetail Restaurant.SaleComboDetail READONLY,
	@salePaymentDetail Restaurant.SalePaymentDetail READONLY,
	@saleProductModifierDetail Restaurant.SaleProductModifierDetail READONLY,
	@saleDeliveryDetail Restaurant.SaleDeliveryDetail READONLY,
	@saleDelivery Restaurant.SaleDelivery READONLY
AS

begin
MERGE dbo.[R_SalesTempMaster] AS trg
    USING @sale AS s
      ON s.Guid = trg.Guid
     WHEN MATCHED THEN
       update  set

       [No] = s.No,
       [Date] = s.Date,
       SectionID = s.SectionID,
       CounterID = s.CounterID,
       BillTime =s.BillTime,
       CustomerID = s.CustomerID,
       Total = s.Total,
       RTotal = s.RTotal,
       Tax = s.Tax,
       Cash = s.Cash,
       [Card] = s.Card,
       CardNo = s.CardNo,
       FxPaid = s.FxPaid,
       FxTypeID = s.FxTypeID,
       FxRate = s.FxRate,
       FxAmount = s.FxAmount,
       CustomerCredit = s.CustomerCredit,
       Discount = s.Discount,
	   DiscountPercentage = s.DiscountPercentage,
	   RoundOff = s.RoundOff,
       FinancialYearID = s.FinancialYearID,
       UserID = s.UserID,
       CreatedBy = s.CreatedBy,
       Remarks = s.Remarks,
       CompanyID = s.CompanyID,
       BranchID = s.BranchID,
       Deleted = s.Deleted,
       Refund = s.Refund,
       TransactionDate = s.TransactionDate,
       Cancelled = s.Cancelled,
       WaiterID = s.WaiterID,
       IsPending = s.IsPending,
       ProdDiscount = s.ProdDiscount,
       CustomerGSTNo = s.CustomerGSTNo,
       BillNo = s.BillNo,
       SeriesType = s.SeriesType,
       TableID =s. TableID,
       TokenNo = s.TokenNo,
       IsDespatched = s.IsDespatched,
       IsSettled = s.IsSettled,
       DeliveryDate = s.DeliveryDate,
       DeliveryTime = s.DeliveryTime,
       DeliveryRemarks =s. DeliveryRemarks,
       IsShiftClosed = s.IsShiftClosed,
       TabBillNo = s.TabBillNo,
       ChairPositions = s.ChairPositions,
       NoOfChairs = s.NoOfChairs,
       RedeemPoints =s. RedeemPoints,
       Redeem = s.Redeem,
       TabID = s.TabID,
       Pax = s.Pax,
       ShiftNumber = s.ShiftNumber,
       CardID = s.CardID,
       CessAmount = s.CessAmount,
       IsComplementary = s.IsComplementary,
       ComplementaryTotal = s.ComplementaryTotal,
       WaiterRemarks = s.WaiterRemarks,
       IsSaved = s.IsSaved,
       IsTakenForUpload = s.IsTakenForUpload,
       EditedAfterUpload = s.EditedAfterUpload,
	   VehicleNo = s.VehicleNo,
	   Merged = s.Merged ,
	   OrderType = s.OrderType
     WHEN NOT MATCHED BY TARGET THEN
      INSERT
	(
			[GuID],
            [No]
           ,[Date]
           ,[SectionID]
           ,[CounterID]
           ,[BillTime]
           ,[CustomerID]
           ,[Total]
           ,[RTotal]
           ,[Tax]
           ,[Cash]
           ,[Card]
           ,[CardNo]
           ,[FxPaid]
           ,[FxTypeID]
           ,[FxRate]
           ,[FxAmount]
           ,[CustomerCredit]
           ,[Discount]
           ,[DiscountPercentage]
           ,[RoundOff]
           ,[FinancialYearID]
           ,[UserID]
           ,[CreatedBy]
           ,[Remarks]
           ,[CompanyID]
           ,[BranchID]
           ,[Deleted]
           ,[Refund]
           ,[TransactionDate]
           ,[Cancelled]
           ,[WaiterID]
           ,[IsPending]
           ,[ProdDiscount]
           ,[CustomerGSTNo]
           ,[BillNo]
           ,[SeriesType]
           ,[TableID]
           ,[TokenNo]
           ,[IsDespatched]
           ,[IsSettled]
           ,[DeliveryDate]
           ,[DeliveryTime]
           ,[DeliveryRemarks]
           ,[IsShiftClosed]
           ,[TabBillNo]
           ,[ChairPositions]
           ,[NoOfChairs]
           ,[RedeemPoints]
           ,[Redeem]
           ,[TabID]
           ,[Pax]
           ,[ShiftNumber]
           ,[CardID]
           ,[CessAmount]
           ,[IsComplementary]
           ,[ComplementaryTotal]
           ,[WaiterRemarks]
           ,[IsSaved]
           ,[IsTakenForUpload]
           ,[EditedAfterUpload]
		   ,[VehicleNo]
		   ,Merged
		   ,OrderType)
     values
	     ( GuID,
          No,
          Date,
          SectionID,
          CounterID,
          BillTime,
          CustomerID,
          Total,
          RTotal,
          Tax,
          Cash,
          Card,
          CardNo,
          FxPaid,
          FxTypeID,
          FxRate,
          FxAmount,
          CustomerCredit,
          Discount,
          DiscountPercentage,
          RoundOff,
          FinancialYearID,
          UserID,
          CreatedBy,
          Remarks,
          CompanyID,
          BranchID,
          Deleted,
          Refund,
          TransactionDate,
          Cancelled,
          WaiterID,
          IsPending,
          ProdDiscount,
          CustomerGSTNo,
          BillNo,
          SeriesType,
          TableID,
          TokenNo,
          IsDespatched,
          IsSettled,
          DeliveryDate,
          DeliveryTime,
          DeliveryRemarks,
          IsShiftClosed,
          TabBillNo,
          ChairPositions,
          NoOfChairs,
          RedeemPoints,
          Redeem,
          TabID,
          Pax,
          ShiftNumber,
          CardID,
          CessAmount,
          IsComplementary,
          ComplementaryTotal,
          WaiterRemarks,
          IsSaved,
          IsTakenForUpload,
          EditedAfterUpload,
		  VehicleNo,
		  Merged,
		  OrderType) ;


	   end

	-------------------SalesTempDetailInsertion--------------------------------------------------


	DELETE R_SalesTempDetail WHERE MasterID in (select MasterID from @saleDetail)

	INSERT INTO [dbo].[R_SalesTempDetail]
           (
           [MasterID]
           ,[ProductID]
           ,[Quantity]
           ,[BaseQuantity]
           ,[UnitRate]
           ,[TaxID]
           ,[TaxPercentage]
           ,[Tax]
           ,[DiscPercentage]
           ,[Discount]
           ,[UnitID]
           ,[ItemTypeID]
           ,[Deleted]
           ,[IsTaxIncludedInPrice]
           ,[Cancelled]
           ,[IsStockUpdated]
           ,[Remarks]
           ,[R_ProductUpdated]
           ,[Merged]
           ,[CessAmount], ChairNo, CourseNo)

          select
           MasterID,
           ProductID,
           Quantity,
           BaseQuantity,
           UnitRate,
           TaxID,
           TaxPercentage,
           Tax,
           DiscPercentage,
           Discount,
           UnitID,
           ItemTypeID,
           Deleted,
           IsTaxIncludedInPrice,
           Cancelled,
           IsStockUpdated,
           Remarks,
           R_ProductUpdated,
           Merged,
           CessAmount, ChairNo, CourseNo from @saleDetail


	-------------SaleTempComboDetailInsertion-----------------------------------



	DELETE R_SalesTempComboDetail WHERE MasterID in(select MasterID from @saleComboDetail)

	INSERT INTO [dbo].[R_SalesTempComboDetail]
           (
          [ProductID]
           ,[Quantity]
           ,[TypeID]
           ,[MasterProductID]

		   ,MasterID)

          select

           ProductID,
           Quantity,
           TypeID,
           MasterProductID

		   ,MasterID from @saleComboDetail

	-------------------SalesTempPaymentDetailInsertion------------------------------------------------------------


	DELETE R_SalesTempPaymentDetail WHERE MasterID in (select MasterID from @salePaymentDetail)

	INSERT INTO [dbo].[R_SalesTempPaymentDetail]
           ([MasterID]
           ,[Type]
           ,[Amount]
           ,[CardNo]
           ,[CardTypeID]
           ,[FxTypeID]
           ,[FxPaid]
           ,[FxRate]
           ,[CustomerID]
           ,[deleted]
           ,[Cancelled])

           select
           MasterID,
           Type,
           Amount,
           CardNo,
           CardTypeID,
           FxTypeID,
           FxPaid,
           FxRate,
           CustomerID,
           deleted,
           Cancelled from @salePaymentDetail

------------------------SalesTempProductModifierDetail Insertion------------------------------------------


	DELETE R_SalesTempProductModifierDetail WHERE MasterID in (select MasterID from @saleProductModifierDetail)

	INSERT INTO [dbo].[R_SalesTempProductModifierDetail]
           ([MasterID]
           ,[ProductID]
           ,[IsVoid]
           ,[Rate]
           ,[Quantity]
           ,[Cancelled]
           ,[Merged]
           ,[ModifierID]
           ,[ParentVoid]
           ,[VoidReason]
           ,[WastedQty])

    select
           MasterID,
           ProductID,
           IsVoid,
           Rate,
           Quantity,
           Cancelled,
           Merged,
           ModifierID,
           ParentVoid,
           VoidReason,
           WastedQty from @saleProductModifierDetail

 ------------------------SalesTempDeliveryDetails Insertion------------------------------------------


 DELETE [R_SalesTempDeliveryDetails] WHERE MasterID in (select MasterID from @saleDeliveryDetail)

 INSERT INTO [dbo].[R_SalesTempDeliveryDetails]
           ([MasterID]
           ,[CustomerID]
           ,[EmployeeID]
           ,[DeliveryDate]
           ,[DeliveryTime]
           ,[DeliveryRemarks])

		select
           MasterID,
           CustomerID,
           EmployeeID,
           DeliveryDate,
           DeliveryTime,
           DeliveryRemarks from @saleDeliveryDetail

-----------------------------------------------------------------

 DELETE [R_SalesDeliveryDetails] WHERE MasterID in(select MasterID from @saleDeliveryDetail)

 INSERT INTO [dbo].[R_SalesDeliveryDetails]
           ([MasterID]
           ,[CustomerID]
           ,[EmployeeID]
           ,[DeliveryDate]
           ,[DeliveryTime]
           ,[DeliveryRemarks])

		select
           MasterID,
           CustomerID,
           EmployeeID,
           DeliveryDate,
           DeliveryTime,
           DeliveryRemarks from @saleDeliveryDetail

 ------------------------SalesTempDelivery Insertion------------------------------------------

 DELETE [R_SalesTempDelivery] WHERE MasterID in (select MasterID from @saleDelivery)

 INSERT INTO [dbo].[R_SalesTempDelivery]
           (
           [IsClosed],
           [MasterID])
     select
		   1,
           MasterID from @saleDelivery

------------------------------------

 DELETE [R_SalesDelivery] WHERE MasterID in (select MasterID from @saleDelivery)

 INSERT INTO [dbo].[R_SalesDelivery]
           (
		   [Guid],
           [MasterID],
           [IsClosed])
    select
		   newid(),
           MasterID,
		   1 from @saleDelivery
GO

PRINT 'Section L complete.';
GO

-- ============================================================
-- SECTION M: R_Settings — IsPriceEnabled default
-- ============================================================
-- Branch-wide setting read by LoungeTABApi (TabSettings.GetGeneralSettingsBoolDefaultTrue)
-- and sent to the tablet app at login. If missing, the Tab app previously sent rate=1 for
-- every sale line (silently wrong prices on every tab sale) since the app defaults to
-- "prices hidden" rather than "prices shown" when this key isn't found. Not a per-tab
-- setting — deliberately branch-wide, so it does NOT belong in R_tabpossettings.
PRINT 'Section M: Ensuring R_Settings.IsPriceEnabled default...';
GO

IF NOT EXISTS (SELECT 1 FROM R_Settings WHERE [Key] = 'IsPriceEnabled')
BEGIN
    INSERT INTO R_Settings ([Key], [Value]) VALUES ('IsPriceEnabled', 'True');
    PRINT 'Added R_Settings.IsPriceEnabled = True.';
END
ELSE
    PRINT 'R_Settings.IsPriceEnabled already exists.';
GO

PRINT 'Section M complete.';
GO

-- ============================================================
-- SECTION N: Backfill R_SalesED / R_SalesTempED.UUserGuid
-- ============================================================
-- UUserGuid was added later (see the ALTER TABLE ADD near the top of this
-- script) and is populated by the app for every new edit-log row going
-- forward, but existing rows from before that column existed were left
-- NULL. Those NULL rows sit in the sales-edit sync queue and are fetched
-- as a single batch by SalesEDSyncHandler/SalesTempEDSyncHandler — one
-- NULL-UUserGuid row throws when the batch is posted upstream, so the
-- entire batch fails every time, on both manual and auto (Windows Task)
-- sync, and never drains. Backfilling UUserGuid from R_User (UUser is the
-- integer R_User.ID recorded at edit time) unblocks the backlog. Safe to
-- re-run: only touches rows still NULL, and does nothing once caught up.
PRINT 'Section N: Backfilling R_SalesED / R_SalesTempED.UUserGuid from R_User...';
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_SalesED') AND name = 'UUserGuid')
BEGIN
    UPDATE SED
    SET SED.UUserGuid = U.GuID
    FROM dbo.R_SalesED SED
    INNER JOIN dbo.R_User U ON U.ID = SED.UUser
    WHERE SED.UUserGuid IS NULL;

    PRINT 'R_SalesED.UUserGuid backfilled for ' + CAST(@@ROWCOUNT AS varchar(20)) + ' row(s).';
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_SalesTempED') AND name = 'UUserGuid')
BEGIN
    UPDATE SED
    SET SED.UUserGuid = U.GuID
    FROM dbo.R_SalesTempED SED
    INNER JOIN dbo.R_User U ON U.ID = SED.UUser
    WHERE SED.UUserGuid IS NULL;

    PRINT 'R_SalesTempED.UUserGuid backfilled for ' + CAST(@@ROWCOUNT AS varchar(20)) + ' row(s).';
END
GO

PRINT 'Section N complete.';
GO

-- ============================================================
-- SECTION O: R_EinvoiceStatus — add BranchID (multi-branch sync support)
-- ============================================================
-- The Windows app is single-branch per install; the central web DB is
-- multi-branch per company. R_EinvoiceStatus sync (upload only, Windows ->
-- central) never carried BranchID, so once merged centrally there was no
-- way to tell which branch a ZATCA status row came from, and BillNo alone
-- is not guaranteed unique across branches. Windows sends its own fixed
-- LocalBranchGUID (same value already used for R_SalesMaster.BranchID);
-- the central UDT/procs are extended to carry it through untouched.
-- restaurant.UDT_R_EinvoiceStatus has dependent procs, so they're dropped
-- before the type is recreated and rebuilt after.
PRINT 'Section O: Adding BranchID to R_EinvoiceStatus sync path...';
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_EinvoiceStatus') AND name = 'BranchID')
BEGIN
    ALTER TABLE dbo.R_EinvoiceStatus ADD BranchID uniqueidentifier NULL;
    PRINT 'Added column BranchID to table dbo.R_EinvoiceStatus.';
END
ELSE
    PRINT 'Column BranchID already exists in table dbo.R_EinvoiceStatus.';
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[Sync_EinvoiceStatus_Insert]') AND type = 'P')
BEGIN
    DROP PROCEDURE [restaurant].[Sync_EinvoiceStatus_Insert];
    PRINT 'Dropped existing SP restaurant.Sync_EinvoiceStatus_Insert (will be recreated).';
END
GO

IF EXISTS (SELECT 1 FROM sys.types WHERE name = 'UDT_R_EinvoiceStatus' AND is_table_type = 1 AND schema_id = SCHEMA_ID('restaurant'))
BEGIN
    DROP TYPE [restaurant].[UDT_R_EinvoiceStatus];
    PRINT 'Dropped existing UDT restaurant.UDT_R_EinvoiceStatus (will be recreated with BranchID).';
END
GO

-- 2026-07-20: ResponseMsg widened from varchar(250) to varchar(MAX), matching
-- R_EinvoiceStatus.ResponseMsg's actual column width (already varchar(MAX)). ZATCA
-- FAILED-status rejection messages routinely exceed 250 characters (e.g. schema
-- validation errors quoting the full XSD violation text), and ADO.NET throws
-- "String or binary data would be truncated" building the TVP the moment a FAILED
-- row with a long ResponseMsg is included in a batch -- confirmed as a live 500
-- Internal Server Error on Sync/UploadEinvoiceStatus, reproduced directly against
-- this exact table type. REPORTED/CLEARED/short NOT REPORTED rows never hit this,
-- which is why it wasn't obvious until a FAILED row landed in the same upload batch.
CREATE TYPE [restaurant].[UDT_R_EinvoiceStatus] AS TABLE(
    [GuID] [varchar](50) NOT NULL,
    [BillNo] [varchar](50) NOT NULL,
    [BillDateTime] [datetime] NOT NULL,
    [xmlFileName] [varchar](250) NULL,
    [ResponseStatus] [varchar](250) NULL,
    [ResponseMsg] [varchar](max) NULL,
    [InvoiceType] [varchar](50) NULL,
    [InvoiceHash] [varchar](250) NULL,
    [ReSubmitStatus] [varchar](50) NULL,
    [Version] [bigint] NULL,
    [BranchID] [uniqueidentifier] NULL
);
GO
PRINT 'Created UDT restaurant.UDT_R_EinvoiceStatus with BranchID.';
GO

-- 2026-07-14: target.Version is no longer written explicitly (was `target.Version=source.Version`
-- in UPDATE, and `Version`/`source.Version` in the INSERT column/VALUES lists). This proc runs
-- on the receiving side (the central DB's own R_EinvoiceStatus), and Section U converts
-- R_EinvoiceStatus.Version to a native rowversion wherever this script runs -- SQL Server
-- rejects any explicit write to a rowversion column ("Cannot insert an explicit value into a
-- timestamp column"). The incoming source.Version (the sending DB's own watermark value) is
-- simply not meaningful on the receiving side anyway; every other working Insert proc in this
-- script (Sync_Sales_Insert, Sync_SalesTemp_Insert, etc.) already omits Version the same way,
-- letting each DB auto-assign its own rowversion on insert/update.
-- 2026-07-20: SET NOCOUNT ON removed. SaleDataAccess.cs's UploadEinvoiceStatus checks success as
-- `ExecuteNonQueryAsync(cmd) > 0` -- but SET NOCOUNT ON inside a stored proc makes ADO.NET's
-- ExecuteNonQuery return -1 instead of the real affected-row count (it suppresses the TDS
-- row-count messages ADO.NET's count tracking depends on), so `-1 > 0` is always false --
-- every upload was logged as "Failure" locally regardless of whether the MERGE actually
-- succeeded (confirmed: rows landed correctly in R_EinvoiceStatus despite the client reporting
-- failure every time). Sync_Sales_Insert / Sync_SalesTemp_Insert -- both of which work
-- correctly -- were confirmed to never have had SET NOCOUNT ON, which is what makes their
-- `> 0` check meaningful.
CREATE OR ALTER PROCEDURE [restaurant].[Sync_EinvoiceStatus_Insert]
    @UDT_R_EinvoiceStatus [restaurant].[UDT_R_EinvoiceStatus] READONLY
AS
BEGIN
    MERGE dbo.R_EinvoiceStatus AS target
    USING @UDT_R_EinvoiceStatus AS source ON (target.GuID = source.GuID)
    WHEN MATCHED THEN UPDATE SET
        target.BillNo=source.BillNo,target.BillDateTime=source.BillDateTime,target.xmlFileName=source.xmlFileName,
        target.ResponseStatus=source.ResponseStatus,target.ResponseMsg=source.ResponseMsg,
        target.InvoiceType=source.InvoiceType,target.InvoiceHash=source.InvoiceHash,
        target.ReSubmitStatus=source.ReSubmitStatus,
        target.BranchID=ISNULL(source.BranchID, target.BranchID)
    WHEN NOT MATCHED THEN INSERT (GuID,BillNo,BillDateTime,xmlFileName,ResponseStatus,ResponseMsg,InvoiceType,InvoiceHash,ReSubmitStatus,BranchID)
    VALUES (source.GuID,source.BillNo,source.BillDateTime,source.xmlFileName,source.ResponseStatus,source.ResponseMsg,source.InvoiceType,source.InvoiceHash,source.ReSubmitStatus,source.BranchID);
END;
GO
PRINT 'Created or altered SP Sync_EinvoiceStatus_Insert with BranchID.';
GO

CREATE OR ALTER PROCEDURE [restaurant].[Sync_EinvoiceStatus_GetAll]
    @Version BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT GuID,BillNo,BillDateTime,xmlFileName,ResponseStatus,ResponseMsg,InvoiceType,InvoiceHash,ReSubmitStatus,Version,BranchID
    FROM dbo.R_EinvoiceStatus WHERE [Version] > @Version;
END;
GO
PRINT 'Created or altered SP Sync_EinvoiceStatus_GetAll with BranchID.';
GO

PRINT 'Section O complete.';
GO

-- ============================================================
-- SECTION P: Backfill R_EinvoiceStatus.BranchID centrally, and
-- (re)create Report_EinvoiceStatusPaging now that the column exists
-- ============================================================
-- Report_EinvoiceStatusPaging previously had no BranchID column to read,
-- so it derived branch by matching R_SalesMaster/R_SalesTempMaster on
-- BillNo alone (no date qualifier). BillNo is not guaranteed unique across
-- branches (each branch's Windows install numbers its own bills), so that
-- join could silently attribute a row to the wrong branch, and it also
-- depended on the original sale row still existing (Deleted=0). Now that
-- BranchID lives directly on R_EinvoiceStatus (see the ALTER TABLE /
-- Sync_EinvoiceStatus_* changes above), this backfills existing rows using
-- that same BillNo-based heuristic one time (same trust level the report
-- already relied on live), then (re)creates the report proc to read
-- E.BranchID directly. The proc has to be defined here rather than in its
-- original spot earlier in this script: R_EinvoiceStatus already exists by
-- that point (created near the top of this script), so SQL Server checks
-- column names immediately rather than deferring — BranchID must exist on
-- the table before a proc referencing it can be created.
PRINT 'Section P: Backfilling R_EinvoiceStatus.BranchID centrally and (re)creating Report_EinvoiceStatusPaging...';
GO

UPDATE E
SET E.BranchID = COALESCE(SM.BranchID, STM.BranchID)
FROM dbo.R_EinvoiceStatus E
LEFT JOIN dbo.R_SalesMaster SM ON SM.BillNo = E.BillNo AND SM.Deleted = 0
LEFT JOIN dbo.R_SalesTempMaster STM ON STM.BillNo = E.BillNo AND STM.Deleted = 0
WHERE E.BranchID IS NULL
  AND COALESCE(SM.BranchID, STM.BranchID) IS NOT NULL;

PRINT 'R_EinvoiceStatus.BranchID backfilled for ' + CAST(@@ROWCOUNT AS varchar(20)) + ' row(s).';
GO

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
        LEFT JOIN dbo.R_SalesMaster sm ON e.BranchID IS NULL AND e.BillNo=sm.BillNo AND sm.Deleted=0
        LEFT JOIN dbo.R_SalesTempMaster stm ON e.BranchID IS NULL AND e.BillNo=stm.BillNo AND stm.Deleted=0
        LEFT JOIN dbo.R_Branch b ON COALESCE(e.BranchID,sm.BranchID,stm.BranchID)=b.GuID
        WHERE CAST(e.BillDateTime AS DATE) BETWEEN @FromDateOnly AND @ToDateOnly
          AND (@BranchID IS NULL OR COALESCE(e.BranchID,sm.BranchID,stm.BranchID)=@BranchGuid)
    )
    SELECT GuID,BillNo,BillDateTime,xmlFileName,ResponseStatus,ResponseMsg,InvoiceType,InvoiceHash,ReSubmitStatus,Version,BranchName,RowCountVal AS [RowCount]
    FROM FilteredEinvoice
    -- @PageSize=-1 (or any value <=0) is the caller's "no limit, return everything" convention
    -- (e.g. the web report's GetAllLazyPagedData with PageSize:-1). Without this guard,
    -- (@PageNumber-1)*@PageSize+1 .. @PageNumber*@PageSize evaluates to "BETWEEN 1 AND -1" for
    -- PageNumber=1/PageSize=-1 - an impossible range - so every row gets silently filtered out,
    -- independent of BranchID/date and identical for every branch, not just one.
    WHERE (@PageSize <= 0 OR RowNum BETWEEN (@PageNumber-1)*@PageSize+1 AND @PageNumber*@PageSize)
    ORDER BY RowNum;
END;
GO
PRINT 'Created or altered SP Report_EinvoiceStatusPaging.';
GO

PRINT 'Section P complete.';
GO

-- ============================================================
-- SECTION Q: Normalize R_EinvoiceStatus.ResponseStatus vocabulary
-- ============================================================
-- ResponseStatus used to be written as ZATCA's raw API response text
-- verbatim (e.g. "NOT_REPORTED", underscore) alongside the app's own
-- "NOT REPORTED" (space) placeholder written before any submission
-- attempt - two different strings that looked confusingly similar to
-- customers. Worse, both GetPendingInvoices (the resubmit engine) and
-- this report used to stop showing a row once it had ever been touched
-- (via a ReSubmitStatus IS NULL/blank check), which meant a FAILED
-- invoice disappeared from both the report and the auto-resubmit queue
-- forever after one failed attempt - not just a labeling problem, an
-- invoice could get silently stranded.
-- The app now writes ResponseStatus using a fixed vocabulary only:
-- NOT REPORTED / FAILED / REPORTED / CLEARED, with ZATCA's exact raw
-- text preserved in ResponseMsg instead, and both the resubmit engine
-- and this report now key off ResponseStatus directly (NOT IN
-- ('REPORTED','CLEARED') = still needs attention) rather than
-- ReSubmitStatus. This backfills existing rows to the same rules, so
-- anything already stuck under the old scheme becomes visible and
-- resubmittable again immediately, not just going forward.
PRINT 'Section Q: Normalizing R_EinvoiceStatus.ResponseStatus vocabulary...';
GO

UPDATE R_EinvoiceStatus
SET ResponseMsg = CASE
        WHEN ResponseMsg IS NULL OR ResponseMsg = ''
            THEN 'ZATCA status: ' + ResponseStatus
        ELSE 'ZATCA status: ' + ResponseStatus + ' - ' + ResponseMsg
    END,
    ResponseStatus = 'FAILED'
WHERE ResponseStatus IS NOT NULL
  AND ResponseStatus NOT IN ('NOT REPORTED', 'FAILED', 'REPORTED', 'CLEARED');

PRINT 'R_EinvoiceStatus.ResponseStatus normalized for ' + CAST(@@ROWCOUNT AS varchar(20)) + ' row(s).';
GO

UPDATE R_EinvoiceStatus
SET ReSubmitStatus = 'FAILED'
WHERE ReSubmitStatus IS NOT NULL
  AND ReSubmitStatus <> ''
  AND ReSubmitStatus NOT IN ('NOT REPORTED', 'FAILED', 'REPORTED', 'CLEARED');

PRINT 'R_EinvoiceStatus.ReSubmitStatus normalized for ' + CAST(@@ROWCOUNT AS varchar(20)) + ' row(s).';
GO

PRINT 'Section Q complete.';
GO

-- ============================================================
-- SECTION Q: dbo.GetStockValue — exclude soft-deleted rows
-- ============================================================
-- dbo.GetStockValue (used by the P&L Trading Statement's Opening/Closing
-- Stock lines and by the Balance Sheet's GetClosingStock) had no Deleted
-- filter at all on Purchase, Sales, or Stock Transfer, unlike
-- restaurant.Report_StockValuePaging (the Stock Value Report), which
-- correctly filters Deleted=0 on all three. A voided/edited purchase,
-- sale, or transfer still counts toward stock value here, but is
-- correctly excluded from the Stock Value Report, producing a
-- reconciliation gap between the two reports equal to the deleted
-- rows' value (confirmed on mrvibe: 7 voided purchase lines totaling
-- 348.50 exactly explained the gap between P&L Closing Stock and the
-- Stock Value Report for 01/06/2026-30/06/2026). OpeningStockMaster/
-- Detail and PurchaseDetail/Inv_SalesDetail/Inv_StcokTransferDetail have
-- no Deleted column of their own, so only the header-level tables
-- (Purchase, Inv_SalesMaster, Inv_StcokTransferMaster) need the filter —
-- same level Report_StockValuePaging already checks at.
PRINT 'Section Q: Fixing dbo.GetStockValue to exclude soft-deleted rows...';
GO

CREATE OR ALTER FUNCTION [dbo].[GetStockValue] (@OpeningDate datetime,@location varchar(max))
RETURNS money
AS
BEGIN

    DECLARE @Stock money;
	set @Stock=0;
	select @Stock = Isnull(sum(Quantity*UnitPrice),0) from OpeningStockDetail D inner join OpeningStockMaster M on M.GuID=D.MasterID inner join restaurant.Product P on P.GuID=D.ProductID where M.BranchID=@location AND M.Date<@OpeningDate;
	select @Stock = @Stock + Isnull(sum(Quantity*Rate),0) from restaurant.PurchaseDetail D inner join restaurant.Purchase M on M.GuID =D.MasterID inner join restaurant.Product P on P.GuID=D.ProductID where M.EntryDate<@OpeningDate and M.BranchID=@location AND M.TransType != 'PR' AND M.TransType != 'PO' AND M.Deleted=0;
	select @Stock = @Stock - Isnull(sum(Quantity*Rate),0) from restaurant.PurchaseDetail D inner join restaurant.Purchase M on M.GuID =D.MasterID inner join restaurant.Product P on P.GuID=D.ProductID where M.EntryDate<@OpeningDate and M.BranchID=@location AND M.TransType = 'PR' AND M.Deleted=0;
	select @Stock = @Stock - Isnull(sum(QTY*PRICE),0) from restaurant.Inv_SalesDetail D inner join restaurant.Inv_SalesMaster M on M.GuID = D.MasterID inner join restaurant.Product P on P.GuID = D.ProductID where M.INVDATE<@OpeningDate  and M.BranchID=@location AND M.TransType != 'SR' AND M.TransType != 'SQ' AND M.Deleted=0;
	select @Stock = @Stock + Isnull(sum(QTY*PRICE),0) from restaurant.Inv_SalesDetail D inner join restaurant.Inv_SalesMaster M on M.GuID = D.MasterID inner join restaurant.Product P on P.GuID = D.ProductID where M.INVDATE<@OpeningDate  and M.BranchID=@location AND M.TRANSTYPE = 'SR' AND M.Deleted=0;
	select @Stock = @Stock - Isnull(sum(Quantity * isnull(PPD.Cost,0)),0) from restaurant.Inv_StcokTransferMaster M inner join restaurant.Inv_StcokTransferDetail D on D.MasterID = M.GuID  inner join restaurant.Product P on P.GuID = D.ProductID inner join restaurant.ProductPriceDetail PPD on PPD.MasterId = P.GUID where M.Date<@OpeningDate AND D.FromBranch = @location AND M.Deleted=0;
	select @Stock = @Stock + Isnull(sum(Quantity * isnull(PPD.Cost,0)),0) from restaurant.Inv_StcokTransferMaster M inner join restaurant.Inv_StcokTransferDetail D on D.MasterID = M.GuID  inner join restaurant.Product P on P.GuID = D.ProductID inner join restaurant.ProductPriceDetail PPD on PPD.MasterId = P.GUID where M.Date<@OpeningDate AND D.ToBranch = @location AND M.Deleted=0;
	RETURN @Stock ;

END
GO

PRINT 'Section Q complete.';
GO

-- ============================================================
-- SECTION R: restaurant.WebMenu — resync from defaultDB
-- ============================================================
-- Source script: WEBMENU_INSERT.sql. That script wipes and reloads the
-- ENTIRE WebMenu table for a target database from defaultDB (the
-- canonical template database used to seed new client databases), so
-- that any client DB's menu tree can be brought back in line with the
-- reference copy in one shot.
--
-- Two corrections made vs. the original WEBMENU_INSERT.sql when
-- folding it in here:
--   1. Schema fix: the original script qualifies WebMenu as
--      [dbo].[WebMenu] on both the target and defaultDB sides. The
--      table actually lives in the restaurant schema everywhere
--      (verified on brtest, test2new, and defaultDB) — there is no
--      dbo.WebMenu. Both references below use [restaurant].[WebMenu].
--   2. No @TargetDB variable / dynamic SQL: per this file's convention
--      (see note near the top — run this script while already
--      connected to the target database, no USE statement), the
--      target-side WebMenu is referenced directly as
--      [restaurant].[WebMenu] rather than via
--      QUOTENAME(@TargetDB)+'.restaurant.WebMenu' + sp_executesql.
--      The source side (defaultDB) is always the literal database name
--      'defaultDB', since that is the fixed name of the template DB on
--      the server — it is NOT a placeholder to fill in.
--
-- Why there's no standalone "fix these specific WebMenu rows" section
-- here: a set of broken/incomplete active menu links were found and
-- fixed directly on defaultDB (and test2new) rather than via targeted
-- UPDATE statements in this script, since this section always resyncs
-- WebMenu from defaultDB wholesale on every run anyway — a separate
-- per-row UPDATE section would be redundant dead weight the moment this
-- section executes. For reference, the fixes already applied on
-- defaultDB (and test2new) are:
--   - Finance > Supplier Credits (ID=118) and Customer Debits (ID=119):
--     pointed to Urls (/Reports/Credit, /Reports/Customer) with no
--     matching React route, sending users through the app's wildcard
--     route into a redirect chain that lands on /signin (looks like a
--     forced logout, though no session is actually invalidated).
--     Repointed to the existing working Payables/Receivables report
--     Urls (/Reports/Accounts/Payables, /Reports/Accounts/Receivables).
--   - Other Charges Report (ID=70): same symptom; backend
--     (OtherChargesController.cs / Report_OtherChargesReport SP) is
--     fully built, but no frontend page/route was ever written to
--     consume it, so there's nothing to repoint it to — deactivated
--     (IsActive=0) instead. brtest already had it inactive.
--   - Reports > Consolidated Reports > Items (ID=92) and PayMode
--     (ID=93): Url values were missing their leading "/"
--     ("Reports/Consolidated/Item" / "...PayMode"), which React Router
--     treats as a relative path rather than absolute — fixed to
--     "/Reports/Consolidated/Item" and "/Reports/Consolidated/PayMode".
--   - Accounts > Acc Group (ID=96, Url=/Accounts/Group): looked
--     unmatched by any route at first glance, but this page
--     (Pages/Accounting/AddGroup.jsx) is opened from within another
--     page rather than navigated to directly from this menu entry, so
--     it does not need a route of its own — left as-is, no fix needed.
--
-- WARNING — destructive: this DELETEs every row in the target
-- database's restaurant.WebMenu before reinserting defaultDB's rows.
-- Any menu customization specific to the target DB that isn't also in
-- defaultDB will be lost — review before running against any database
-- with known local menu customizations.
--
-- CRITICAL GUARD (added 2026-08-17, after a real incident): this section
-- must NEVER run while connected to defaultDB itself. Since the DELETE
-- and the subsequent INSERT...SELECT FROM [defaultDB].[restaurant].[WebMenu]
-- are separate GO-batches (each commits independently, no shared
-- transaction), running this while connected TO defaultDB deletes
-- defaultDB's own WebMenu rows and then tries to copy them back FROM
-- the very table that was just emptied — netting zero rows. This
-- actually happened: a full-script replay against defaultDB (as part of
-- routine idempotency verification, nothing WebMenu-specific) silently
-- wiped defaultDB.restaurant.WebMenu to 0 rows, and every subsequent
-- replay against any other target DB (testmeat, brtest, dtest1) then
-- propagated that emptiness via this same section, breaking the live
-- menu (WebMenu IDs are referenced by UserWebMenuPermission, so an
-- empty WebMenu means no menu items render for anyone). Recovered by
-- restoring all four from kashkan.restaurant.WebMenu (the one DB never
-- touched by this script, still had the original 128 rows with the
-- correct IDs). Root cause fixed below by skipping this entire section
-- whenever DB_NAME() = 'defaultDB' — defaultDB is the *source* of this
-- sync, never a valid target for it.
PRINT 'Section R: Resyncing restaurant.WebMenu from defaultDB.restaurant.WebMenu...';
GO

IF DB_NAME() = 'defaultDB'
    PRINT 'Section R skipped: connected to defaultDB itself, which is the source of this sync, not a valid target.';
GO

IF DB_NAME() <> 'defaultDB'
BEGIN
    SET IDENTITY_INSERT [restaurant].[WebMenu] ON;
END
GO

IF DB_NAME() <> 'defaultDB'
BEGIN
    DELETE FROM [restaurant].[WebMenu];
END
GO

IF DB_NAME() <> 'defaultDB'
BEGIN
    INSERT INTO [restaurant].[WebMenu]
    (
        ID,
        GuID,
        Name,
        ParentID,
        Url,
        Icon,
        Class,
        IsSubMenu,
        SpanClass,
        btnClass,
        OnClick,
        ControllerName,
        IsActive
    )
    SELECT
        ID,
        GuID,
        Name,
        ParentID,
        Url,
        Icon,
        Class,
        IsSubMenu,
        SpanClass,
        btnClass,
        OnClick,
        ControllerName,
        IsActive
    FROM [defaultDB].[restaurant].[WebMenu];
END
GO

IF DB_NAME() <> 'defaultDB'
BEGIN
    SET IDENTITY_INSERT [restaurant].[WebMenu] OFF;
END
GO

PRINT 'Section R complete.';
GO

-- ============================================================
-- SECTION S: restaurant.Sync_Log_Insert — embedded self-cleanup
-- ============================================================
-- 2026-07-13: Sync_Log grew unbounded (326K+ rows on ArafaArabic_CITY, required a one-time
-- manual cleanup). This adds a probabilistic self-cleanup step (~1 in 500 calls, roughly
-- once/day given typical autosync cadence) directly to the insert proc so it never grows
-- unbounded again, instead of relying on a manual/scheduled cleanup script.
--
-- SAFETY: never deletes the max-version Success row per (EntityType, Direction) -- only
-- older/superseded Success rows for the same entity+direction, and Failure rows older than
-- @FailureRetentionDays (30). Required so Sync_GetTimeStamp's watermark query
-- (MAX(Version) WHERE SyncStatus='Success') never resets to zero and forces a full
-- historical resync of any entity -- including ones a customer hasn't manually downloaded
-- in 60+ days, since that entity's one Success row is always its own max regardless of age.
-- Cleanup runs in its own TRY/CATCH so a transient issue there can never affect the real
-- log write above (which has already committed by that point).
PRINT 'Section S: Sync_Log_Insert embedded self-cleanup...';
GO

CREATE OR ALTER PROCEDURE [restaurant].[Sync_Log_Insert]

	@UDT_Sync_Log  [restaurant].[Sync_Log_UDT]     READONLY
AS
 BEGIN TRY
    BEGIN TRANSACTION
			  MERGE [restaurant].[Sync_Log] AS SL USING
			  (
				SELECT EntityType,[Version],JSONString,SyncTime,SyncStatus,FailureReason,ISNULL(AttemptCount,0)AttemptCount,SyncDirection
				FROM @UDT_Sync_Log
			  )USL ON USL.[Version] = SL.[Version] AND USL.[Version]!=0
			  WHEN MATCHED THEN
			        UPDATE SET
					 SL.EntityType = USL.EntityType
					,SL.[Version] = USL.[Version]
					,SL.JSONString = USL.JSONString
					,SL.SyncTime = USL.SyncTime
					,SL.SyncStatus = USL.SyncStatus
					,SL.FailureReason = USL.FailureReason
					,SL.AttemptCount = USL.AttemptCount
					,SL.Direction = USL.SyncDirection
			  WHEN NOT MATCHED THEN
			  INSERT (
			  EntityType,[Version],JSONString,SyncTime,SyncStatus,FailureReason,AttemptCount,Direction  )
			  VALUES
			  (
			   USL.EntityType,USL.[Version],USL.JSONString,USL.SyncTime,USL.SyncStatus,USL.FailureReason,USL.AttemptCount,USL.SyncDirection
			  );
	 COMMIT TRANSACTION
     END TRY

 BEGIN CATCH
        ROLLBACK TRANSACTION
        RETURN -1
END CATCH

	IF (ABS(CHECKSUM(NEWID())) % 500 = 0)
	BEGIN
		BEGIN TRY
			DECLARE @FailureRetentionDays INT = 30;

			;WITH RankedSuccess AS (
				SELECT GuID,
				       ROW_NUMBER() OVER (
				           PARTITION BY EntityType, Direction
				           ORDER BY CONVERT(BIGINT, Version) DESC, SyncTime DESC
				       ) AS rn
				FROM restaurant.Sync_Log
				WHERE SyncStatus = 'Success'
			)
			DELETE SL
			FROM restaurant.Sync_Log SL
			INNER JOIN RankedSuccess R ON R.GuID = SL.GuID
			WHERE R.rn > 1;

			DELETE FROM restaurant.Sync_Log
			WHERE SyncStatus = 'Failure'
			  AND SyncTime < DATEADD(DAY, -@FailureRetentionDays, GETDATE());
		END TRY
		BEGIN CATCH
			-- Swallow deliberately: routine cleanup must never surface as a sync failure.
		END CATCH
	END

   RETURN 1
GO

PRINT 'Section S complete.';
GO

-- ============================================================
-- SECTION T: Sync perf -- Version/MasterID indexes + server-side filtering
-- for Sync_SalesTemp_GetAll / Sync_DayClose_GetAll
-- ============================================================
-- 2026-07-14: these sync GetAll procs do `WHERE Version > @Version` on
-- R_SalesTempMaster/R_DailyClosingMaster with no supporting index, forcing a full
-- clustered-index scan every autosync cycle -- risk of SQL Server escalating to a
-- full table lock (past ~5000 locks in one statement) and blocking a concurrent
-- bill save (WinApp/tablet) on the same tables. Only R_SalesTempMaster/Detail/ED and
-- R_DailyClosingMaster/Detail are indexed here -- confirmed via real row counts that
-- the live R_SalesMaster/R_SalesDetail/R_SalesED tables stay tiny (cleared daily by
-- day-close transfer), so indexing them has no benefit.
--
-- On top of that, Sync_SalesTemp_GetAll's 6 detail-table SELECTs and
-- Sync_DayClose_GetAll's R_DailyClosingDetail SELECT had NO WHERE clause at all
-- (DayClose's was present but commented out) -- an unconditional full-table read
-- every cycle, with the C# client (SalesTempSyncHandler/DailyCloseSyncHandler)
-- doing the real MasterID-based filtering itself after the fact. This section pushes
-- that same filter into the query so SQL Server only returns the rows the client
-- actually keeps.
--
-- Version is a rowversion/timestamp column; comparing it directly to a BIGINT
-- parameter forces an implicit conversion of the COLUMN (BIGINT outranks
-- timestamp), which is non-sargable and defeats the new index. Fixed via
-- CAST(@Version AS BINARY(8)) on the parameter side instead -- verified empirically
-- (symmetric-difference / EXCEPT comparison both ways, zero-row diff) against the
-- old `WHERE Version > @Version` behavior on ArafaArabic_CITY before rollout, at a
-- real mid-range watermark and at v=0/v=max/v=max-1 edge cases.
--
-- Scope: only Sync_SalesTemp_GetAll / Sync_DayClose_GetAll change. Confirmed (via
-- grep) these procs are referenced only by SalesTempSyncHandler.cs /
-- DailyCloseSyncHandler.cs -- NOT by usp_TransferDataToTempTable or any day-close /
-- bill-save write path, so normal business operations are unaffected.
PRINT 'Section T: sync perf indexes + Sync_SalesTemp_GetAll / Sync_DayClose_GetAll rewrite...';
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_R_SalesTempMaster_Version' AND object_id = OBJECT_ID('dbo.R_SalesTempMaster'))
    CREATE NONCLUSTERED INDEX IX_R_SalesTempMaster_Version ON dbo.R_SalesTempMaster(Version);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_R_SalesTempDetail_Version' AND object_id = OBJECT_ID('dbo.R_SalesTempDetail'))
    CREATE NONCLUSTERED INDEX IX_R_SalesTempDetail_Version ON dbo.R_SalesTempDetail(Version);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_R_SalesTempED_Version' AND object_id = OBJECT_ID('dbo.R_SalesTempED'))
    CREATE NONCLUSTERED INDEX IX_R_SalesTempED_Version ON dbo.R_SalesTempED(Version);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_R_DailyClosingMaster_Version' AND object_id = OBJECT_ID('dbo.R_DailyClosingMaster'))
    CREATE NONCLUSTERED INDEX IX_R_DailyClosingMaster_Version ON dbo.R_DailyClosingMaster(Version);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_R_DailyClosingDetail_Version' AND object_id = OBJECT_ID('dbo.R_DailyClosingDetail'))
    CREATE NONCLUSTERED INDEX IX_R_DailyClosingDetail_Version ON dbo.R_DailyClosingDetail(Version);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_R_SalesTempDetail_MasterID' AND object_id = OBJECT_ID('dbo.R_SalesTempDetail'))
    CREATE NONCLUSTERED INDEX IX_R_SalesTempDetail_MasterID ON dbo.R_SalesTempDetail(MasterID);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_R_SalesTempPaymentDetail_MasterID' AND object_id = OBJECT_ID('dbo.R_SalesTempPaymentDetail'))
    CREATE NONCLUSTERED INDEX IX_R_SalesTempPaymentDetail_MasterID ON dbo.R_SalesTempPaymentDetail(MasterID);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_R_SalesTempProductModifierDetail_MasterID' AND object_id = OBJECT_ID('dbo.R_SalesTempProductModifierDetail'))
    CREATE NONCLUSTERED INDEX IX_R_SalesTempProductModifierDetail_MasterID ON dbo.R_SalesTempProductModifierDetail(MasterID);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_R_SalesTempComboDetail_MasterID' AND object_id = OBJECT_ID('dbo.R_SalesTempComboDetail'))
    CREATE NONCLUSTERED INDEX IX_R_SalesTempComboDetail_MasterID ON dbo.R_SalesTempComboDetail(MasterID);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_R_SalesTempDelivery_MasterID' AND object_id = OBJECT_ID('dbo.R_SalesTempDelivery'))
    CREATE NONCLUSTERED INDEX IX_R_SalesTempDelivery_MasterID ON dbo.R_SalesTempDelivery(MasterID);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_R_MiscellaneousSalesAmount_MasterID' AND object_id = OBJECT_ID('dbo.R_MiscellaneousSalesAmount'))
    CREATE NONCLUSTERED INDEX IX_R_MiscellaneousSalesAmount_MasterID ON dbo.R_MiscellaneousSalesAmount(MasterID);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_R_DailyClosingDetail_MasterID' AND object_id = OBJECT_ID('dbo.R_DailyClosingDetail'))
    CREATE NONCLUSTERED INDEX IX_R_DailyClosingDetail_MasterID ON dbo.R_DailyClosingDetail(MasterID);
GO

-- 2026-07-20: added @BatchSize (default 2000, oldest-pending-first via ORDER BY
-- Version ASC). On a DB with a large never-synced backlog (confirmed on one customer
-- copy: 36,744 pending rows), the unbounded version above fetched the entire pending
-- set in one call -- SalesTempSyncHandler.GetAll() builds a fully-nested C# object
-- graph (Products/Payments/Modifiers/Combos/Misc per row) for every one of those rows
-- before any upload batching ever starts, confirmed via a live OutOfMemoryException in
-- that step. @BatchSize caps how much SQL Server returns and the client ever holds in
-- memory per call; SalesTempSyncHandler.Upload() now loops internally, calling
-- GetAll() repeatedly and advancing its own watermark by each page's MAX(Version)
-- until a page comes back smaller than @BatchSize. External contract (Upload()
-- returns Task<bool>, no new parameters) is unchanged -- confirmed via grep that
-- AutoSyncService.cs, the dormant SaleAutoSyncService.cs, and frmDataSync.cs's manual
-- "Upload" button all call Upload()/Handle() with no arguments, so manual sync gets
-- this fix with zero changes needed on its side. Verified by simulating the exact
-- pagination against the real 36,744-row backlog: watermark advances monotonically,
-- zero gaps, zero duplicates, total rows across all pages matches the original
-- pending count exactly.
CREATE OR ALTER PROCEDURE [restaurant].[Sync_SalesTemp_GetAll]
	@Version BIGINT = NULL,
	@BatchSize INT = 2000
AS

    SET NOCOUNT ON

	DECLARE @ChangedMasterIDs TABLE (GuID UNIQUEIDENTIFIER PRIMARY KEY);
	INSERT INTO @ChangedMasterIDs (GuID)
	SELECT TOP (@BatchSize) GuID FROM [R_SalesTempMaster] WHERE Version > CAST(@Version AS BINARY(8)) ORDER BY Version ASC;

	SELECT  SM.ID,SM.[GuID],[No],[Date],SectionID,CounterID,BillTime,CustomerID,Total,RTotal,Tax,Cash,[Card],[CardNo],
	FxPaid,FxTypeID,FxRate,FxAmount,CustomerCredit,Discount,DiscountPercentage,RoundOff,FinancialYearID,
	UserID,CreatedBy,Remarks,CompanyID,LastUpdate,BranchID,Deleted,Refund,TransactionDate,IsPending,
	Cancelled,WaiterID,ProdDiscount,CustomerGSTNo,BillNo,SeriesType,TableID,CancelReason,
	TokenNo,ISNULL(IsDespatched,0)IsDespatched,ISNULL(IsSettled,0)IsSettled,DeliveryDate,DeliveryTime,DeliveryRemarks,ISNULL(IsShiftClosed,0)IsShiftClosed,ShiftNumber,
	TabID,Merged,Pax,ISNULL(Redeem,0)Redeem,ISNULL(RedeemPoints,0)RedeemPoints,NoOfChairs,ChairPositions,TabBillNo,IsComplementary,ComplementaryTotal,
	CardID,IsprintedFromPay,CessAmount,WaiterRemarks,IsSaved,IsTakenForUpload,EditedAfterUpload,vehicleno,
	convert(BIGINT,Version)[Version],UpdatedUser
	,SD.[GuID] AS DeliveryID, OrderOpenedDateTime, OrderClosedDateTime
	FROM [R_SalesTempMaster] SM
	LEFT OUTER JOIN [R_SalesDelivery] SD ON SM.[GuID] = SD.MasterID
	WHERE SM.[GuID] IN (SELECT GuID FROM @ChangedMasterIDs)
	ORDER BY SM.Version ASC

	SELECT * FROM [R_SalesTempDetail] WHERE MasterID IN (SELECT GuID FROM @ChangedMasterIDs)

	SELECT * FROM [dbo].[R_SalesTempPaymentDetail] WHERE MasterID IN (SELECT GuID FROM @ChangedMasterIDs)

	SELECT * FROM R_SalesTempProductModifierDetail WHERE MasterID IN (SELECT GuID FROM @ChangedMasterIDs)

	SELECT * FROM [R_SalesTempComboDetail] WHERE MasterID IN (SELECT GuID FROM @ChangedMasterIDs)

	SELECT * FROM [R_SalesTempDelivery] WHERE MasterID IN (SELECT GuID FROM @ChangedMasterIDs)

	SELECT * FROM [R_MiscellaneousSalesAmount] WHERE MasterID IN (SELECT GuID FROM @ChangedMasterIDs)
	--SELECT * FROM [R_SalesTempDeliveryDetails]


	SET NOCOUNT OFF
GO

CREATE OR ALTER PROCEDURE [restaurant].[Sync_DayClose_GetAll]
	@Version BIGINT = NULL
AS

    SET NOCOUNT ON

	DECLARE @ChangedMasterIDs TABLE (GuID UNIQUEIDENTIFIER PRIMARY KEY);
	INSERT INTO @ChangedMasterIDs (GuID)
	SELECT GuID FROM [R_DailyClosingMaster] WHERE Version > CAST(@Version AS BINARY(8));

	SELECT ID,[GuID],[Date],SectionID,Quantity,Total,Tax,Discount,NetTotal,BranchID,[Type],RoundOff,ProdDiscount AS ProductDiscount,Cash,[Card],Credit,CreditRepayment,CessAmount,WaiterRemarks
	,convert(BIGINT,[Version])[Version],CreatedUser,CreatedDate,BranchID
	FROM [R_DailyClosingMaster]
	WHERE [GuID] IN (SELECT GuID FROM @ChangedMasterIDs)

	SELECT ID,[GuID],MasterID,SectionID,ProductID,BranchID,Quantity,Rate,Total,TaxPer AS TaxPercentage,Tax,NetTotal,[Type],Discount,DiscPercentage,CessAmount,convert(BIGINT,[Version])[Version]
    FROM [R_DailyClosingDetail]
	WHERE MasterID IN (SELECT GuID FROM @ChangedMasterIDs)
	SET NOCOUNT OFF
GO

PRINT 'Section T complete.';
GO

-- ============================================================
-- SECTION U: R_EinvoiceStatus.Version -- bigint (never populated) -> rowversion
-- ============================================================
-- 2026-07-14: R_EinvoiceStatus.Version has been `bigint NULL` since the table was
-- first created, with no default. The app's insert path (EinvoiceResult.Insert() in
-- RestaurantERP\BusinessClass\EinvoiceResult.cs) never sets it, so every existing row
-- is NULL -- and `WHERE Version > @Version` never matches a NULL, meaning
-- Sync_EinvoiceStatus_GetAll has always returned zero rows. This is why enabling the
-- EinvoiceStatus autosync (Section EinvoiceStatus wiring in AutoSyncService.cs) produces
-- no errors and no Sync_Log entries at all -- it runs, finds nothing, reports success,
-- and silently uploads nothing, every cycle, forever.
--
-- Every one of the other 44 synced tables uses a native rowversion/timestamp column
-- instead of a manually-maintained bigint -- auto-incrementing on every insert/update
-- with zero app-code involvement, which is what actually keeps incremental sync
-- working long-term. A static DEFAULT would only fix the immediate NULL backlog: once
-- new rows also get the same static default value, the watermark would stop matching
-- them the same way it's failing today. So this converts the column to match the
-- schema-wide pattern instead of patching around it.
--
-- Dropping + re-adding as rowversion makes SQL Server assign real ascending values to
-- all existing rows automatically as part of the ALTER -- proper one-time backfill,
-- no manual UPDATE needed. Sync_EinvoiceStatus_GetAll is updated to match the same
-- CAST(@Version AS BINARY(8)) / CONVERT(BIGINT, Version) pattern already applied to
-- Sync_SalesTemp_GetAll / Sync_DayClose_GetAll in Section T, so the client-facing
-- contract (Version comes back as a plain BIGINT) is unchanged.
--
-- CONSEQUENCE (mitigated below): on any DB where this table already has a backlog,
-- the first autosync cycle after this rollout would otherwise fetch the ENTIRE
-- backlog in one GetAll call/upload, since the watermark starts at 0 --
-- EinvoiceStatusSyncHandler.Upload() posts the whole list in a single HTTP call
-- with no batching. To bound this, GetAll also filters to BillDateTime >= @CutoffDate
-- (2026-04-01, the current ZATCA reporting quarter at the time of this change) --
-- older invoices are permanently out of scope for this sync, not just skipped on
-- the first run. A Version-only seed (e.g. pre-marking Sync_Log with a cutoff
-- Version) was considered instead, but rejected: Version is a rowversion assigned
-- in insert/update order, not invoice-date order -- confirmed 2,416 out-of-order
-- cases vs BillDateTime on ArafaArabic_CITY -- so a Version-based cutoff wouldn't
-- reliably map to a date boundary, and a later edit to an old pre-cutoff row would
-- bump its rowversion high enough to resurface it. Filtering directly on
-- BillDateTime has neither problem. On ArafaArabic_CITY this reduced the first-run
-- backlog from 57,722 rows to 10,861. Adjust @CutoffDate for the quarter in effect
-- when this runs on other DBs, if needed.
PRINT 'Section U: R_EinvoiceStatus.Version bigint -> rowversion...';
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_EinvoiceStatus') AND name = 'Version' AND system_type_id <> TYPE_ID('timestamp'))
BEGIN
    ALTER TABLE dbo.R_EinvoiceStatus DROP COLUMN Version;
    ALTER TABLE dbo.R_EinvoiceStatus ADD Version timestamp;
    PRINT 'Converted R_EinvoiceStatus.Version from bigint to rowversion.';
END
ELSE
    PRINT 'R_EinvoiceStatus.Version is already rowversion -- skipped.';
GO

-- 2026-07-20: added @BatchSize (default 2000, oldest-pending-first via ORDER BY
-- Version ASC). EinvoiceStatusSyncHandler had no batching at all on the fetch side --
-- confirmed on one customer copy with a 23,003-row backlog: a single oversized HTTP
-- POST risks exceeding the client's timeout even without OOMing outright, and since
-- ASP.NET doesn't necessarily abort an in-flight server-side transaction just because
-- the client stopped listening, the data can commit successfully while the client
-- still logs "Failure" and never advances its watermark (confirmed: rows landing
-- centrally with a matching BranchID despite Sync_Log showing continuous failures for
-- the same period). EinvoiceStatusSyncHandler.Upload() now loops internally, calling
-- GetAll() repeatedly and advancing its own watermark by each page's MAX(Version)
-- until a page comes back smaller than @BatchSize -- same pattern as
-- Sync_SalesTemp_GetAll in Section T. External contract unchanged; EinvoiceStatus has
-- no manual-sync entry point at all (confirmed via grep of frmDataSync.cs's
-- TransactionEntityType switch), so this only ever runs via AutoSyncService anyway.
-- Verified by simulating the exact pagination against the real 23,003-row backlog:
-- watermark advances monotonically, zero gaps, zero duplicates, total rows across all
-- pages matches the original pending count exactly.
CREATE OR ALTER PROCEDURE [restaurant].[Sync_EinvoiceStatus_GetAll]
    @Version BIGINT = NULL,
    @BatchSize INT = 2000
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CutoffDate DATETIME = '2026-04-01';
    SELECT TOP (@BatchSize) GuID,BillNo,BillDateTime,xmlFileName,ResponseStatus,ResponseMsg,InvoiceType,InvoiceHash,ReSubmitStatus,
    CONVERT(BIGINT,Version) AS Version, BranchID
    FROM dbo.R_EinvoiceStatus
    WHERE Version > CAST(@Version AS BINARY(8))
      AND BillDateTime >= @CutoffDate
    ORDER BY Version ASC;
END;
GO

-- IX_R_EinvoiceStatus_Version now includes BillDateTime: R_EinvoiceStatus is a heap,
-- so the plain Version-only index still needed a RID lookup per row to check the
-- BillDateTime cutoff above, which the optimizer weighed against a full scan every
-- time on this table's current size. Dropped and recreated unconditionally since
-- IF NOT EXISTS would have skipped it wherever the plain version already ran.
DROP INDEX IF EXISTS IX_R_EinvoiceStatus_Version ON dbo.R_EinvoiceStatus;
CREATE NONCLUSTERED INDEX IX_R_EinvoiceStatus_Version ON dbo.R_EinvoiceStatus(Version) INCLUDE (BillDateTime);
GO

PRINT 'Section U complete.';
GO

-- ============================================================
-- Section V - GL Reporting fixes (2026-07-14)
-- ============================================================

-- Fix 1: dbo.VoucherSumDateToDateWithOB
--   WEB DB: reads dbo.voucher (empty) => change to restaurant.Voucher
--   OB join: dbo.Ledger => R_Ledger (web schema)
ALTER FUNCTION [dbo].[VoucherSumDateToDateWithOB](
    @LedgerID  uniqueidentifier,
    @StartDate datetime,
    @EndDate   datetime,
    @isDebit   bit,
    @branchID  uniqueidentifier,
    @userID    int = NULL
)
RETURNS money
AS
BEGIN
    DECLARE @M money;

    SELECT @M = ISNULL(SUM(Amount), 0)
    FROM restaurant.Voucher
    WHERE Date >= @StartDate
      AND Date <= @EndDate
      AND LedgerID = @LedgerID
      AND isDebit  = @isDebit
      AND BranchID = @BranchID;

    SELECT @M = @M + (
        CASE WHEN @IsDebit = 1
             THEN ISNULL(SUM(LBO.Debit),  0)
             ELSE ISNULL(SUM(LBO.Credit), 0)
        END
    )
    FROM  LedgerBranchOpeningDetail  LBO
    INNER JOIN R_Ledger              L   ON L.GuID   = LBO.LedgerID
    INNER JOIN LedgerBranchOpeningMaster LBM ON LBM.GuID  = LBO.MasterID
    WHERE LBO.LedgerID  = @LedgerID
      AND LBM.BranchID  = @BranchID;

    RETURN @M;
END
GO

-- Fix 2: restaurant.GetPandLIncome
--   Formula was Debit-Credit (yields negative for income/sales ledgers).
--   Changed to Credit-Debit so income items return positive values.
CREATE OR ALTER PROCEDURE [restaurant].[GetPandLIncome]
(
    @FromDate        datetime,
    @ToDate          datetime,
    @FinancialYearID int,
    @BranchID        varchar(max),
    @GroupID         int,
    @GroupGuid       uniqueidentifier
)
AS
BEGIN
    select [R_Group].Name as [Group], R_Ledger.Name as Ledger,
        Expense =
            dbo.VoucherSumDateToDateWithOB(R_Ledger.GuID, @FromDate, @ToDate, 'False', @branchID, DEFAULT) -
            dbo.VoucherSumDateToDateWithOB(R_Ledger.GuID, @FromDate, @ToDate, 'True',  @branchID, DEFAULT)
    from R_Ledger, [R_Group]
    where R_Ledger.GroupID = [R_Group].GuID
      and ([R_Group].ID = @GroupID OR R_Group.ParentGroupID = @GroupGuid)
    order by R_Ledger.GuID
END;
GO

PRINT 'Section V complete.';
GO

-- ============================================================
-- Section W - GetLedgerReportDetail SP fix (2026-07-14)
-- ============================================================
-- Bug: A.isDebit used instead of R.isDebit in CASE -> amounts in wrong Debit/Credit column.
--      No R.isDebit <> A.isDebit filter -> N*(N-1) cross-join rows for compound vouchers.
-- Fix: Dual-mode SP:
--   UNFILTERED (LedgerID = all zeros): direct query showing each entry with its OWN ledger name.
--     All ledger entries (CASH, ROUND OFF, SALES, OUTPUT TAX) visible with correct Dr/Cr.
--   FILTERED (specific ledger): self-join showing the primary contra as Particulars (1 row per entry).
-- Data fix companion: UPDATE restaurant.Voucher SET IsPrimary=0 WHERE Type='DC'
--   AND LedgerID IN (OUTPUT_TAX, ROUND_OFF, DISCOUNT_PAID) -- run on each customer DB.
CREATE OR ALTER PROCEDURE [restaurant].[GetLedgerReportDetail]
    (@LedgerID varchar(max) = '00000000-0000-0000-0000-000000000000',
     @FromDate datetime,
     @ToDate datetime,
     @FinancialYearID int,
     @BranchID varchar(max),
     @PageNumber   INT = NULL,
     @PageSize    INT = NULL,
     @SortingColumn   VARCHAR(MAX) = NULL,
     @SortingDirection  VARCHAR(MAX) = NULL)
AS
BEGIN
    DECLARE @OBM Money;
    DECLARE @CBM Money;
    DECLARE @OB decimal(18,2);
    DECLARE @CB decimal(18,2);
    DECLARE @IsDebitOB bit;
    DECLARE @IsDebitCB bit;
    DECLARE @location varchar(max) = @BranchID;
    DECLARE @SQLString nvarchar(max), @PARAMDEF NVARCHAR(MAX);

    SET @OBM = dbo.LedgerOB(@LedgerID, @FromDate, 1, @location, DEFAULT)
             - dbo.LedgerOB(@LedgerID, @FromDate, 0, @location, DEFAULT);
    SET @CBM = dbo.LedgerOB(@LedgerID, @ToDate + 1, 1, @location, DEFAULT)
             - dbo.LedgerOB(@LedgerID, @ToDate + 1, 0, @location, DEFAULT);

    IF @OBM < 0
    BEGIN
        SET @IsDebitOB = 0;
        SET @OBM = ABS(@OBM);
    END
    ELSE
        SET @IsDebitOB = 1;

    IF @CBM < 0
    BEGIN
        SET @IsDebitCB = 0;
        SET @CBM = ABS(@CBM);
    END
    ELSE
        SET @IsDebitCB = 1;

    SET @OB = CONVERT(decimal(18,2), @OBM);
    SET @CB = CONVERT(decimal(18,2), @CBM);

    IF (@LedgerID = '' OR @LedgerID = '00000000-0000-0000-0000-000000000000')
    BEGIN
        -- UNFILTERED: show every ledger entry with its own name as Particulars (no self-join).
        SET @SQLString = N'
        SELECT
            0 AS SLNO,
            V.Date,
            COALESCE(L.Name, S.FullName, C.Name) AS Particulars,
            V.Type,
            V.No,
            Debit  = CASE WHEN V.isDebit = 1 THEN V.Amount ELSE 0 END,
            Credit = CASE WHEN V.isDebit = 0 THEN V.Amount ELSE 0 END,
            V.Narration,
            COALESCE(G.Name,
                CASE WHEN S.GuID IS NOT NULL THEN ''SUNDRY CREDITORS'' ELSE NULL END,
                CASE WHEN C.GuID IS NOT NULL THEN ''SUNDRY DEBTORS''   ELSE NULL END
            ) AS GroupName,
            @OB AS OB,
            @IsDebitOB AS IsDebitOB,
            @CB AS CB,
            @IsDebitCB AS IsDebitCB
        FROM restaurant.Voucher V
        LEFT JOIN R_Ledger         L ON L.GuID = V.LedgerID
        LEFT JOIN R_Group          G ON G.GuID = L.GroupID
        LEFT JOIN restaurant.Supplier S ON S.GuID = V.LedgerID
        LEFT JOIN R_Customer       C ON C.GuID = V.LedgerID
        WHERE V.Date >= @FromDate AND V.Date <= @ToDate';

        IF (@location != '' AND @location != '00000000-0000-0000-0000-000000000000')
            SET @SQLString = @SQLString + ' AND V.BranchID = ''' + @location + '''';

        SET @SQLString = @SQLString + ' ORDER BY V.Date, V.Type, V.No, V.isDebit DESC';
    END
    ELSE
    BEGIN
        -- FILTERED: show the specific ledger''s transactions with primary contra as Particulars.
        SET @SQLString = N'
        SELECT DISTINCT
            0 AS SLNO,
            R.Date,
            A_Led.Name AS Particulars,
            R.Type,
            R.No,
            Debit  = CASE WHEN R.isDebit = 1 THEN R.Amount ELSE 0 END,
            Credit = CASE WHEN R.isDebit = 0 THEN R.Amount ELSE 0 END,
            R.Narration,
            R_Group.Name AS GroupName,
            @OB AS OB,
            @IsDebitOB AS IsDebitOB,
            @CB AS CB,
            @IsDebitCB AS IsDebitCB
        FROM restaurant.Voucher AS R
        INNER JOIN restaurant.Voucher AS A
            ON  R.No              = A.No
            AND R.Type            = A.Type
            AND R.LedgerID       <> A.LedgerID
            AND R.BranchID        = A.BranchID
            AND R.CompanyID       = A.CompanyID
            AND R.FinancialYearID = A.FinancialYearID
            AND R.isDebit        <> A.isDebit
            AND A.isPrimary       = 1
        INNER JOIN R_Ledger AS A_Led ON A_Led.GuID = A.LedgerID
        INNER JOIN R_Group         ON R_Group.GuID = A_Led.GroupID
        WHERE A.Date >= @FromDate AND A.Date <= @ToDate
          AND R.LedgerID = ''' + @LedgerID + '''';

        IF (@location != '' AND @location != '00000000-0000-0000-0000-000000000000')
            SET @SQLString = @SQLString + ' AND R.BranchID = ''' + @location + '''';

        SET @SQLString = @SQLString + N'
        UNION ALL
        SELECT DISTINCT
            0 AS SLNO,
            R.Date,
            SUP.FullName AS Particulars,
            R.Type,
            R.No,
            Debit  = CASE WHEN R.isDebit = 1 THEN R.Amount ELSE 0 END,
            Credit = CASE WHEN R.isDebit = 0 THEN R.Amount ELSE 0 END,
            R.Narration,
            ''SUNDRY CREDITORS'' AS GroupName,
            @OB AS OB,
            @IsDebitOB AS IsDebitOB,
            @CB AS CB,
            @IsDebitCB AS IsDebitCB
        FROM restaurant.Voucher AS R
        INNER JOIN restaurant.Voucher AS A
            ON  R.No              = A.No
            AND R.Type            = A.Type
            AND R.LedgerID       <> A.LedgerID
            AND R.BranchID        = A.BranchID
            AND R.CompanyID       = A.CompanyID
            AND R.FinancialYearID = A.FinancialYearID
            AND R.isDebit        <> A.isDebit
            AND A.isPrimary       = 1
        INNER JOIN restaurant.Supplier SUP ON SUP.GuID = A.LedgerID
        WHERE A.Date >= @FromDate AND A.Date <= @ToDate
          AND R.LedgerID = ''' + @LedgerID + '''';

        IF (@location != '' AND @location != '00000000-0000-0000-0000-000000000000')
            SET @SQLString = @SQLString + ' AND R.BranchID = ''' + @location + '''';

        SET @SQLString = @SQLString + N'
        UNION ALL
        SELECT DISTINCT
            0 AS SLNO,
            R.Date,
            CUST.Name AS Particulars,
            R.Type,
            R.No,
            Debit  = CASE WHEN R.isDebit = 1 THEN R.Amount ELSE 0 END,
            Credit = CASE WHEN R.isDebit = 0 THEN R.Amount ELSE 0 END,
            R.Narration,
            ''SUNDRY DEBTORS'' AS GroupName,
            @OB AS OB,
            @IsDebitOB AS IsDebitOB,
            @CB AS CB,
            @IsDebitCB AS IsDebitCB
        FROM restaurant.Voucher AS R
        INNER JOIN restaurant.Voucher AS A
            ON  R.No              = A.No
            AND R.Type            = A.Type
            AND R.LedgerID       <> A.LedgerID
            AND R.BranchID        = A.BranchID
            AND R.CompanyID       = A.CompanyID
            AND R.FinancialYearID = A.FinancialYearID
            AND R.isDebit        <> A.isDebit
            AND A.isPrimary       = 1
        INNER JOIN R_Customer CUST ON CUST.GuID = A.LedgerID
        WHERE A.Date >= @FromDate AND A.Date <= @ToDate
          AND R.LedgerID = ''' + @LedgerID + '''';

        IF (@location != '' AND @location != '00000000-0000-0000-0000-000000000000')
            SET @SQLString = @SQLString + ' AND R.BranchID = ''' + @location + '''';

        SET @SQLString = @SQLString + ' ORDER BY R.Date, R.Type, R.No';
    END

    SET @PARAMDEF = N'@FromDate Date, @ToDate Date, @OB decimal, @CB decimal, @OBM decimal, @CBM decimal, @IsDebitOB bit, @IsDebitCB bit, @FinancialYearID decimal';

    EXEC sp_executesql
        @SQLString,
        @PARAMDEF,
        @FromDate = @FromDate,
        @ToDate = @ToDate,
        @OB = @OB,
        @CB = @CB,
        @OBM = @OBM,
        @CBM = @CBM,
        @IsDebitCB = @IsDebitCB,
        @IsDebitOB = @IsDebitOB,
        @FinancialYearID = @FinancialYearID;
END;
GO

-- Data fix: run on each customer web DB to correct IsPrimary for already-posted DC vouchers.
-- New vouchers posted after AccVouchersDataAccess.cs rebuild will have correct IsPrimary automatically.
UPDATE restaurant.Voucher
SET IsPrimary = 0
WHERE Type = 'DC'
  AND LedgerID IN (
    '27D8ED43-98A4-424B-8442-A65D164E2A0F',  -- OUTPUT TAX
    '61E26628-7BB8-418C-A17C-9BC4ABF374EA',  -- ROUND OFF
    '2229BF68-92D0-42DB-A4A7-454DB5A8380E'   -- DISCOUNT PAID
  );
GO

PRINT 'Section W complete.';
GO

-- ============================================================
-- Section X - Consumption Report stored procedures (2026-08-01)
-- ============================================================
-- New reports: "Item wise Consumption Report" and "Consumption Report based on
-- Menu Items" (customer spec: Meat Point Grill - New Report.xlsx). Both turn POS
-- sales quantities into raw-material consumption using the existing Product BOQ
-- (recipe) data: restaurant.Inv_ProductBOQMaster/Detail.
--
-- Sales source mirrors restaurant.Report_ItemWiseSalesreportPaging exactly:
-- R_SalesMaster/R_SalesDetail (settled bills) UNION ALL R_SalesTempMaster/
-- R_SalesTempDetail (current bills synced live from the Windows POS app) --
-- both must be included for accurate consumption figures. Joined to
-- restaurant.Product + restaurant.ProductPriceDetail (per-branch Category/Group)
-- the same way, NOT the legacy dbo.R_Product table used by
-- Report_ItemWiseSalesReportSummary (that table is empty in this DB).
--
-- A product can have more than one non-deleted Inv_ProductBOQMaster row (recipe
-- re-saved over time) -- only the most recently dated one per product is used,
-- otherwise item/raw-material rows fan out into duplicates.
--
-- restaurant.Product.UnitID and restaurant.Inv_ProductBOQDetail.UnitId both
-- resolve against dbo.R_Unit (NOT dbo.Unit -- verified empty overlap on this DB).
--
-- @BranchID is effectively required: restaurant.ProductPriceDetail is looked up
-- per-branch (INNER JOIN ... AND PPD.BranchID = @BranchID), same requirement as
-- the existing Report_ItemWiseSalesreportPaging proc.
CREATE OR ALTER PROCEDURE [restaurant].[Report_ItemWiseConsumptionReport]
(
    @BranchID    VARCHAR(MAX) = NULL,
    @SectionID   VARCHAR(MAX) = NULL,
    @CounterID   VARCHAR(MAX) = NULL,
    @ProductID   VARCHAR(MAX) = NULL,
    @CategoryID  VARCHAR(MAX) = NULL,
    @GroupID     VARCHAR(MAX) = NULL,
    @UserID      VARCHAR(MAX) = NULL,
    @FromDate    DATE = NULL,
    @ToDate      DATE = NULL,
    @IsDayClosed INT  = NULL
)
AS
BEGIN
    SET ARITHABORT ON
    SET XACT_ABORT ON
    SET NOCOUNT ON

    DECLARE @R_ToDate DATE = DATEADD(DAY, 1, @ToDate)

    IF OBJECT_ID('tempdb..#ICR_SoldItems') IS NOT NULL DROP TABLE #ICR_SoldItems
    IF OBJECT_ID('tempdb..#ICR_LatestBOQ') IS NOT NULL DROP TABLE #ICR_LatestBOQ

    SELECT ProductID, SUM(Quantity) AS Quantity, SUM(Total) AS Total
    INTO #ICR_SoldItems
    FROM
    (
        SELECT SD.ProductId AS ProductID, SD.Quantity,
               ((SD.UnitRate * SD.Quantity) - SD.Discount) + SD.Tax + SD.CessAmount AS Total
        FROM R_SalesMaster SM
        INNER JOIN R_SalesDetail SD ON SD.MasterID = SM.GuID
        INNER JOIN restaurant.Product PM ON PM.GuID = SD.ProductId
        INNER JOIN restaurant.ProductPriceDetail PPD ON PPD.MasterID = PM.GuID AND PPD.BranchID = @BranchID
        INNER JOIN R_GroupEntry GE ON GE.Guid = PPD.GroupID
        LEFT OUTER JOIN restaurant.Section S ON SM.SectionID = S.GuID
        LEFT OUTER JOIN R_Counter C ON SM.CounterID = C.GuID
        LEFT OUTER JOIN R_User U ON U.GuID = SM.WaiterID
        WHERE SM.Refund = 0 AND SM.Deleted = 0 AND SM.Cancelled = 0
          AND PM.MenuItem = 1
          AND (SD.ProductId = @ProductID OR @ProductID IS NULL)
          AND (S.GuID = @SectionID OR @SectionID IS NULL)
          AND (C.GuID = @CounterID OR @CounterID IS NULL)
          AND (SM.WaiterID = @UserID OR @UserID IS NULL)
          AND (PPD.CategoryID = @CategoryID OR @CategoryID IS NULL)
          AND (GE.Guid = @GroupID OR @GroupID IS NULL)
          AND (SM.TransactionDate >= @FromDate OR @FromDate IS NULL)
          AND (SM.TransactionDate < @R_ToDate OR @ToDate IS NULL)
          AND (SM.BranchID = @BranchID OR @BranchID IS NULL)

        UNION ALL

        SELECT SD.ProductId AS ProductID, SD.Quantity,
               ((SD.UnitRate * SD.Quantity) - SD.Discount) + SD.Tax + SD.CessAmount AS Total
        FROM R_SalesTempMaster SM
        INNER JOIN R_SalesTempDetail SD ON SD.MasterID = SM.GuID
        INNER JOIN restaurant.Product PM ON PM.GuID = SD.ProductId
        INNER JOIN restaurant.ProductPriceDetail PPD ON PPD.MasterID = PM.GuID AND PPD.BranchID = @BranchID
        INNER JOIN R_GroupEntry GE ON GE.Guid = PPD.GroupID
        LEFT OUTER JOIN restaurant.Section S ON SM.SectionID = S.GuID
        LEFT OUTER JOIN R_Counter C ON SM.CounterID = C.GuID
        LEFT OUTER JOIN R_User U ON U.GuID = SM.WaiterID
        WHERE SM.Refund = 0 AND SM.Deleted = 0 AND SM.Cancelled = 0
          AND PM.MenuItem = 1
          AND (SD.ProductId = @ProductID OR @ProductID IS NULL)
          AND (S.GuID = @SectionID OR @SectionID IS NULL)
          AND (C.GuID = @CounterID OR @CounterID IS NULL)
          AND (SM.WaiterID = @UserID OR @UserID IS NULL)
          AND (PPD.CategoryID = @CategoryID OR @CategoryID IS NULL)
          AND (GE.Guid = @GroupID OR @GroupID IS NULL)
          AND (SM.TransactionDate >= @FromDate OR @FromDate IS NULL)
          AND (SM.TransactionDate < @R_ToDate OR @ToDate IS NULL)
          AND (SM.BranchID = @BranchID OR @BranchID IS NULL)
    ) SoldDetail
    GROUP BY ProductID

    SELECT ProductID, GuID AS MasterGuID
    INTO #ICR_LatestBOQ
    FROM
    (
        SELECT ProductID, GuID, ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY BOQdate DESC, ID DESC) AS rn
        FROM restaurant.Inv_ProductBOQMaster
        WHERE Deleted = 0
    ) X
    WHERE rn = 1

    -- Result set 1: item-level sales summary (only menu items with an active BOQ recipe)
    SELECT
        LB.ProductID,
        P.Name AS Product,
        U.Name AS UnitName,
        SI.Quantity,
        CASE WHEN SI.Quantity <> 0 THEN SI.Total / SI.Quantity ELSE 0 END AS Rate,
        SI.Total
    FROM #ICR_SoldItems SI
    INNER JOIN #ICR_LatestBOQ LB ON LB.ProductID = SI.ProductID
    INNER JOIN restaurant.Product P ON P.GuID = SI.ProductID
    LEFT OUTER JOIN dbo.R_Unit U ON U.GuID = P.UnitID
    ORDER BY P.Name

    -- Result set 2: raw-material consumption per finished item (recipe qty x qty sold)
    SELECT
        ROW_NUMBER() OVER (PARTITION BY LB.ProductID ORDER BY RP.Name) AS SlNo,
        LB.ProductID AS FinishedProductID,
        RP.Name AS Product,
        RU.Name AS UnitName,
        (BD.Quantity * SI.Quantity) AS Quantity,
        BD.Cost AS Rate,
        (BD.Quantity * SI.Quantity * BD.Cost) AS Total
    FROM #ICR_SoldItems SI
    INNER JOIN #ICR_LatestBOQ LB ON LB.ProductID = SI.ProductID
    INNER JOIN restaurant.Inv_ProductBOQDetail BD ON BD.MasterID = LB.MasterGuID AND BD.Deleted = 0
    INNER JOIN restaurant.Product RP ON RP.GuID = BD.ProductID
    LEFT OUTER JOIN dbo.R_Unit RU ON RU.GuID = BD.UnitId
    ORDER BY LB.ProductID, RP.Name

    DROP TABLE #ICR_SoldItems
    DROP TABLE #ICR_LatestBOQ
END
GO

-- "Consumption Report based on Menu Items": same recipe x sales computation as
-- Report_ItemWiseConsumptionReport, but flattened -- one row per raw material,
-- summed across every qualifying menu item sold in the period. Because the same
-- raw material can appear in multiple recipes with different Cost snapshots,
-- Rate is derived as Total / Quantity (quantity-weighted average) so the sheet's
-- Quantity x Rate = Total identity still holds.
CREATE OR ALTER PROCEDURE [restaurant].[Report_MenuItemConsumptionReport]
(
    @BranchID    VARCHAR(MAX) = NULL,
    @SectionID   VARCHAR(MAX) = NULL,
    @CounterID   VARCHAR(MAX) = NULL,
    @ProductID   VARCHAR(MAX) = NULL,
    @CategoryID  VARCHAR(MAX) = NULL,
    @GroupID     VARCHAR(MAX) = NULL,
    @UserID      VARCHAR(MAX) = NULL,
    @FromDate    DATE = NULL,
    @ToDate      DATE = NULL,
    @IsDayClosed INT  = NULL
)
AS
BEGIN
    SET ARITHABORT ON
    SET XACT_ABORT ON
    SET NOCOUNT ON

    DECLARE @R_ToDate DATE = DATEADD(DAY, 1, @ToDate)

    IF OBJECT_ID('tempdb..#MCR_SoldItems') IS NOT NULL DROP TABLE #MCR_SoldItems
    IF OBJECT_ID('tempdb..#MCR_LatestBOQ') IS NOT NULL DROP TABLE #MCR_LatestBOQ

    SELECT ProductID, SUM(Quantity) AS Quantity
    INTO #MCR_SoldItems
    FROM
    (
        SELECT SD.ProductId AS ProductID, SD.Quantity
        FROM R_SalesMaster SM
        INNER JOIN R_SalesDetail SD ON SD.MasterID = SM.GuID
        INNER JOIN restaurant.Product PM ON PM.GuID = SD.ProductId
        INNER JOIN restaurant.ProductPriceDetail PPD ON PPD.MasterID = PM.GuID AND PPD.BranchID = @BranchID
        INNER JOIN R_GroupEntry GE ON GE.Guid = PPD.GroupID
        LEFT OUTER JOIN restaurant.Section S ON SM.SectionID = S.GuID
        LEFT OUTER JOIN R_Counter C ON SM.CounterID = C.GuID
        LEFT OUTER JOIN R_User U ON U.GuID = SM.WaiterID
        WHERE SM.Refund = 0 AND SM.Deleted = 0 AND SM.Cancelled = 0
          AND PM.MenuItem = 1
          AND (SD.ProductId = @ProductID OR @ProductID IS NULL)
          AND (S.GuID = @SectionID OR @SectionID IS NULL)
          AND (C.GuID = @CounterID OR @CounterID IS NULL)
          AND (SM.WaiterID = @UserID OR @UserID IS NULL)
          AND (PPD.CategoryID = @CategoryID OR @CategoryID IS NULL)
          AND (GE.Guid = @GroupID OR @GroupID IS NULL)
          AND (SM.TransactionDate >= @FromDate OR @FromDate IS NULL)
          AND (SM.TransactionDate < @R_ToDate OR @ToDate IS NULL)
          AND (SM.BranchID = @BranchID OR @BranchID IS NULL)

        UNION ALL

        SELECT SD.ProductId AS ProductID, SD.Quantity
        FROM R_SalesTempMaster SM
        INNER JOIN R_SalesTempDetail SD ON SD.MasterID = SM.GuID
        INNER JOIN restaurant.Product PM ON PM.GuID = SD.ProductId
        INNER JOIN restaurant.ProductPriceDetail PPD ON PPD.MasterID = PM.GuID AND PPD.BranchID = @BranchID
        INNER JOIN R_GroupEntry GE ON GE.Guid = PPD.GroupID
        LEFT OUTER JOIN restaurant.Section S ON SM.SectionID = S.GuID
        LEFT OUTER JOIN R_Counter C ON SM.CounterID = C.GuID
        LEFT OUTER JOIN R_User U ON U.GuID = SM.WaiterID
        WHERE SM.Refund = 0 AND SM.Deleted = 0 AND SM.Cancelled = 0
          AND PM.MenuItem = 1
          AND (SD.ProductId = @ProductID OR @ProductID IS NULL)
          AND (S.GuID = @SectionID OR @SectionID IS NULL)
          AND (C.GuID = @CounterID OR @CounterID IS NULL)
          AND (SM.WaiterID = @UserID OR @UserID IS NULL)
          AND (PPD.CategoryID = @CategoryID OR @CategoryID IS NULL)
          AND (GE.Guid = @GroupID OR @GroupID IS NULL)
          AND (SM.TransactionDate >= @FromDate OR @FromDate IS NULL)
          AND (SM.TransactionDate < @R_ToDate OR @ToDate IS NULL)
          AND (SM.BranchID = @BranchID OR @BranchID IS NULL)
    ) SoldDetail
    GROUP BY ProductID

    SELECT ProductID, GuID AS MasterGuID
    INTO #MCR_LatestBOQ
    FROM
    (
        SELECT ProductID, GuID, ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY BOQdate DESC, ID DESC) AS rn
        FROM restaurant.Inv_ProductBOQMaster
        WHERE Deleted = 0
    ) X
    WHERE rn = 1

    ;WITH RawMaterialConsumption AS
    (
        SELECT
            BD.ProductID AS RawMaterialProductID,
            SUM(BD.Quantity * SI.Quantity) AS Quantity,
            SUM(BD.Quantity * SI.Quantity * BD.Cost) AS Total
        FROM #MCR_SoldItems SI
        INNER JOIN #MCR_LatestBOQ LB ON LB.ProductID = SI.ProductID
        INNER JOIN restaurant.Inv_ProductBOQDetail BD ON BD.MasterID = LB.MasterGuID AND BD.Deleted = 0
        GROUP BY BD.ProductID
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY RP.Name) AS SlNo,
        RP.Name AS Product,
        RU.Name AS UnitName,
        RMC.Quantity,
        CASE WHEN RMC.Quantity <> 0 THEN RMC.Total / RMC.Quantity ELSE 0 END AS Rate,
        RMC.Total
    FROM RawMaterialConsumption RMC
    INNER JOIN restaurant.Product RP ON RP.GuID = RMC.RawMaterialProductID
    LEFT OUTER JOIN dbo.R_Unit RU ON RU.GuID = RP.UnitID
    ORDER BY RP.Name

    DROP TABLE #MCR_SoldItems
    DROP TABLE #MCR_LatestBOQ
END
GO

PRINT 'Section X complete.';
GO

-- ============================================================
-- Section Y - WebMenu entries for Consumption Report (2026-08-08)
-- ============================================================
-- Registers the Consumption Report screen (Section X's stored
-- procedures / LoungeWebAPI's MenuItemConsumptionReport controller
-- route) in restaurant.WebMenu so it appears in the Reports menu.
-- Follows the existing Wastage Detail/Wastage Summary placement
-- pattern: sits under POS SUMMARY (ParentID=7, IsSubMenu=1). ID is
-- IDENTITY -- keyed by GuID for idempotency, same convention as
-- Section A2's seed data.
--
-- Correction (2026-08-18): this section originally also inserted a
-- SECOND, separate top-level entry "Item Wise Consumption Report"
-- (GuID ...5A01, directly under REPORTS) alongside "Consumption
-- Report" (GuID ...5A02, under POS SUMMARY). User feedback: these are
-- redundant -- Consumption Report already covers it, and the
-- top-level duplicate was confusing (kept reappearing at the bottom
-- of the menu). Removed the insert for ...5A01 below and replaced it
-- with an idempotent DELETE, so any database that already has it
-- (from an earlier run of the old version of this section) gets it
-- cleaned up too, not just newly-provisioned databases. defaultDB no
-- longer has this row, so Section R/Z's resync-from-defaultDB already
-- keeps every other database in line -- this DELETE only matters for
-- catching a database that runs this full script directly without
-- going through Section R first.
PRINT 'Section Y: WebMenu entries for Consumption Report...';
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[WebMenu]') AND type = 'U')
BEGIN
    -- ParentID is a self-referencing IDENTITY value, not stable across databases
    -- (each DB's WebMenu rows were seeded/edited independently over time) -- look
    -- the parents up by name rather than hardcoding the IDs seen on defaultDB.
    DECLARE @ReportsMenuID INT = (SELECT TOP 1 ID FROM restaurant.WebMenu WHERE Name = 'REPORTS' AND ParentID = 0);
    DECLARE @PosSummaryMenuID INT = (SELECT TOP 1 ID FROM restaurant.WebMenu WHERE Name = 'POS SUMMARY' AND ParentID = @ReportsMenuID);

    DELETE FROM restaurant.UserWebMenuPermission WHERE MenuID = (SELECT ID FROM restaurant.WebMenu WHERE GuID = '7F3E9A2C-4B1D-4E6F-9A8B-6C2D3E4F5A01');
    DELETE FROM restaurant.WebMenu WHERE GuID = '7F3E9A2C-4B1D-4E6F-9A8B-6C2D3E4F5A01';

    IF @PosSummaryMenuID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM restaurant.WebMenu WHERE GuID = '7F3E9A2C-4B1D-4E6F-9A8B-6C2D3E4F5A02')
        INSERT INTO restaurant.WebMenu (GuID, Name, ParentID, Url, Icon, Class, IsSubMenu, SpanClass, btnClass, OnClick, ControllerName, IsActive)
        VALUES ('7F3E9A2C-4B1D-4E6F-9A8B-6C2D3E4F5A02', 'Menu Item Consumption Report', @PosSummaryMenuID, '/Reports/MenuItemConsumptionReport/Index', 'PlusCircle', NULL, 1, NULL, NULL, NULL, 'MenuItemConsumptionReport', 1);

    PRINT 'Inserted Consumption Report WebMenu entry successfully (Item Wise Consumption Report duplicate removed if present).';
END
ELSE
BEGIN
    PRINT 'restaurant.WebMenu not found -- skipped Consumption Report menu entries.';
END
GO

PRINT 'Section Y complete.';
GO

-- ============================================================
-- Section Y2 - Fix Consumption Report menu entry + permissions (Kashkan)
-- ============================================================
-- Section Y above registered the row (GuID 7F3E9A2C-4B1D-4E6F-9A8B-6C2D3E4F5A02)
-- as "Menu Item Consumption Report" but never inserted any
-- restaurant.UserWebMenuPermission rows for it -- so despite existing in
-- restaurant.WebMenu (sibling of Sales Item Summary / Wastage Summary under
-- POS SUMMARY, ParentID=7, IsSubMenu=1) it was invisible to every role,
-- since fetchmenuPermissions/fetchspecialpermission filter the tree per role
-- before rendering. Also correcting the name/URL to the confirmed route.
PRINT 'Section Y2: Fixing Consumption Report menu entry + permissions...';
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[WebMenu]') AND type = 'U')
BEGIN
    UPDATE restaurant.WebMenu
    SET Name = 'Consumption Report', Url = '/Reports/ConsumptionReport/Index'
    WHERE GuID = '7F3E9A2C-4B1D-4E6F-9A8B-6C2D3E4F5A02'
      AND (Name <> 'Consumption Report' OR Url <> '/Reports/ConsumptionReport/Index');

    IF @@ROWCOUNT > 0
        PRINT 'Renamed Menu Item Consumption Report -> Consumption Report.';
    ELSE
        PRINT 'Consumption Report menu entry already correctly named (or not found).';
END
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[WebMenu]') AND type = 'U')
   AND EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[UserWebMenuPermission]') AND type = 'U')
BEGIN
    DECLARE @ConsumptionMenuID INT = (SELECT TOP 1 ID FROM restaurant.WebMenu WHERE GuID = '7F3E9A2C-4B1D-4E6F-9A8B-6C2D3E4F5A02');
    DECLARE @SalesItemSummaryID INT = (SELECT TOP 1 ID FROM restaurant.WebMenu WHERE Name = 'Sales Item Summary');

    IF @ConsumptionMenuID IS NOT NULL AND @SalesItemSummaryID IS NOT NULL
    BEGIN
        -- Update any pre-existing rows for this (broken/invisible) menu item so
        -- they actually match Sales Item Summary, not just fill in gaps -- a
        -- stray all-zero placeholder row was found for UserTypeID=1 on at least
        -- one database, which would otherwise leave that role incorrectly
        -- denied despite having full access to the sibling report.
        UPDATE existing
        SET existing.[View] = src.[View], existing.[Add] = src.[Add], existing.[Edit] = src.[Edit], existing.Deletion = src.Deletion
        FROM restaurant.UserWebMenuPermission existing
        JOIN restaurant.UserWebMenuPermission src ON src.MenuID = @SalesItemSummaryID AND src.UserTypeID = existing.UserTypeID
        WHERE existing.MenuID = @ConsumptionMenuID;

        INSERT INTO restaurant.UserWebMenuPermission (GuID, UserTypeID, MenuID, [View], [Add], [Edit], Deletion)
        SELECT NEWID(), src.UserTypeID, @ConsumptionMenuID, src.[View], src.[Add], src.[Edit], src.Deletion
        FROM restaurant.UserWebMenuPermission src
        WHERE src.MenuID = @SalesItemSummaryID
          AND NOT EXISTS (
                SELECT 1 FROM restaurant.UserWebMenuPermission existing
                WHERE existing.MenuID = @ConsumptionMenuID AND existing.UserTypeID = src.UserTypeID
          );

        PRINT 'Inserted ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' new permission row(s) for Consumption Report (existing rows for matching roles were also synced to Sales Item Summary).';
    END
    ELSE
        PRINT 'Skipped Consumption Report permission copy (menu row or Sales Item Summary not found).';
END
GO

PRINT 'Section Y2 complete.';
GO

-- ============================================================
-- Section Z - Generic backfill of missing WebMenu entries from defaultDB (2026-08-08)
-- ============================================================
-- Generic, additive "diff and backfill" for restaurant.WebMenu, so future menu
-- additions to defaultDB (new reports/features) reach every other database the
-- next time this script runs, WITHOUT hand-writing a new IF NOT EXISTS block
-- per feature (see Section Y for that older, one-off pattern -- this supersedes
-- the need for more of those).
--
-- Only ever INSERTs rows missing here (matched by the stable GuID) -- never
-- deletes or updates anything that already exists, so a customer's own
-- customizations (disabled items via IsActive=0, custom entries) are never
-- touched. This is deliberately NOT the old WEBMENU_INSERT.sql behaviour
-- (that one does DELETE + full replace from defaultDB, which would wipe
-- per-customer differences on every run -- not used here on purpose).
--
-- ParentID is a per-database IDENTITY value, not a stable key across DBs, so
-- each source row's parent is resolved by matching the PARENT's GuID against
-- this database's WebMenu, not by copying the raw ParentID number. Two passes:
-- top-level items (ParentID=0) first, then children -- so a brand-new
-- top-level category and its children can both backfill in the same run.
--
-- Requires defaultDB to be reachable from the same SQL Server instance as the
-- target database (cross-database query) -- same assumption the legacy
-- WEBMENU_INSERT.sql script made. Skips cleanly if that's not the case, if
-- this IS defaultDB, or if restaurant.WebMenu doesn't exist here.
PRINT 'Section Z: Backfilling missing WebMenu entries from defaultDB...';
GO

IF DB_NAME() <> 'defaultDB'
   AND EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[WebMenu]') AND type = 'U')
   AND EXISTS (SELECT 1 FROM sys.databases WHERE name = 'defaultDB')
BEGIN
    DECLARE @TopLevelAdded INT, @ChildrenAdded INT;

    -- Pass 1: top-level categories (ParentID = 0 on defaultDB) missing here.
    INSERT INTO restaurant.WebMenu (GuID, Name, ParentID, Url, Icon, Class, IsSubMenu, SpanClass, btnClass, OnClick, ControllerName, IsActive)
    SELECT Src.GuID, Src.Name, 0, Src.Url, Src.Icon, Src.Class, Src.IsSubMenu, Src.SpanClass, Src.btnClass, Src.OnClick, Src.ControllerName, Src.IsActive
    FROM defaultDB.restaurant.WebMenu Src
    WHERE Src.ParentID = 0
      AND NOT EXISTS (SELECT 1 FROM restaurant.WebMenu Tgt WHERE Tgt.GuID = Src.GuID);
    SET @TopLevelAdded = @@ROWCOUNT;

    -- Pass 2: everything else, resolving ParentID by the parent's GuID (now
    -- includes any brand-new top-level parent Pass 1 just added). A row whose
    -- parent can't be resolved locally (parent also missing and itself has a
    -- missing parent, 3+ levels deep) is skipped rather than inserted with a
    -- guessed/invalid ParentID -- rare in practice given this menu is at most
    -- 3 levels deep, but safer than corrupting the tree.
    INSERT INTO restaurant.WebMenu (GuID, Name, ParentID, Url, Icon, Class, IsSubMenu, SpanClass, btnClass, OnClick, ControllerName, IsActive)
    SELECT Src.GuID, Src.Name, LocalParent.ID, Src.Url, Src.Icon, Src.Class, Src.IsSubMenu, Src.SpanClass, Src.btnClass, Src.OnClick, Src.ControllerName, Src.IsActive
    FROM defaultDB.restaurant.WebMenu Src
    INNER JOIN defaultDB.restaurant.WebMenu SrcParent ON SrcParent.ID = Src.ParentID
    INNER JOIN restaurant.WebMenu LocalParent ON LocalParent.GuID = SrcParent.GuID
    WHERE Src.ParentID <> 0
      AND NOT EXISTS (SELECT 1 FROM restaurant.WebMenu Tgt WHERE Tgt.GuID = Src.GuID);
    SET @ChildrenAdded = @@ROWCOUNT;

    PRINT CONVERT(VARCHAR(10), @TopLevelAdded) + ' top-level and ' + CONVERT(VARCHAR(10), @ChildrenAdded) + ' child WebMenu entries backfilled from defaultDB.';
END
ELSE
BEGIN
    PRINT 'Skipped WebMenu backfill (this is defaultDB, restaurant.WebMenu is missing here, or defaultDB is unreachable from this server).';
END
GO

PRINT 'Section Z complete.';
GO

-- ============================================================
-- Section AA - Kashkan fix: ComplimentaryReason missing from sync
-- pipeline (Web/cloud DB never received it after upload, even
-- though it saved fine locally). CancelReason already flowed
-- through every hop of this pipeline; ComplimentaryReason never
-- did. Fixes: restaurant.Sale table type, the local source procs
-- (Sync_Sales_GetAll, Sync_SalesTemp_GetAll), and the cloud-side
-- consumers (Sync_Sales_Insert, Sync_SalesTemp_Insert). Also
-- recreates sale_temp_insert unchanged, since it references the
-- same UDT and must be dropped/recreated alongside it.
--
-- Addendum (Kashkan Phase 5, Order Timing): reused this same
-- drop-UDT-recreate-UDT-recreate-procs cycle to also add
-- OrderOpenedDateTime/OrderClosedDateTime to restaurant.Sale, and to
-- Sync_Sales_GetAll/Sync_SalesTemp_GetAll (SELECT) and
-- Sync_Sales_Insert/Sync_SalesTemp_Insert (MERGE UPDATE/INSERT), so
-- these two new columns flow through the local-to-cloud sync pipeline
-- the same way ComplimentaryReason does. sale_temp_insert still did
-- not need any body changes (same reasoning as above - it's dropped
-- and recreated verbatim only because it also references the UDT).
-- ============================================================
-- ============================================================
-- Kashkan feedback fix: Complimentary Reason not present in Web/cloud DB
-- after sync upload. Root cause: ComplimentaryReason was never added to
-- the restaurant.Sale table type (the TVP the WinForms sync pipeline
-- uses to upload sales), the local Sync_Sales_GetAll source proc, the
-- Sale domain model, or the cloud-side Sync_Sales_Insert/Sync_SalesTemp_Insert
-- procs that consume the TVP. Every one of these already carries
-- CancelReason (which is why Cancel sync works) but was never extended
-- to ComplimentaryReason when that feature was added.
-- ============================================================
PRINT 'Kashkan fix: extending sync pipeline for ComplimentaryReason...';
GO

-- ---- Step 1: drop procs that reference restaurant.Sale as a TVP param,
-- required before the type itself can be dropped/recreated.
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[Sync_Sales_Insert]') AND type = 'P')
    DROP PROCEDURE [restaurant].[Sync_Sales_Insert];
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[Sync_SalesTemp_Insert]') AND type = 'P')
    DROP PROCEDURE [restaurant].[Sync_SalesTemp_Insert];
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[restaurant].[sale_temp_insert]') AND type = 'P')
    DROP PROCEDURE [restaurant].[sale_temp_insert];
GO

-- ---- Step 2: recreate restaurant.Sale UDT with the new column added
-- (right after CancelReason, matching the R_SalesMaster column placement).
IF EXISTS (SELECT 1 FROM sys.table_types WHERE name = 'Sale' AND schema_id = SCHEMA_ID('restaurant'))
    DROP TYPE [restaurant].[Sale];
GO

IF SCHEMA_ID('restaurant') IS NOT NULL
BEGIN
    EXEC('CREATE TYPE [restaurant].[Sale] AS TABLE (
      [GuID] uniqueidentifier NOT NULL,
      [No] int NOT NULL,
      [Date] datetime NOT NULL,
      [SectionID] uniqueidentifier NOT NULL,
      [CounterID] uniqueidentifier NOT NULL,
      [BillTime] datetime NOT NULL,
      [CustomerID] uniqueidentifier NULL,
      [Total] decimal(18,8) NOT NULL,
      [RTotal] decimal(18,8) NOT NULL,
      [Tax] decimal(18,8) NOT NULL,
      [Cash] decimal(18,8) NULL,
      [Card] decimal(18,8) NULL,
      [CardNo] varchar(50) NULL,
      [FxPaid] decimal(18,8) NULL,
      [FxTypeID] uniqueidentifier NULL,
      [FxRate] decimal(18,2) NULL,
      [FxAmount] decimal(18,8) NULL,
      [CustomerCredit] decimal(18,8) NOT NULL,
      [Discount] decimal(18,2) NULL,
      [DiscountPercentage] decimal(18,2) NULL,
      [RoundOff] decimal(18,8) NULL,
      [FinancialYearID] int NOT NULL,
      [UserID] int NOT NULL,
      [CreatedBy] uniqueidentifier NOT NULL,
      [Remarks] varchar(250) NULL,
      [CompanyID] int NOT NULL,
      [LastUpdate] datetime NOT NULL,
      [BranchID] uniqueidentifier NULL,
      [Deleted] bit NULL,
      [Refund] bit NULL,
      [TransactionDate] datetime NULL,
      [Cancelled] bit NULL,
      [WaiterID] uniqueidentifier NULL,
      [IsPending] bit NULL,
      [ProdDiscount] decimal(18,8) NULL,
      [CustomerGSTNo] varchar(50) NULL,
      [BillNo] varchar(50) NULL,
      [SeriesType] int NULL,
      [TableID] uniqueidentifier NULL,
      [CancelReason] varchar(250) NULL,
      [ComplimentaryReason] varchar(250) NULL,
      [TokenNo] int NULL,
      [IsDespatched] bit NULL,
      [IsSettled] bit NULL,
      [DeliveryDate] datetime NULL,
      [DeliveryTime] datetime NULL,
      [DeliveryRemarks] varchar(50) NULL,
      [IsShiftClosed] bit NULL,
      [Merged] bit NULL,
      [TabBillNo] varchar(50) NULL,
      [ChairPositions] varchar(50) NULL,
      [NoOfChairs] int NULL,
      [RedeemPoints] int NULL,
      [Redeem] decimal(18,2) NULL,
      [TabID] varchar(100) NULL,
      [Pax] int NULL,
      [ShiftNumber] int NULL,
      [CardID] varchar(100) NULL,
      [CessAmount] decimal(18,2) NOT NULL,
      [IsComplementary] bit NULL,
      [ComplementaryTotal] decimal(18,8) NULL,
      [IsprintedFromPay] bit NULL,
      [WaiterRemarks] nvarchar(100) NULL,
      [IsSaved] bit NOT NULL,
      [IsTakenForUpload] bit NULL,
      [EditedAfterUpload] bit NULL,
      [VehicleNo] varchar(100) NULL,
      [UpdatedUser] uniqueidentifier NULL,
      [OrderType] varchar(20) NULL,
      [OrderOpenedDateTime] datetime NULL,
      [OrderClosedDateTime] datetime NULL
    )');
    PRINT 'Recreated restaurant.Sale table type with ComplimentaryReason column.';
END
GO

PRINT 'Step 2 complete.';
GO
CREATE PROCEDURE [restaurant].[Sync_Sales_Insert]

	@sale Restaurant.Sale READONLY,
	@saleDetail Restaurant.SaleDetail READONLY,
	@saleComboDetail Restaurant.SaleComboDetail READONLY,
	@saleDelivery Restaurant.SaleDelivery READONLY,
	--@saleDeliveryDetail Restaurant.SaleDeliveryDetail READONLY,
	@saleProductModifierDetail Restaurant.SaleProductModifierDetail READONLY,
	@salePaymentDetail Restaurant.SalePaymentDetail READONLY,
	@miscellaneousSalesAmount Restaurant.MiscellaneousSalesAmount READONLY
AS

 BEGIN TRY
    BEGIN TRANSACTION

    MERGE dbo.[R_SalesMaster] AS trg
    USING @sale AS s
      ON s.[Guid] = trg.Guid AND s.BranchID = trg.BranchID
     WHEN MATCHED THEN
       update  set
	   [GuID] = s.[GuID],
       [No] = s.[No],
       [Date] = s.[Date],
       SectionID = s.SectionID,
       CounterID = s.CounterID,
       BillTime =s.BillTime,
       CustomerID = s.CustomerID,
       Total = s.Total,
       RTotal = s.RTotal,
       Tax = s.Tax,
       Cash = s.Cash,
       [Card] = s.[Card],
       CardNo = s.CardNo,
       FxPaid = s.FxPaid,
       FxTypeID = s.FxTypeID,
       FxRate = s.FxRate,
       FxAmount = s.FxAmount,
       CustomerCredit = s.CustomerCredit,
       Discount = s.Discount,
	   DiscountPercentage = s.DiscountPercentage,
	   RoundOff = s.RoundOff,
       FinancialYearID = s.FinancialYearID,
       UserID = s.UserID,
       CreatedBy = s.CreatedBy,
       Remarks = s.Remarks,
       CompanyID = s.CompanyID,
       BranchID = s.BranchID,
       Deleted = s.Deleted,
       Refund = s.Refund,
       TransactionDate = s.TransactionDate,
       Cancelled = s.Cancelled,
       WaiterID = s.WaiterID,
       IsPending = s.IsPending,
       ProdDiscount = s.ProdDiscount,
       CustomerGSTNo = s.CustomerGSTNo,
       BillNo = s.BillNo,
       SeriesType = s.SeriesType,
       TableID =s. TableID,
       TokenNo = s.TokenNo,
       IsDespatched = s.IsDespatched,
       IsSettled = s.IsSettled,
       DeliveryDate = s.DeliveryDate,
       DeliveryTime = s.DeliveryTime,
       DeliveryRemarks =s. DeliveryRemarks,
       IsShiftClosed = s.IsShiftClosed,
       TabBillNo = s.TabBillNo,
       ChairPositions = s.ChairPositions,
       NoOfChairs = s.NoOfChairs,
       RedeemPoints =s. RedeemPoints,
       Redeem = s.Redeem,
       TabID = s.TabID,
       Pax = s.Pax,
       ShiftNumber = s.ShiftNumber,
       CardID = s.CardID,
       CessAmount = s.CessAmount,
       IsComplementary = s.IsComplementary,
       ComplementaryTotal = s.ComplementaryTotal,
       WaiterRemarks = s.WaiterRemarks,
       IsSaved = s.IsSaved,
       IsTakenForUpload = s.IsTakenForUpload,
       EditedAfterUpload = s.EditedAfterUpload,
	   VehicleNo = s.VehicleNo,
	   Merged = s.Merged,
	   LastUpdate = s.LastUpdate,
	   CancelReason = s.CancelReason,
	   ComplimentaryReason = s.ComplimentaryReason,
	   IsPrintedFromPay = s.IsPrintedFromPay,
	   UpdatedUser = s.UpdatedUser,
		OrderType= s.OrderType,
		OrderOpenedDateTime = s.OrderOpenedDateTime,
		OrderClosedDateTime = s.OrderClosedDateTime
     WHEN NOT MATCHED BY TARGET THEN
      INSERT
	(
			[GuID],
            [No]
           ,[Date]
           ,[SectionID]
           ,[CounterID]
           ,[BillTime]
           ,[CustomerID]
           ,[Total]
           ,[RTotal]
           ,[Tax]
           ,[Cash]
           ,[Card]
           ,[CardNo]
           ,[FxPaid]
           ,[FxTypeID]
           ,[FxRate]
           ,[FxAmount]
           ,[CustomerCredit]
           ,[Discount]
           ,[DiscountPercentage]
           ,[RoundOff]
           ,[FinancialYearID]
           ,[UserID]
           ,[CreatedBy]
           ,[Remarks]
           ,[CompanyID]
           ,[BranchID]
           ,[Deleted]
           ,[Refund]
           ,[TransactionDate]
           ,[Cancelled]
           ,[WaiterID]
           ,[IsPending]
           ,[ProdDiscount]
           ,[CustomerGSTNo]
           ,[BillNo]
           ,[SeriesType]
           ,[TableID]
           ,[TokenNo]
           ,[IsDespatched]
           ,[IsSettled]
           ,[DeliveryDate]
           ,[DeliveryTime]
           ,[DeliveryRemarks]
           ,[IsShiftClosed]
           ,[TabBillNo]
           ,[ChairPositions]
           ,[NoOfChairs]
           ,[RedeemPoints]
           ,[Redeem]
           ,[TabID]
           ,[Pax]
           ,[ShiftNumber]
           ,[CardID]
           ,[CessAmount]
           ,[IsComplementary]
           ,[ComplementaryTotal]
           ,[WaiterRemarks]
           ,[IsSaved]
           ,[IsTakenForUpload]
           ,[EditedAfterUpload]
		   ,[VehicleNo]
		   ,Merged
		   ,LastUpdate
		   ,CancelReason
		   ,ComplimentaryReason
		   ,IsPrintedFromPay
		   ,UpdatedUser,
		   OrderType,OrderOpenedDateTime,OrderClosedDateTime)
     values
	     ( [GuID],
          [No],
          [Date],
          SectionID,
          CounterID,
          BillTime,
          CustomerID,
          Total,
          RTotal,
          Tax,
          Cash,
          [Card],
          CardNo,
          FxPaid,
          FxTypeID,
          FxRate,
          FxAmount,
          CustomerCredit,
          Discount,
          DiscountPercentage,
          RoundOff,
          FinancialYearID,
          UserID,
          CreatedBy,
          Remarks,
          CompanyID,
          BranchID,
          Deleted,
          Refund,
          TransactionDate,
          Cancelled,
          WaiterID,
          IsPending,
          ProdDiscount,
          CustomerGSTNo,
          BillNo,
          SeriesType,
          TableID,
          TokenNo,
          IsDespatched,
          IsSettled,
          DeliveryDate,
          DeliveryTime,
          DeliveryRemarks,
          IsShiftClosed,
          TabBillNo,
          ChairPositions,
          NoOfChairs,
          RedeemPoints,
          Redeem,
          TabID,
          Pax,
          ShiftNumber,
          CardID,
          CessAmount,
          IsComplementary,
          ComplementaryTotal,
          WaiterRemarks,
          IsSaved,
          IsTakenForUpload,
          EditedAfterUpload,
		  VehicleNo,
		  Merged
		  ,LastUpdate
		  ,CancelReason
		  ,ComplimentaryReason
		  ,IsPrintedFromPay
		  ,UpdatedUser,
		  OrderType,OrderOpenedDateTime,OrderClosedDateTime) ;


	-------------------SalesDetailInsertion--------------------------------------------------


	DELETE R_SalesDetail WHERE MasterID in (select MasterID from @saleDetail)

	INSERT INTO [dbo].[R_SalesDetail]
           (
		   [GuID],
           [MasterID]
           ,[ProductID]
           ,[Quantity]
           ,[BaseQuantity]
           ,[UnitRate]
           ,[TaxID]
           ,[TaxPercentage]
           ,[Tax]
           ,[DiscPercentage]
           ,[Discount]
           ,[UnitID]
           ,[ItemTypeID]
           ,[Deleted]
           ,[IsTaxIncludedInPrice]
           ,[Cancelled]
           --,[IsStockUpdated]
           ,[Remarks]
           --,[R_ProductUpdated]
           ,[Merged]
           ,[CessAmount], CourseNo, ChairNo)

          select
		  [GuID],
           MasterID,
           ProductID,
           Quantity,
           BaseQuantity,
           UnitRate,
           TaxID,
           TaxPercentage,
           Tax,
           DiscPercentage,
           Discount,
           UnitID,
           ItemTypeID,
           Deleted,
           IsTaxIncludedInPrice,
           Cancelled,
          -- IsStockUpdated,
           Remarks,
          -- R_ProductUpdated,
           Merged,
           CessAmount, CourseNo, ChairNo from @saleDetail


	-------------SaleComboDetailInsertion-----------------------------------


	DELETE R_SalesComboDetail WHERE MasterID in(select MasterID from @saleComboDetail)

	INSERT INTO [dbo].[R_SalesComboDetail]
           (
		    DetailGuID
           ,[ProductID]
           ,[Quantity]
           ,[TypeID]
           ,[MasterProductID]
		   ,MasterID)

          select
          DetailGuID,
           ProductID,
           Quantity,
           TypeID,
           MasterProductID
		   ,MasterID
		   from @saleComboDetail


----	-------------------SalesPaymentDetailInsertion------------------------------------------------------------


	DELETE R_SalesPaymentDetail WHERE MasterID in (select MasterID from @salePaymentDetail)

	INSERT INTO [dbo].[R_SalesPaymentDetail]
           ([MasterID]
           ,[Type]
           ,[Amount]
           ,[CardNo]
           ,[CardTypeID]
           ,[FxTypeID]
           ,[FxPaid]
           ,[FxRate]
           ,[CustomerID]
           ,[deleted]
           ,[Cancelled])

           select
           MasterID,
           Type,
           Amount,
           CardNo,
           CardTypeID,
           FxTypeID,
           FxPaid,
           FxRate,
           CustomerID,
           deleted,
           Cancelled from @salePaymentDetail

----------------------------SalesProductModifierDetail Insertion------------------------------------------


	DELETE R_SalesProductModifierDetail WHERE MasterID in (select MasterID from @saleProductModifierDetail)

	INSERT INTO [dbo].[R_SalesProductModifierDetail]
           ([MasterID]
           ,[ProductID]
           ,[IsVoid]
           ,[Rate]
           ,[Quantity]
           ,[Cancelled]
           ,[Merged]
           ,[ModifierID]
           ,[ParentVoid]
           ,[VoidReason]
           ,[WastedQty])

    select
           MasterID,
           ProductID,
           IsVoid,
           Rate,
           Quantity,
           Cancelled,
           Merged,
           ModifierID,
           ParentVoid,
           VoidReason,
           WastedQty from @saleProductModifierDetail
-- ------------------------SalesMiscellaneousSalesAmount Insertion------------------------------------------
 DELETE [R_MiscellaneousSalesAmount] WHERE MasterID in (select MasterID from @miscellaneousSalesAmount)
 INSERT INTO [dbo].[R_MiscellaneousSalesAmount]
    ([MasterID]
	 ,[DelveryID]
	 ,[ContainerID]
	 ,[OthrchargeID]
	 ,[DelAmount]
	 ,[ContAmount]
	 ,[OtherAmount]
	 ,[DayCloseStatus]
	 ,[Merged])
  select
       MasterID,
	   DelveryID,
       ContainerID,
	   OthrchargeID,
	   DelAmount,
	   ContAmount,
	   OtherAmount,
	   DayCloseStatus,
	   Merged from @miscellaneousSalesAmount

 ------------------------SalesDeliveryDetails Insertion------------------------------------------


 --DELETE [R_SalesDeliveryDetails] WHERE MasterID in(select MasterID from @saleDeliveryDetail)

 --INSERT INTO [dbo].[R_SalesDeliveryDetails]
 --          ([MasterID]
 --          ,[CustomerID]
 --          ,[EmployeeID]
 --          ,[DeliveryDate]
 --          ,[DeliveryTime]
 --          ,[DeliveryRemarks])

	--	select
 --          MasterID,
 --          CustomerID,
 --          EmployeeID,
 --          DeliveryDate,
 --          DeliveryTime,
 --          DeliveryRemarks from @saleDeliveryDetail

-- ------------------------SalesDelivery Insertion------------------------------------------

 DELETE [R_SalesDelivery] WHERE MasterID in (select MasterID from @saleDelivery)

 INSERT INTO [dbo].[R_SalesDelivery]
           (
		   [Guid],
           [MasterID],
           [IsClosed])
    select
		   newid(),
           MasterID,
		   0 from @saleDelivery


	   		 COMMIT TRANSACTION
     END TRY
   BEGIN CATCH
        ROLLBACK TRANSACTION
        RETURN -1
   END CATCH
 RETURN 1
GO
PRINT 'Recreated restaurant.Sync_Sales_Insert with ComplimentaryReason.';
GO
CREATE PROCEDURE [restaurant].[Sync_SalesTemp_Insert]

	@sale Restaurant.Sale READONLY,
	@saleDetail Restaurant.SaleDetail READONLY,
	@saleComboDetail Restaurant.SaleComboDetail READONLY,
	@saleDelivery Restaurant.SaleDelivery READONLY,
	--@saleDeliveryDetail Restaurant.SaleDeliveryDetail READONLY,
	@saleProductModifierDetail Restaurant.SaleProductModifierDetail READONLY,
	@salePaymentDetail Restaurant.SalePaymentDetail READONLY,
	@miscellaneousSalesAmount Restaurant.MiscellaneousSalesAmount READONLY
AS
DECLARE @TransactionDate DATETIME = (SELECT TOP 1 TransactionDate from @sale order by TransactionDate desc)
DECLARE @BranchID UNIQUEIDENTIFIER = (SELECT TOP 1 BranchID from @sale order by TransactionDate desc)

 BEGIN TRY
    BEGIN TRANSACTION

	MERGE dbo.[R_SalesTempMaster] AS trg
    USING @sale AS s
      ON s.[Guid] = trg.Guid
     WHEN MATCHED THEN
       update  set
	   [GuID] = s.[GuID],
       [No] = s.[No],
       [Date] = s.[Date],
       SectionID = s.SectionID,
       CounterID = s.CounterID,
       BillTime =s.BillTime,
       CustomerID = s.CustomerID,
       Total = s.Total,
       RTotal = s.RTotal,
       Tax = s.Tax,
       Cash = s.Cash,
       [Card] = s.[Card],
       CardNo = s.CardNo,
       FxPaid = s.FxPaid,
       FxTypeID = s.FxTypeID,
       FxRate = s.FxRate,
       FxAmount = s.FxAmount,
       CustomerCredit = s.CustomerCredit,
       Discount = s.Discount,
	   DiscountPercentage = s.DiscountPercentage,
	   RoundOff = s.RoundOff,
       FinancialYearID = s.FinancialYearID,
       UserID = s.UserID,
       CreatedBy = s.CreatedBy,
       Remarks = s.Remarks,
       CompanyID = s.CompanyID,
       BranchID = s.BranchID,
       Deleted = s.Deleted,
       Refund = s.Refund,
       TransactionDate = s.TransactionDate,
       Cancelled = s.Cancelled,
       WaiterID = s.WaiterID,
       IsPending = s.IsPending,
       ProdDiscount = s.ProdDiscount,
       CustomerGSTNo = s.CustomerGSTNo,
       BillNo = s.BillNo,
       SeriesType = s.SeriesType,
       TableID =s. TableID,
       TokenNo = s.TokenNo,
       IsDespatched = s.IsDespatched,
       IsSettled = s.IsSettled,
       DeliveryDate = s.DeliveryDate,
       DeliveryTime = s.DeliveryTime,
       DeliveryRemarks =s. DeliveryRemarks,
       IsShiftClosed = s.IsShiftClosed,
       TabBillNo = s.TabBillNo,
       ChairPositions = s.ChairPositions,
       NoOfChairs = s.NoOfChairs,
       RedeemPoints =s. RedeemPoints,
       Redeem = s.Redeem,
       TabID = s.TabID,
       Pax = s.Pax,
       ShiftNumber = s.ShiftNumber,
       CardID = s.CardID,
       CessAmount = s.CessAmount,
       IsComplementary = s.IsComplementary,
       ComplementaryTotal = s.ComplementaryTotal,
       WaiterRemarks = s.WaiterRemarks,
       IsSaved = s.IsSaved,
       IsTakenForUpload = s.IsTakenForUpload,
       EditedAfterUpload = s.EditedAfterUpload,
	   VehicleNo = s.VehicleNo,
	   Merged = s.Merged,
	   LastUpdate = s.LastUpdate,
	   CancelReason = s.CancelReason,
	   ComplimentaryReason = s.ComplimentaryReason,
	   IsPrintedFromPay = s.IsPrintedFromPay,
	   UpdatedUser = s.UpdatedUser,
	   OrderType = S.OrderType,
	   OrderOpenedDateTime = S.OrderOpenedDateTime,
	   OrderClosedDateTime = S.OrderClosedDateTime
     WHEN NOT MATCHED BY TARGET THEN
      INSERT
	(
			[GuID],
            [No]
           ,[Date]
           ,[SectionID]
           ,[CounterID]
           ,[BillTime]
           ,[CustomerID]
           ,[Total]
           ,[RTotal]
           ,[Tax]
           ,[Cash]
           ,[Card]
           ,[CardNo]
           ,[FxPaid]
           ,[FxTypeID]
           ,[FxRate]
           ,[FxAmount]
           ,[CustomerCredit]
           ,[Discount]
           ,[DiscountPercentage]
           ,[RoundOff]
           ,[FinancialYearID]
           ,[UserID]
           ,[CreatedBy]
           ,[Remarks]
           ,[CompanyID]
           ,[BranchID]
           ,[Deleted]
           ,[Refund]
           ,[TransactionDate]
           ,[Cancelled]
           ,[WaiterID]
           ,[IsPending]
           ,[ProdDiscount]
           ,[CustomerGSTNo]
           ,[BillNo]
           ,[SeriesType]
           ,[TableID]
           ,[TokenNo]
           ,[IsDespatched]
           ,[IsSettled]
           ,[DeliveryDate]
           ,[DeliveryTime]
           ,[DeliveryRemarks]
           ,[IsShiftClosed]
           ,[TabBillNo]
           ,[ChairPositions]
           ,[NoOfChairs]
           ,[RedeemPoints]
           ,[Redeem]
           ,[TabID]
           ,[Pax]
           ,[ShiftNumber]
           ,[CardID]
           ,[CessAmount]
           ,[IsComplementary]
           ,[ComplementaryTotal]
           ,[WaiterRemarks]
           ,[IsSaved]
           ,[IsTakenForUpload]
           ,[EditedAfterUpload]
		   ,[VehicleNo]
		   ,Merged
		   ,LastUpdate
		   ,CancelReason
		   ,ComplimentaryReason
		   ,IsPrintedFromPay
		   ,UpdatedUser,
		   OrderType,OrderOpenedDateTime,OrderClosedDateTime)
     values
	     ( [GuID],
          [No],
          [Date],
          SectionID,
          CounterID,
          BillTime,
          CustomerID,
          Total,
          RTotal,
          Tax,
          Cash,
          [Card],
          CardNo,
          FxPaid,
          FxTypeID,
          FxRate,
          FxAmount,
          CustomerCredit,
          Discount,
          DiscountPercentage,
          RoundOff,
          FinancialYearID,
          UserID,
          CreatedBy,
          Remarks,
          CompanyID,
          BranchID,
          Deleted,
          Refund,
          TransactionDate,
          Cancelled,
          WaiterID,
          IsPending,
          ProdDiscount,
          CustomerGSTNo,
          BillNo,
          SeriesType,
          TableID,
          TokenNo,
          IsDespatched,
          IsSettled,
          DeliveryDate,
          DeliveryTime,
          DeliveryRemarks,
          IsShiftClosed,
          TabBillNo,
          ChairPositions,
          NoOfChairs,
          RedeemPoints,
          Redeem,
          TabID,
          Pax,
          ShiftNumber,
          CardID,
          CessAmount,
          IsComplementary,
          ComplementaryTotal,
          WaiterRemarks,
          IsSaved,
          IsTakenForUpload,
          EditedAfterUpload,
		  VehicleNo,
		  Merged
		  ,LastUpdate
		  ,CancelReason
		  ,ComplimentaryReason
		  ,IsPrintedFromPay
		  ,UpdatedUser,
		  OrderType,OrderOpenedDateTime,OrderClosedDateTime) ;


	-------------------SalesDetailInsertion--------------------------------------------------


	DELETE R_SalesTempDetail WHERE MasterID in (select MasterID from @saleDetail)

	INSERT INTO [dbo].[R_SalesTempDetail]
           (
		   [GuID],
           [MasterID]
           ,[ProductID]
           ,[Quantity]
           ,[BaseQuantity]
           ,[UnitRate]
           ,[TaxID]
           ,[TaxPercentage]
           ,[Tax]
           ,[DiscPercentage]
           ,[Discount]
           ,[UnitID]
           ,[ItemTypeID]
           ,[Deleted]
           ,[IsTaxIncludedInPrice]
           ,[Cancelled]
           ,[IsStockUpdated]
           ,[Remarks]
           ,[R_ProductUpdated]
           ,[Merged]
           ,[CessAmount], ChairNo, CourseNo)

          select
		  [GuID],
           MasterID,
           ProductID,
           Quantity,
           BaseQuantity,
           UnitRate,
           TaxID,
           TaxPercentage,
           Tax,
           DiscPercentage,
           Discount,
           UnitID,
           ItemTypeID,
           Deleted,
           IsTaxIncludedInPrice,
           Cancelled,
           IsStockUpdated,
           Remarks,
           R_ProductUpdated,
           Merged,
           CessAmount, ChairNo, CourseNo from @saleDetail


	-------------SaleComboDetailInsertion-----------------------------------

	DELETE [R_SalesTempComboDetail] WHERE MasterID in(select MasterID from @saleComboDetail)

	INSERT INTO [dbo].[R_SalesTempComboDetail]
           (
		    DetailGuID
           ,[ProductID]
           ,[Quantity]
           ,[TypeID]
           ,[MasterProductID]
		   ,MasterID)

          select
          DetailGuID,
           ProductID,
           Quantity,
           TypeID,
           MasterProductID
		   ,MasterID
		   from @saleComboDetail


--	-------------------SalesPaymentDetailInsertion------------------------------------------------------------


	DELETE R_SalesTempPaymentDetail WHERE MasterID in (select MasterID from @salePaymentDetail)

	INSERT INTO [dbo].[R_SalesTempPaymentDetail]
           ([MasterID]
           ,[Type]
           ,[Amount]
           ,[CardNo]
           ,[CardTypeID]
           ,[FxTypeID]
           ,[FxPaid]
           ,[FxRate]
           ,[CustomerID]
           ,[deleted]
           ,[Cancelled])

           select
           MasterID,
           Type,
           Amount,
           CardNo,
           CardTypeID,
           FxTypeID,
           FxPaid,
           FxRate,
           CustomerID,
           deleted,
           Cancelled from @salePaymentDetail

--------------------------SalesProductModifierDetail Insertion------------------------------------------


	DELETE R_SalesTempProductModifierDetail WHERE MasterID in (select MasterID from @saleProductModifierDetail)

	INSERT INTO [dbo].[R_SalesTempProductModifierDetail]
           ([MasterID]
           ,[ProductID]
           ,[IsVoid]
           ,[Rate]
           ,[Quantity]
           ,[Cancelled]
           ,[Merged]
           ,[ModifierID]
           ,[ParentVoid]
           ,[VoidReason]
           ,[WastedQty])

    select
           MasterID,
           ProductID,
           IsVoid,
           Rate,
           Quantity,
           Cancelled,
           Merged,
           ModifierID,
           ParentVoid,
           VoidReason,
           WastedQty from @saleProductModifierDetail
 -- ------------------------SalesMiscellaneousSalesAmount Insertion------------------------------------------
 DELETE [R_MiscellaneousSalesAmount] WHERE MasterID in (select MasterID from @miscellaneousSalesAmount)
 INSERT INTO [dbo].[R_MiscellaneousSalesAmount]
    ([MasterID]
	 ,[DelveryID]
	 ,[ContainerID]
	 ,[OthrchargeID]
	 ,[DelAmount]
	 ,[ContAmount]
	 ,[OtherAmount]
	 ,[DayCloseStatus]
	 ,[Merged])
  select
       MasterID,
	   DelveryID,
       ContainerID,
	   OthrchargeID,
	   DelAmount,
	   ContAmount,
	   OtherAmount,
	   DayCloseStatus,
	   Merged from @miscellaneousSalesAmount

 ------------------------SalesDeliveryDetails Insertion------------------------------------------


 --DELETE [R_SalesTempDeliveryDetails] WHERE MasterID in(select MasterID from @saleDeliveryDetail)

 --INSERT INTO [dbo].[R_SalesTempDeliveryDetails]
 --          ([MasterID]
 --          ,[CustomerID]
 --          ,[EmployeeID]
 --          ,[DeliveryDate]
 --          ,[DeliveryTime]
 --          ,[DeliveryRemarks])

	--	select
 --          MasterID,
 --          CustomerID,
 --          EmployeeID,
 --          DeliveryDate,
 --          DeliveryTime,
 --          DeliveryRemarks from @saleDeliveryDetail

 ------------------------SalesDelivery Insertion------------------------------------------

 --DELETE [R_SalesTempDelivery] WHERE MasterID in (select MasterID from @saleDelivery)

 --INSERT INTO [dbo].[R_SalesTempDelivery]
 --          (
 --          [IsClosed],
 --          [MasterID])
 --    select
	--	   1,
 --          MasterID from @saleDelivery

------------------------------------

 DELETE [R_SalesTempDelivery] WHERE MasterID in (select MasterID from @saleDelivery)

 INSERT INTO [dbo].[R_SalesTempDelivery]
           (
		   [Guid],
           [MasterID],
           [IsClosed])
    select
		   newid(),
           MasterID,
		   1 from @saleDelivery



	DELETE FROM [R_SalesMaster]
	WHERE TransactionDate<=@TransactionDate AND BranchID = @BranchID

	DELETE FROM [R_SalesDetail]
	WHERE MasterID NOT IN (SELECT [Guid] FROM [R_SalesMaster])

	DELETE FROM [R_SalesComboDetail]
	WHERE DetailGuID NOT IN (SELECT [Guid] FROM [R_SalesDetail])

	DELETE FROM R_SalesPaymentDetail
	WHERE MasterID NOT IN (SELECT [Guid] FROM [R_SalesMaster])

	DELETE FROM R_SalesProductModifierDetail
	WHERE MasterID NOT IN (SELECT [Guid] FROM [R_SalesMaster])

	DELETE FROM [R_SalesDeliveryDetails]
	WHERE MasterID NOT IN (SELECT [Guid] FROM [R_SalesMaster])

	DELETE FROM [R_SalesDelivery]
	WHERE MasterID NOT IN (SELECT [Guid] FROM [R_SalesMaster])

	DELETE FROM R_SalesED
	WHERE MasterID NOT IN (SELECT [Guid] FROM [R_SalesMaster])



	COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        RETURN -1
   END CATCH
 RETURN 1
GO
PRINT 'Recreated restaurant.Sync_SalesTemp_Insert with ComplimentaryReason.';
GO
Create PROCEDURE [restaurant].[sale_temp_insert]

	@sale Restaurant.Sale READONLY,
	@saleDetail Restaurant.SaleDetail READONLY,
	@saleComboDetail Restaurant.SaleComboDetail READONLY,
	@salePaymentDetail Restaurant.SalePaymentDetail READONLY,
	@saleProductModifierDetail Restaurant.SaleProductModifierDetail READONLY,
	@saleDeliveryDetail Restaurant.SaleDeliveryDetail READONLY,
	@saleDelivery Restaurant.SaleDelivery READONLY
AS

begin
MERGE dbo.[R_SalesTempMaster] AS trg
    USING @sale AS s
      ON s.Guid = trg.Guid
     WHEN MATCHED THEN
       update  set

       [No] = s.No,
       [Date] = s.Date,
       SectionID = s.SectionID,
       CounterID = s.CounterID,
       BillTime =s.BillTime,
       CustomerID = s.CustomerID,
       Total = s.Total,
       RTotal = s.RTotal,
       Tax = s.Tax,
       Cash = s.Cash,
       [Card] = s.Card,
       CardNo = s.CardNo,
       FxPaid = s.FxPaid,
       FxTypeID = s.FxTypeID,
       FxRate = s.FxRate,
       FxAmount = s.FxAmount,
       CustomerCredit = s.CustomerCredit,
       Discount = s.Discount,
	   DiscountPercentage = s.DiscountPercentage,
	   RoundOff = s.RoundOff,
       FinancialYearID = s.FinancialYearID,
       UserID = s.UserID,
       CreatedBy = s.CreatedBy,
       Remarks = s.Remarks,
       CompanyID = s.CompanyID,
       BranchID = s.BranchID,
       Deleted = s.Deleted,
       Refund = s.Refund,
       TransactionDate = s.TransactionDate,
       Cancelled = s.Cancelled,
       WaiterID = s.WaiterID,
       IsPending = s.IsPending,
       ProdDiscount = s.ProdDiscount,
       CustomerGSTNo = s.CustomerGSTNo,
       BillNo = s.BillNo,
       SeriesType = s.SeriesType,
       TableID =s. TableID,
       TokenNo = s.TokenNo,
       IsDespatched = s.IsDespatched,
       IsSettled = s.IsSettled,
       DeliveryDate = s.DeliveryDate,
       DeliveryTime = s.DeliveryTime,
       DeliveryRemarks =s. DeliveryRemarks,
       IsShiftClosed = s.IsShiftClosed,
       TabBillNo = s.TabBillNo,
       ChairPositions = s.ChairPositions,
       NoOfChairs = s.NoOfChairs,
       RedeemPoints =s. RedeemPoints,
       Redeem = s.Redeem,
       TabID = s.TabID,
       Pax = s.Pax,
       ShiftNumber = s.ShiftNumber,
       CardID = s.CardID,
       CessAmount = s.CessAmount,
       IsComplementary = s.IsComplementary,
       ComplementaryTotal = s.ComplementaryTotal,
       WaiterRemarks = s.WaiterRemarks,
       IsSaved = s.IsSaved,
       IsTakenForUpload = s.IsTakenForUpload,
       EditedAfterUpload = s.EditedAfterUpload,
	   VehicleNo = s.VehicleNo,
	   Merged = s.Merged ,
	   OrderType = s.OrderType
     WHEN NOT MATCHED BY TARGET THEN
      INSERT
	(
			[GuID],
            [No]
           ,[Date]
           ,[SectionID]
           ,[CounterID]
           ,[BillTime]
           ,[CustomerID]
           ,[Total]
           ,[RTotal]
           ,[Tax]
           ,[Cash]
           ,[Card]
           ,[CardNo]
           ,[FxPaid]
           ,[FxTypeID]
           ,[FxRate]
           ,[FxAmount]
           ,[CustomerCredit]
           ,[Discount]
           ,[DiscountPercentage]
           ,[RoundOff]
           ,[FinancialYearID]
           ,[UserID]
           ,[CreatedBy]
           ,[Remarks]
           ,[CompanyID]
           ,[BranchID]
           ,[Deleted]
           ,[Refund]
           ,[TransactionDate]
           ,[Cancelled]
           ,[WaiterID]
           ,[IsPending]
           ,[ProdDiscount]
           ,[CustomerGSTNo]
           ,[BillNo]
           ,[SeriesType]
           ,[TableID]
           ,[TokenNo]
           ,[IsDespatched]
           ,[IsSettled]
           ,[DeliveryDate]
           ,[DeliveryTime]
           ,[DeliveryRemarks]
           ,[IsShiftClosed]
           ,[TabBillNo]
           ,[ChairPositions]
           ,[NoOfChairs]
           ,[RedeemPoints]
           ,[Redeem]
           ,[TabID]
           ,[Pax]
           ,[ShiftNumber]
           ,[CardID]
           ,[CessAmount]
           ,[IsComplementary]
           ,[ComplementaryTotal]
           ,[WaiterRemarks]
           ,[IsSaved]
           ,[IsTakenForUpload]
           ,[EditedAfterUpload]
		   ,[VehicleNo]
		   ,Merged
		   ,OrderType)
     values
	     ( GuID,
          No,
          Date,
          SectionID,
          CounterID,
          BillTime,
          CustomerID,
          Total,
          RTotal,
          Tax,
          Cash,
          Card,
          CardNo,
          FxPaid,
          FxTypeID,
          FxRate,
          FxAmount,
          CustomerCredit,
          Discount,
          DiscountPercentage,
          RoundOff,
          FinancialYearID,
          UserID,
          CreatedBy,
          Remarks,
          CompanyID,
          BranchID,
          Deleted,
          Refund,
          TransactionDate,
          Cancelled,
          WaiterID,
          IsPending,
          ProdDiscount,
          CustomerGSTNo,
          BillNo,
          SeriesType,
          TableID,
          TokenNo,
          IsDespatched,
          IsSettled,
          DeliveryDate,
          DeliveryTime,
          DeliveryRemarks,
          IsShiftClosed,
          TabBillNo,
          ChairPositions,
          NoOfChairs,
          RedeemPoints,
          Redeem,
          TabID,
          Pax,
          ShiftNumber,
          CardID,
          CessAmount,
          IsComplementary,
          ComplementaryTotal,
          WaiterRemarks,
          IsSaved,
          IsTakenForUpload,
          EditedAfterUpload,
		  VehicleNo,
		  Merged,
		  OrderType) ;


	   end

	-------------------SalesTempDetailInsertion--------------------------------------------------


	DELETE R_SalesTempDetail WHERE MasterID in (select MasterID from @saleDetail)

	INSERT INTO [dbo].[R_SalesTempDetail]
           (
           [MasterID]
           ,[ProductID]
           ,[Quantity]
           ,[BaseQuantity]
           ,[UnitRate]
           ,[TaxID]
           ,[TaxPercentage]
           ,[Tax]
           ,[DiscPercentage]
           ,[Discount]
           ,[UnitID]
           ,[ItemTypeID]
           ,[Deleted]
           ,[IsTaxIncludedInPrice]
           ,[Cancelled]
           ,[IsStockUpdated]
           ,[Remarks]
           ,[R_ProductUpdated]
           ,[Merged]
           ,[CessAmount], ChairNo, CourseNo)

          select
           MasterID,
           ProductID,
           Quantity,
           BaseQuantity,
           UnitRate,
           TaxID,
           TaxPercentage,
           Tax,
           DiscPercentage,
           Discount,
           UnitID,
           ItemTypeID,
           Deleted,
           IsTaxIncludedInPrice,
           Cancelled,
           IsStockUpdated,
           Remarks,
           R_ProductUpdated,
           Merged,
           CessAmount, ChairNo, CourseNo from @saleDetail


	-------------SaleTempComboDetailInsertion-----------------------------------



	DELETE R_SalesTempComboDetail WHERE MasterID in(select MasterID from @saleComboDetail)

	INSERT INTO [dbo].[R_SalesTempComboDetail]
           (
          [ProductID]
           ,[Quantity]
           ,[TypeID]
           ,[MasterProductID]

		   ,MasterID)

          select

           ProductID,
           Quantity,
           TypeID,
           MasterProductID

		   ,MasterID from @saleComboDetail

	-------------------SalesTempPaymentDetailInsertion------------------------------------------------------------


	DELETE R_SalesTempPaymentDetail WHERE MasterID in (select MasterID from @salePaymentDetail)

	INSERT INTO [dbo].[R_SalesTempPaymentDetail]
           ([MasterID]
           ,[Type]
           ,[Amount]
           ,[CardNo]
           ,[CardTypeID]
           ,[FxTypeID]
           ,[FxPaid]
           ,[FxRate]
           ,[CustomerID]
           ,[deleted]
           ,[Cancelled])

           select
           MasterID,
           Type,
           Amount,
           CardNo,
           CardTypeID,
           FxTypeID,
           FxPaid,
           FxRate,
           CustomerID,
           deleted,
           Cancelled from @salePaymentDetail

------------------------SalesTempProductModifierDetail Insertion------------------------------------------


	DELETE R_SalesTempProductModifierDetail WHERE MasterID in (select MasterID from @saleProductModifierDetail)

	INSERT INTO [dbo].[R_SalesTempProductModifierDetail]
           ([MasterID]
           ,[ProductID]
           ,[IsVoid]
           ,[Rate]
           ,[Quantity]
           ,[Cancelled]
           ,[Merged]
           ,[ModifierID]
           ,[ParentVoid]
           ,[VoidReason]
           ,[WastedQty])

    select
           MasterID,
           ProductID,
           IsVoid,
           Rate,
           Quantity,
           Cancelled,
           Merged,
           ModifierID,
           ParentVoid,
           VoidReason,
           WastedQty from @saleProductModifierDetail

 ------------------------SalesTempDeliveryDetails Insertion------------------------------------------


 DELETE [R_SalesTempDeliveryDetails] WHERE MasterID in (select MasterID from @saleDeliveryDetail)

 INSERT INTO [dbo].[R_SalesTempDeliveryDetails]
           ([MasterID]
           ,[CustomerID]
           ,[EmployeeID]
           ,[DeliveryDate]
           ,[DeliveryTime]
           ,[DeliveryRemarks])

		select
           MasterID,
           CustomerID,
           EmployeeID,
           DeliveryDate,
           DeliveryTime,
           DeliveryRemarks from @saleDeliveryDetail

-----------------------------------------------------------------

 DELETE [R_SalesDeliveryDetails] WHERE MasterID in(select MasterID from @saleDeliveryDetail)

 INSERT INTO [dbo].[R_SalesDeliveryDetails]
           ([MasterID]
           ,[CustomerID]
           ,[EmployeeID]
           ,[DeliveryDate]
           ,[DeliveryTime]
           ,[DeliveryRemarks])

		select
           MasterID,
           CustomerID,
           EmployeeID,
           DeliveryDate,
           DeliveryTime,
           DeliveryRemarks from @saleDeliveryDetail

 ------------------------SalesTempDelivery Insertion------------------------------------------

 DELETE [R_SalesTempDelivery] WHERE MasterID in (select MasterID from @saleDelivery)

 INSERT INTO [dbo].[R_SalesTempDelivery]
           (
           [IsClosed],
           [MasterID])
     select
		   1,
           MasterID from @saleDelivery

------------------------------------

 DELETE [R_SalesDelivery] WHERE MasterID in (select MasterID from @saleDelivery)

 INSERT INTO [dbo].[R_SalesDelivery]
           (
		   [Guid],
           [MasterID],
           [IsClosed])
    select
		   newid(),
           MasterID,
		   1 from @saleDelivery


GO
PRINT 'Recreated restaurant.sale_temp_insert (unchanged, only needed re-creation to unblock UDT alter).';
GO
-- restaurant.Sync_Sales_GetAll (Windows-side sync source proc read by Axobis.Restaurant.Server.Sync's
-- SalesSyncHandler.GetAllSales - must select OrderType or the C# row["OrderType"] mapping throws and
-- breaks the whole sales upload batch for this customer)
-- Kashkan fix: added ComplimentaryReason so it flows through the sync pipeline like CancelReason already does.
CREATE OR ALTER PROCEDURE [restaurant].[Sync_Sales_GetAll]
	@Version BIGINT = NULL
AS

    SET NOCOUNT ON

	SELECT SM.ID,SM.[GuID],[No],[Date],SectionID,CounterID,BillTime,CustomerID,Total,RTotal,Tax,Cash,[Card],[CardNo],
	FxPaid,FxTypeID,FxRate,FxAmount,CustomerCredit,Discount,DiscountPercentage,RoundOff,FinancialYearID,
	UserID,CreatedBy,Remarks,CompanyID,LastUpdate,BranchID,Deleted,Refund,TransactionDate,IsPending,
	BillTypeID,Cancelled,WaiterID,ProdDiscount,CustomerGSTNo,BillNo,SeriesType,TableID,CancelReason,ComplimentaryReason,
	TokenNo,IsDespatched,IsSettled,DeliveryDate,DeliveryTime,DeliveryRemarks,IsShiftClosed,ShiftNumber,
	TabID,Merged,Pax,Redeem,ISNULL(RedeemPoints,0)RedeemPoints,NoOfChairs,ChairPositions,TabBillNo,IsComplementary,ComplementaryTotal,
	CardID,IsprintedFromPay,CessAmount,WaiterRemarks,IsSaved,IsTakenForUpload,EditedAfterUpload,vehicleno,
	TabOrderNo,convert(BIGINT,Version)[Version],UpdatedUser
	,SD.[GuID] AS DeliveryID, OrderType, OrderOpenedDateTime, OrderClosedDateTime
	FROM [R_SalesMaster] SM
	LEFT OUTER JOIN [R_SalesDelivery] SD ON SM.[GuID] = SD.MasterID
	WHERE [Version] > @Version

	SELECT *  FROM [R_SalesDetail]

	SELECT [GuID],MasterID,[Type],[Amount],CardNo,CardTypeID,FxTypeID,FxPaid,FxRate,[CustomerID],deleted,Cancelled
	FROM [dbo].[R_SalesPaymentDetail]

	SELECT * FROM R_SalesProductModifierDetail

	SELECT * FROM [R_SalesComboDetail]

	SELECT * FROM [R_SalesDelivery]

	SELECT * FROM [R_MiscellaneousSalesAmount]

	SET NOCOUNT OFF
GO
PRINT 'Fixed restaurant.Sync_Sales_GetAll to include ComplimentaryReason.';
GO
CREATE OR ALTER PROCEDURE [restaurant].[Sync_SalesTemp_GetAll]
	@Version BIGINT = NULL
AS

    SET NOCOUNT ON

	SELECT  SM.ID,SM.[GuID],[No],[Date],SectionID,CounterID,BillTime,CustomerID,Total,RTotal,Tax,Cash,[Card],[CardNo],
	FxPaid,FxTypeID,FxRate,FxAmount,CustomerCredit,Discount,DiscountPercentage,RoundOff,FinancialYearID,
	UserID,CreatedBy,Remarks,CompanyID,LastUpdate,BranchID,Deleted,Refund,TransactionDate,IsPending,
	Cancelled,WaiterID,ProdDiscount,CustomerGSTNo,BillNo,SeriesType,TableID,CancelReason,ComplimentaryReason,
	TokenNo,ISNULL(IsDespatched,0)IsDespatched,ISNULL(IsSettled,0)IsSettled,DeliveryDate,DeliveryTime,DeliveryRemarks,ISNULL(IsShiftClosed,0)IsShiftClosed,ShiftNumber,
	TabID,Merged,Pax,ISNULL(Redeem,0)Redeem,ISNULL(RedeemPoints,0)RedeemPoints,NoOfChairs,ChairPositions,TabBillNo,IsComplementary,ComplementaryTotal,
	CardID,IsprintedFromPay,CessAmount,WaiterRemarks,IsSaved,IsTakenForUpload,EditedAfterUpload,vehicleno,
	convert(BIGINT,Version)[Version],UpdatedUser
	,SD.[GuID] AS DeliveryID, OrderOpenedDateTime, OrderClosedDateTime
	FROM [R_SalesTempMaster] SM
	LEFT OUTER JOIN [R_SalesDelivery] SD ON SM.[GuID] = SD.MasterID
	WHERE [Version] > @Version

	SELECT * FROM [R_SalesTempDetail]

	SELECT * FROM [dbo].[R_SalesTempPaymentDetail]

	SELECT * FROM R_SalesTempProductModifierDetail

	SELECT * FROM [R_SalesTempComboDetail]

	SELECT * FROM [R_SalesTempDelivery]

	--SELECT * FROM [R_SalesTempDeliveryDetails]


	SET NOCOUNT OFF
GO
PRINT 'Fixed restaurant.Sync_SalesTemp_GetAll to include ComplimentaryReason.';
GO

PRINT 'Section AA complete.';
GO

-- ============================================================
-- Section AB - Kashkan Phase 4: Void Report (Req #3), backend only.
-- Depends on dbo.R_VoidLog (created in Section AA's predecessor round,
-- Phase 3). New item-level report distinct from the existing
-- invoice-level GetSalesStatusReport: order #, item, qty voided,
-- reason, who voided it, and when. Two SPs follow the same
-- non-paged/paged pairing used throughout this file (e.g.
-- Report_ItemWiseSalesreport / Report_ItemWiseSalesreportPaging).
-- No React/WinForms UI in this round - contract documented for the
-- frontend handover doc; this is the WebAPI-facing backend only.
--
-- Addendum: wires R_VoidLog into the local-to-cloud sync pipeline
-- (found during testing: void reasons saved correctly locally but
-- never reached the Web DB, unlike ComplimentaryReason/CancelReason
-- which ride along on R_SalesMaster's own Sale UDT sync). Mirrors the
-- same GetAll/Insert pattern already used for every other synced
-- entity (e.g. Sync_StockOver_GetAll/Sync_StockOver_Insert): a Version
-- (rowversion) column drives "since last sync" incremental pulls on
-- the local side, a MERGE-based Insert proc idempotently upserts by
-- GuID on the cloud side.
-- ============================================================

CREATE OR ALTER PROCEDURE [restaurant].[Report_VoidLog]
(
 @FromDate   DATE          = NULL,
 @ToDate     DATE          = NULL,
 @BranchID   VARCHAR(MAX)  = NULL,
 @SectionID  VARCHAR(MAX)  = NULL,
 @CounterID  VARCHAR(MAX)  = NULL,
 @ProductID  VARCHAR(MAX)  = NULL,
 @UserID     VARCHAR(MAX)  = NULL
)
AS
BEGIN
	DECLARE
	     @R_FromDate  DATE          = @FromDate,
	     @R_ToDate    DATE          = @ToDate,
	     @R_BranchID  VARCHAR(MAX)  = NULLIF(@BranchID,''),
	     @R_SectionID VARCHAR(MAX)  = NULLIF(@SectionID,''),
	     @R_CounterID VARCHAR(MAX)  = NULLIF(@CounterID,''),
	     @R_ProductID VARCHAR(MAX)  = NULLIF(@ProductID,''),
	     @R_UserID    VARCHAR(MAX)  = NULLIF(@UserID,'')

	SET ARITHABORT ON; SET XACT_ABORT ON; SET NOCOUNT ON;
	IF @R_ToDate IS NOT NULL SET @R_ToDate = DATEADD(D, 1, @R_ToDate);

	SELECT VL.BillNo, VL.VoidedDate, VL.ProductName AS Product, VL.Quantity, VL.UnitRate, VL.Reason,
	       VL.VoidedByUserName AS [User], ISNULL(S.Name,'') [Section], ISNULL(C.Name,'') [Counter], ISNULL(B.Name,'') [Branch]
	FROM [dbo].[R_VoidLog] VL
	LEFT OUTER JOIN restaurant.Section S ON S.[GuID] = VL.SectionID
	LEFT OUTER JOIN R_Counter C ON C.[GuID] = VL.CounterID
	LEFT OUTER JOIN R_Branch B ON B.[GuID] = VL.BranchID
	WHERE (VL.VoidedDate >= @R_FromDate OR @R_FromDate IS NULL)
	AND (VL.VoidedDate < @R_ToDate OR @R_ToDate IS NULL)
	AND (VL.BranchID = @R_BranchID OR @R_BranchID IS NULL)
	AND (VL.SectionID = @R_SectionID OR @R_SectionID IS NULL)
	AND (VL.CounterID = @R_CounterID OR @R_CounterID IS NULL)
	AND (VL.ProductID = @R_ProductID OR @R_ProductID IS NULL)
	AND (VL.VoidedByUserID = @R_UserID OR @R_UserID IS NULL)
	ORDER BY VL.VoidedDate DESC;

	SET NOCOUNT OFF;
END
GO
PRINT 'Created or altered SP Report_VoidLog.';
GO

CREATE OR ALTER PROCEDURE [restaurant].[Report_VoidLogPaging]
(
 @FromDate         DATE          = NULL,
 @ToDate           DATE          = NULL,
 @BranchID         VARCHAR(MAX)  = NULL,
 @SectionID        VARCHAR(MAX)  = NULL,
 @CounterID        VARCHAR(MAX)  = NULL,
 @ProductID        VARCHAR(MAX)  = NULL,
 @UserID           VARCHAR(MAX)  = NULL,
 @PageNumber       INT           = NULL,
 @PageSize         INT           = NULL,
 @SortingColumn    VARCHAR(MAX)  = NULL,
 @SortingDirection VARCHAR(MAX)  = NULL
)
AS
BEGIN
	DECLARE
	     @R_FromDate         DATE           = @FromDate,
	     @R_ToDate           DATE           = @ToDate,
	     @R_BranchID         VARCHAR(MAX)   = NULLIF(@BranchID,''),
	     @R_SectionID        VARCHAR(MAX)   = NULLIF(@SectionID,''),
	     @R_CounterID        VARCHAR(MAX)   = NULLIF(@CounterID,''),
	     @R_ProductID        VARCHAR(MAX)   = NULLIF(@ProductID,''),
	     @R_UserID           VARCHAR(MAX)   = NULLIF(@UserID,''),
	     @R_PageNumber       INT            = @PageNumber,
	     @R_PageSize         INT            = @PageSize,
	     @R_SortingColumn    VARCHAR(MAX)   = @SortingColumn,
	     @R_SortingDirection VARCHAR(MAX)   = ISNULL(@SortingDirection,'DESC')

	DECLARE @SortingCmd VARCHAR(MAX)

	SET ARITHABORT ON; SET XACT_ABORT ON; SET NOCOUNT ON;
	IF @R_ToDate IS NOT NULL SET @R_ToDate = DATEADD(D, 1, @R_ToDate);

	IF Object_id('TempDB.dbo.#VoidLogReport') IS NOT NULL DROP TABLE #VoidLogReport;
	IF Object_id('TempDB.dbo.#VoidLogReportCount') IS NOT NULL DROP TABLE #VoidLogReportCount;

	SELECT VL.[GuID],VL.BillNo,VL.VoidedDate,VL.ProductName AS Product,VL.Quantity,VL.UnitRate,VL.Reason,
	       VL.VoidedByUserName AS [User],ISNULL(S.Name,'')[Section],ISNULL(C.Name,'')[Counter],ISNULL(B.Name,'')[Branch]
	INTO #VoidLogReport
	FROM [dbo].[R_VoidLog] VL
	LEFT OUTER JOIN restaurant.Section S ON S.[GuID] = VL.SectionID
	LEFT OUTER JOIN R_Counter C ON C.[GuID] = VL.CounterID
	LEFT OUTER JOIN R_Branch B ON B.[GuID] = VL.BranchID
	WHERE (VL.VoidedDate >= @R_FromDate OR @R_FromDate IS NULL)
	AND (VL.VoidedDate < @R_ToDate OR @R_ToDate IS NULL)
	AND (VL.BranchID = @R_BranchID OR @R_BranchID IS NULL)
	AND (VL.SectionID = @R_SectionID OR @R_SectionID IS NULL)
	AND (VL.CounterID = @R_CounterID OR @R_CounterID IS NULL)
	AND (VL.ProductID = @R_ProductID OR @R_ProductID IS NULL)
	AND (VL.VoidedByUserID = @R_UserID OR @R_UserID IS NULL);

	SELECT COUNT(*) AS VoidLogCount INTO #VoidLogReportCount FROM #VoidLogReport;

	IF @PageSize=-1
	BEGIN
		IF @R_SortingColumn IS NULL
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT VoidLogCount FROM #VoidLogReportCount)[RowCount] FROM #VoidLogReport ORDER BY VoidedDate '+@R_SortingDirection+',BillNo '+@R_SortingDirection;
			EXEC(@SortingCmd);
		END
		ELSE
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT VoidLogCount FROM #VoidLogReportCount)[RowCount],VoidedDate AS VoidedDate1,BillNo AS BillNo1 FROM #VoidLogReport ORDER BY '+@R_SortingColumn+' '+@R_SortingDirection+',VoidedDate1 desc,BillNo1 asc';
			EXEC(@SortingCmd);
		END
	END
	ELSE
	BEGIN
		IF @R_SortingColumn IS NULL
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT VoidLogCount FROM #VoidLogReportCount)[RowCount] FROM #VoidLogReport ORDER BY VoidedDate '+@R_SortingDirection+',BillNo '+@R_SortingDirection+' OFFSET ('+CAST(@R_PageNumber-1 AS NVARCHAR(MAX))+')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS FETCH NEXT '+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS ONLY';
			EXEC(@SortingCmd);
		END
		ELSE
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT VoidLogCount FROM #VoidLogReportCount)[RowCount],VoidedDate AS VoidedDate1,BillNo AS BillNo1 FROM #VoidLogReport ORDER BY '+@R_SortingColumn+' '+@R_SortingDirection+',VoidedDate1 desc,BillNo1 asc OFFSET ('+CAST(@R_PageNumber-1 AS NVARCHAR(MAX))+')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS FETCH NEXT '+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS ONLY';
			EXEC(@SortingCmd);
		END
	END

	SELECT SUM(Quantity) AS Quantity FROM #VoidLogReport;

	IF Object_id('TempDB.dbo.#VoidLogReport') IS NOT NULL DROP TABLE #VoidLogReport;
	IF Object_id('TempDB.dbo.#VoidLogReportCount') IS NOT NULL DROP TABLE #VoidLogReportCount;
	SET NOCOUNT OFF;
END
GO
PRINT 'Created or altered SP Report_VoidLogPaging.';
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.R_VoidLog') AND name = 'Version')
BEGIN
    ALTER TABLE dbo.R_VoidLog ADD Version ROWVERSION;
    PRINT 'Added column Version to dbo.R_VoidLog successfully.';
END
ELSE
    PRINT 'Column Version already exists on dbo.R_VoidLog.';
GO

IF EXISTS (SELECT 1 FROM sys.table_types WHERE name = 'VoidLog_UDT' AND schema_id = SCHEMA_ID('restaurant'))
    DROP TYPE [restaurant].[VoidLog_UDT];
GO

CREATE TYPE [restaurant].[VoidLog_UDT] AS TABLE (
    [GuID]             uniqueidentifier NOT NULL,
    [MasterID]         uniqueidentifier NULL,
    [BillNo]           varchar(50)      NULL,
    [SectionID]        uniqueidentifier NULL,
    [CounterID]        uniqueidentifier NULL,
    [BranchID]         uniqueidentifier NULL,
    [ProductID]        uniqueidentifier NULL,
    [ProductName]      varchar(200)     NULL,
    [Quantity]         decimal(18,3)    NULL,
    [UnitRate]         money            NULL,
    [Reason]           varchar(250)     NULL,
    [VoidedByUserID]   uniqueidentifier NULL,
    [VoidedByUserName] varchar(100)     NULL,
    [VoidedDate]       datetime         NOT NULL,
    [CompanyID]        int              NULL,
    [FinancialYearID]  decimal(18,0)    NULL
);
GO
PRINT 'Created restaurant.VoidLog_UDT.';
GO

-- Local-side pull: run against the WinForms DB, feeds Server.Sync's VoidLogSyncHandler.GetAll().
CREATE OR ALTER PROCEDURE [restaurant].[Sync_VoidLog_GetAll]
    @Version BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT GuID, MasterID, BillNo, SectionID, CounterID, BranchID, ProductID, ProductName, Quantity, UnitRate, Reason,
           VoidedByUserID, VoidedByUserName, VoidedDate, CompanyID, FinancialYearID, CONVERT(BIGINT, Version) AS [Version]
    FROM dbo.R_VoidLog
    WHERE CONVERT(BIGINT, Version) > @Version
    ORDER BY Version;
    SET NOCOUNT OFF;
END
GO
PRINT 'Created or altered SP Sync_VoidLog_GetAll.';
GO

-- Cloud-side push: run against the Web DB, called by SaleDataAccess.Upload(List<VoidLog>) via Api/Sale/VoidLog/Sync/Upload.
CREATE OR ALTER PROCEDURE [restaurant].[Sync_VoidLog_Insert]
    @UDT_VoidLog [restaurant].[VoidLog_UDT] READONLY
AS
BEGIN
    SET NOCOUNT ON;
    MERGE dbo.[R_VoidLog] AS trg
    USING @UDT_VoidLog AS s
    ON s.GuID = trg.GuID
    WHEN MATCHED THEN UPDATE SET
        trg.MasterID = s.MasterID,
        trg.BillNo = s.BillNo,
        trg.SectionID = s.SectionID,
        trg.CounterID = s.CounterID,
        trg.BranchID = s.BranchID,
        trg.ProductID = s.ProductID,
        trg.ProductName = s.ProductName,
        trg.Quantity = s.Quantity,
        trg.UnitRate = s.UnitRate,
        trg.Reason = s.Reason,
        trg.VoidedByUserID = s.VoidedByUserID,
        trg.VoidedByUserName = s.VoidedByUserName,
        trg.VoidedDate = s.VoidedDate,
        trg.CompanyID = s.CompanyID,
        trg.FinancialYearID = s.FinancialYearID
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (GuID, MasterID, BillNo, SectionID, CounterID, BranchID, ProductID, ProductName, Quantity, UnitRate, Reason,
                VoidedByUserID, VoidedByUserName, VoidedDate, CompanyID, FinancialYearID)
        VALUES (s.GuID, s.MasterID, s.BillNo, s.SectionID, s.CounterID, s.BranchID, s.ProductID, s.ProductName, s.Quantity, s.UnitRate, s.Reason,
                s.VoidedByUserID, s.VoidedByUserName, s.VoidedDate, s.CompanyID, s.FinancialYearID);
    SET NOCOUNT OFF;
END
GO
PRINT 'Created or altered SP Sync_VoidLog_Insert.';
GO

PRINT 'Section AB complete.';
GO

-- ============================================================
-- Section AC - Kashkan Phase 5: Order Timing + Captain/Waiter Report
-- (Req #4), backend only. Depends on OrderOpenedDateTime/
-- OrderClosedDateTime (added to R_SalesMaster/R_SalesTempMaster in
-- Section B, and to the sync pipeline via the same reused UDT cycle
-- in Section AA) already being populated by WinForms/TABApi at
-- Insert()/settle time. Per-order report (not aggregated like the
-- existing GetWaiterWiseSale) showing how long each order took from
-- open to close, per waiter/captain - UNIONs R_SalesMaster (today,
-- not yet day-closed) and R_SalesTempMaster (already day-closed),
-- same reason GetWaiterWiseSale does. No React/WinForms UI in this
-- round - contract documented for the frontend handover doc.
-- ============================================================

CREATE OR ALTER PROCEDURE [restaurant].[Report_OrderTiming]
(
 @FromDate   DATE          = NULL,
 @ToDate     DATE          = NULL,
 @BranchID   VARCHAR(MAX)  = NULL,
 @SectionID  VARCHAR(MAX)  = NULL,
 @CounterID  VARCHAR(MAX)  = NULL,
 @UserID     VARCHAR(MAX)  = NULL
)
AS
BEGIN
	DECLARE
	     @R_FromDate  DATE          = @FromDate,
	     @R_ToDate    DATE          = @ToDate,
	     @R_BranchID  VARCHAR(MAX)  = NULLIF(@BranchID,''),
	     @R_SectionID VARCHAR(MAX)  = NULLIF(@SectionID,''),
	     @R_CounterID VARCHAR(MAX)  = NULLIF(@CounterID,''),
	     @R_UserID    VARCHAR(MAX)  = NULLIF(@UserID,'')

	SET ARITHABORT ON; SET XACT_ABORT ON; SET NOCOUNT ON;
	IF @R_ToDate IS NOT NULL SET @R_ToDate = DATEADD(D, 1, @R_ToDate);

	SELECT * FROM (
		SELECT SM.BillNo, SM.TransactionDate, SM.OrderOpenedDateTime, SM.OrderClosedDateTime,
		       DATEDIFF(MINUTE, SM.OrderOpenedDateTime, SM.OrderClosedDateTime) AS DurationMinutes,
		       ISNULL(U.Name,'') AS [User], ISNULL(S.Name,'') [Section], ISNULL(C.Name,'') [Counter], ISNULL(B.Name,'') [Branch],
		       (SM.Total+SM.Tax+SM.CessAmount-SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff) AS NetTotal
		FROM R_SalesMaster SM
		LEFT OUTER JOIN R_User U ON U.[GuID] = SM.WaiterID
		LEFT OUTER JOIN restaurant.Section S ON S.[GuID] = SM.SectionID
		LEFT OUTER JOIN R_Counter C ON C.[GuID] = SM.CounterID
		LEFT OUTER JOIN R_Branch B ON B.[GuID] = SM.BranchID
		WHERE SM.Deleted = 0
		AND (SM.TransactionDate >= @R_FromDate OR @R_FromDate IS NULL)
		AND (SM.TransactionDate < @R_ToDate OR @R_ToDate IS NULL)
		AND (SM.BranchID = @R_BranchID OR @R_BranchID IS NULL)
		AND (SM.SectionID = @R_SectionID OR @R_SectionID IS NULL)
		AND (SM.CounterID = @R_CounterID OR @R_CounterID IS NULL)
		AND (SM.WaiterID = @R_UserID OR @R_UserID IS NULL)
		UNION ALL
		SELECT SM.BillNo, SM.TransactionDate, SM.OrderOpenedDateTime, SM.OrderClosedDateTime,
		       DATEDIFF(MINUTE, SM.OrderOpenedDateTime, SM.OrderClosedDateTime) AS DurationMinutes,
		       ISNULL(U.Name,'') AS [User], ISNULL(S.Name,'') [Section], ISNULL(C.Name,'') [Counter], ISNULL(B.Name,'') [Branch],
		       (SM.Total+SM.Tax+SM.CessAmount-SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff) AS NetTotal
		FROM R_SalesTempMaster SM
		LEFT OUTER JOIN R_User U ON U.[GuID] = SM.WaiterID
		LEFT OUTER JOIN restaurant.Section S ON S.[GuID] = SM.SectionID
		LEFT OUTER JOIN R_Counter C ON C.[GuID] = SM.CounterID
		LEFT OUTER JOIN R_Branch B ON B.[GuID] = SM.BranchID
		WHERE SM.Deleted = 0
		AND (SM.TransactionDate >= @R_FromDate OR @R_FromDate IS NULL)
		AND (SM.TransactionDate < @R_ToDate OR @R_ToDate IS NULL)
		AND (SM.BranchID = @R_BranchID OR @R_BranchID IS NULL)
		AND (SM.SectionID = @R_SectionID OR @R_SectionID IS NULL)
		AND (SM.CounterID = @R_CounterID OR @R_CounterID IS NULL)
		AND (SM.WaiterID = @R_UserID OR @R_UserID IS NULL)
	) AS T
	ORDER BY OrderOpenedDateTime DESC;

	SET NOCOUNT OFF;
END
GO
PRINT 'Created or altered SP Report_OrderTiming.';
GO

CREATE OR ALTER PROCEDURE [restaurant].[Report_OrderTimingPaging]
(
 @FromDate         DATE          = NULL,
 @ToDate           DATE          = NULL,
 @BranchID         VARCHAR(MAX)  = NULL,
 @SectionID        VARCHAR(MAX)  = NULL,
 @CounterID        VARCHAR(MAX)  = NULL,
 @UserID           VARCHAR(MAX)  = NULL,
 @PageNumber       INT           = NULL,
 @PageSize         INT           = NULL,
 @SortingColumn    VARCHAR(MAX)  = NULL,
 @SortingDirection VARCHAR(MAX)  = NULL
)
AS
BEGIN
	DECLARE
	     @R_FromDate         DATE           = @FromDate,
	     @R_ToDate           DATE           = @ToDate,
	     @R_BranchID         VARCHAR(MAX)   = NULLIF(@BranchID,''),
	     @R_SectionID        VARCHAR(MAX)   = NULLIF(@SectionID,''),
	     @R_CounterID        VARCHAR(MAX)   = NULLIF(@CounterID,''),
	     @R_UserID           VARCHAR(MAX)   = NULLIF(@UserID,''),
	     @R_PageNumber       INT            = @PageNumber,
	     @R_PageSize         INT            = @PageSize,
	     @R_SortingColumn    VARCHAR(MAX)   = @SortingColumn,
	     @R_SortingDirection VARCHAR(MAX)   = ISNULL(@SortingDirection,'DESC')

	DECLARE @SortingCmd VARCHAR(MAX)

	SET ARITHABORT ON; SET XACT_ABORT ON; SET NOCOUNT ON;
	IF @R_ToDate IS NOT NULL SET @R_ToDate = DATEADD(D, 1, @R_ToDate);

	IF Object_id('TempDB.dbo.#OrderTimingReport') IS NOT NULL DROP TABLE #OrderTimingReport;
	IF Object_id('TempDB.dbo.#OrderTimingReportCount') IS NOT NULL DROP TABLE #OrderTimingReportCount;

	SELECT * INTO #OrderTimingReport FROM (
		SELECT SM.BillNo, SM.TransactionDate, SM.OrderOpenedDateTime, SM.OrderClosedDateTime,
		       DATEDIFF(MINUTE, SM.OrderOpenedDateTime, SM.OrderClosedDateTime) AS DurationMinutes,
		       ISNULL(U.Name,'') AS [User], ISNULL(S.Name,'') [Section], ISNULL(C.Name,'') [Counter], ISNULL(B.Name,'') [Branch],
		       (SM.Total+SM.Tax+SM.CessAmount-SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff) AS NetTotal
		FROM R_SalesMaster SM
		LEFT OUTER JOIN R_User U ON U.[GuID] = SM.WaiterID
		LEFT OUTER JOIN restaurant.Section S ON S.[GuID] = SM.SectionID
		LEFT OUTER JOIN R_Counter C ON C.[GuID] = SM.CounterID
		LEFT OUTER JOIN R_Branch B ON B.[GuID] = SM.BranchID
		WHERE SM.Deleted = 0
		AND (SM.TransactionDate >= @R_FromDate OR @R_FromDate IS NULL)
		AND (SM.TransactionDate < @R_ToDate OR @R_ToDate IS NULL)
		AND (SM.BranchID = @R_BranchID OR @R_BranchID IS NULL)
		AND (SM.SectionID = @R_SectionID OR @R_SectionID IS NULL)
		AND (SM.CounterID = @R_CounterID OR @R_CounterID IS NULL)
		AND (SM.WaiterID = @R_UserID OR @R_UserID IS NULL)
		UNION ALL
		SELECT SM.BillNo, SM.TransactionDate, SM.OrderOpenedDateTime, SM.OrderClosedDateTime,
		       DATEDIFF(MINUTE, SM.OrderOpenedDateTime, SM.OrderClosedDateTime) AS DurationMinutes,
		       ISNULL(U.Name,'') AS [User], ISNULL(S.Name,'') [Section], ISNULL(C.Name,'') [Counter], ISNULL(B.Name,'') [Branch],
		       (SM.Total+SM.Tax+SM.CessAmount-SM.Discount-ISNULL(SM.ProdDiscount,0)+SM.RoundOff) AS NetTotal
		FROM R_SalesTempMaster SM
		LEFT OUTER JOIN R_User U ON U.[GuID] = SM.WaiterID
		LEFT OUTER JOIN restaurant.Section S ON S.[GuID] = SM.SectionID
		LEFT OUTER JOIN R_Counter C ON C.[GuID] = SM.CounterID
		LEFT OUTER JOIN R_Branch B ON B.[GuID] = SM.BranchID
		WHERE SM.Deleted = 0
		AND (SM.TransactionDate >= @R_FromDate OR @R_FromDate IS NULL)
		AND (SM.TransactionDate < @R_ToDate OR @R_ToDate IS NULL)
		AND (SM.BranchID = @R_BranchID OR @R_BranchID IS NULL)
		AND (SM.SectionID = @R_SectionID OR @R_SectionID IS NULL)
		AND (SM.CounterID = @R_CounterID OR @R_CounterID IS NULL)
		AND (SM.WaiterID = @R_UserID OR @R_UserID IS NULL)
	) AS T;

	SELECT COUNT(*) AS OrderTimingCount INTO #OrderTimingReportCount FROM #OrderTimingReport;

	IF @PageSize=-1
	BEGIN
		IF @R_SortingColumn IS NULL
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT OrderTimingCount FROM #OrderTimingReportCount)[RowCount] FROM #OrderTimingReport ORDER BY OrderOpenedDateTime '+@R_SortingDirection+',BillNo '+@R_SortingDirection;
			EXEC(@SortingCmd);
		END
		ELSE
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT OrderTimingCount FROM #OrderTimingReportCount)[RowCount],OrderOpenedDateTime AS OrderOpenedDateTime1,BillNo AS BillNo1 FROM #OrderTimingReport ORDER BY '+@R_SortingColumn+' '+@R_SortingDirection+',OrderOpenedDateTime1 desc,BillNo1 asc';
			EXEC(@SortingCmd);
		END
	END
	ELSE
	BEGIN
		IF @R_SortingColumn IS NULL
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT OrderTimingCount FROM #OrderTimingReportCount)[RowCount] FROM #OrderTimingReport ORDER BY OrderOpenedDateTime '+@R_SortingDirection+',BillNo '+@R_SortingDirection+' OFFSET ('+CAST(@R_PageNumber-1 AS NVARCHAR(MAX))+')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS FETCH NEXT '+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS ONLY';
			EXEC(@SortingCmd);
		END
		ELSE
		BEGIN
			SELECT @SortingCmd='SELECT *,(SELECT OrderTimingCount FROM #OrderTimingReportCount)[RowCount],OrderOpenedDateTime AS OrderOpenedDateTime1,BillNo AS BillNo1 FROM #OrderTimingReport ORDER BY '+@R_SortingColumn+' '+@R_SortingDirection+',OrderOpenedDateTime1 desc,BillNo1 asc OFFSET ('+CAST(@R_PageNumber-1 AS NVARCHAR(MAX))+')*'+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS FETCH NEXT '+CAST(@R_PageSize AS NVARCHAR(MAX))+' ROWS ONLY';
			EXEC(@SortingCmd);
		END
	END

	SELECT AVG(CAST(DurationMinutes AS DECIMAL(18,2))) AS DurationMinutes, SUM(NetTotal) AS NetTotal FROM #OrderTimingReport WHERE DurationMinutes IS NOT NULL;

	IF Object_id('TempDB.dbo.#OrderTimingReport') IS NOT NULL DROP TABLE #OrderTimingReport;
	IF Object_id('TempDB.dbo.#OrderTimingReportCount') IS NOT NULL DROP TABLE #OrderTimingReportCount;
	SET NOCOUNT OFF;
END
GO
PRINT 'Created or altered SP Report_OrderTimingPaging.';
GO

PRINT 'Section AC complete.';
GO
