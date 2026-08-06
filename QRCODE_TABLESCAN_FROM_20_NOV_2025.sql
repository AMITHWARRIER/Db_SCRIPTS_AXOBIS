/*** SCRIPTS TO IMPLEMENT TABLE QR CODE PAYMENT ***/

CREATE TABLE R_QRTableMap
(
    QrGUID UNIQUEIDENTIFIER PRIMARY KEY,
    TableID UNIQUEIDENTIFIER NOT NULL,
    SectionID UNIQUEIDENTIFIER NOT NULL,
    IsActive BIT DEFAULT 1
)
GO

CREATE PROCEDURE restaurant.GetQRBill 
    @QrGUID UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    -- 🔐 Step 1: Get Table + Section from QR
    DECLARE @TableID UNIQUEIDENTIFIER, @SectionID UNIQUEIDENTIFIER;

    SELECT @TableID = TableID, @SectionID = SectionID
    FROM R_QRTableMap 
    WHERE QrGUID = @QrGUID AND IsActive = 1;

    IF (@TableID IS NULL)
    BEGIN
        SELECT 'INVALID_QR' AS Status;
        RETURN;
    END

    -- 🔍 Step 2: Get Unsettled Bill
    SELECT TOP 1 
        SM.GUID AS BillID,
        SM.[No] AS BillNo,
        SM.TableID,
        SM.SectionID,
        SM.Total AS SubTotal,
        SM.Tax,
        (SM.Total + SM.Tax) AS GrandTotal,
        ST.Name AS TableName
    INTO #BillData
    FROM R_SalesMaster SM
    LEFT JOIN R_SectionTables ST ON ST.GUID = SM.TableID
    WHERE SM.TableID = @TableID 
        AND SM.SectionID = @SectionID
        AND SM.IsPending = 1
        AND SM.IsSettled = 0
        AND SM.Cancelled = 0
        AND SM.Deleted = 0
    ORDER BY SM.[No] DESC;

    IF NOT EXISTS (SELECT 1 FROM #BillData)
    BEGIN
        SELECT 'NO_ACTIVE_BILL' AS Status;
        RETURN;
    END

    DECLARE @MasterID UNIQUEIDENTIFIER;
    SELECT @MasterID = BillID FROM #BillData;

    -- 🍽 Step 3: Fetch Bill Items (Clean output)
    SELECT 
        P.Name AS ItemName,
        SD.Quantity,
        SD.UnitRate AS Price,
        (SD.Quantity * SD.UnitRate) AS LineTotal
    FROM R_SalesDetail SD
    INNER JOIN R_Product P ON P.GUID = SD.ProductID
    WHERE SD.MasterID = @MasterID AND SD.Deleted = 0;

    -- 💵 Step 4: Final totals
    SELECT 
        BillNo,
        TableName,
        SubTotal,
        Tax,
        GrandTotal,
        'PENDING_PAYMENT' AS Status
    FROM #BillData;
END;
