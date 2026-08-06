DECLARE @TargetDB SYSNAME = 'DB NAME HERE';
DECLARE @SQL NVARCHAR(MAX);

SET @SQL = '
SET IDENTITY_INSERT ' + QUOTENAME(@TargetDB) + '.dbo.WebMenu ON;

DELETE FROM ' + QUOTENAME(@TargetDB) + '.dbo.WebMenu;

INSERT INTO ' + QUOTENAME(@TargetDB) + '.dbo.WebMenu
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
FROM defaultDB.dbo.WebMenu;

SET IDENTITY_INSERT ' + QUOTENAME(@TargetDB) + '.dbo.WebMenu OFF;
';

EXEC sp_executesql @SQL;