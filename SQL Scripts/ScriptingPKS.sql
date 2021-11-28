DECLARE @object_id int ;
DECLARE @parent_object_id int ;
DECLARE @TSQL NVARCHAR (4000);
DECLARE @COLUMN_NAME SYSNAME ;
DECLARE @is_descending_key bit ;
DECLARE @col1 BIT ;
DECLARE @action CHAR (6);
 
--SET @action = 'DROP';
SET @action = 'CREATE';
 
DECLARE PKcursor CURSOR FOR
    select kc .object_id, kc.parent_object_id
    from sys.key_constraints kc
    inner join sys .objects o
    on kc .parent_object_id = o.object_id
    where kc .type = 'PK' and o .type = 'U'
    and o .name not in ('dtproperties', 'sysdiagrams')  -- not true user tables
        AND o. [object_id] = object_ID('[dbo].[ASPStateTempSessions]' )
    order by QUOTENAME (OBJECT_SCHEMA_NAME( kc.parent_object_id ))
            ,QUOTENAME( OBJECT_NAME(kc .parent_object_id));
 
OPEN PKcursor;
FETCH NEXT FROM PKcursor INTO @object_id, @parent_object_id;
 
WHILE @@FETCH_STATUS = 0
BEGIN
    IF @action = 'DROP'
        SET @TSQL = 'ALTER TABLE '
                  + QUOTENAME (OBJECT_SCHEMA_NAME( @parent_object_id))
                  + '.' + QUOTENAME(OBJECT_NAME (@parent_object_id))
                  + ' DROP CONSTRAINT ' + QUOTENAME(OBJECT_NAME (@object_id))
    ELSE
        BEGIN
        SET @TSQL = 'ALTER TABLE '
                  + QUOTENAME (OBJECT_SCHEMA_NAME( @parent_object_id))
                  + '.' + QUOTENAME(OBJECT_NAME (@parent_object_id))
                  + ' ADD CONSTRAINT ' + QUOTENAME(OBJECT_NAME (@object_id))
                  + ' PRIMARY KEY'
                  + CASE INDEXPROPERTY( @parent_object_id
                                      ,OBJECT_NAME( @object_id),'IsClustered' )
                        WHEN 1 THEN ' CLUSTERED'
                        ELSE ' NONCLUSTERED'
                    END
                  + ' (' ;
 
        DECLARE ColumnCursor CURSOR FOR
            select COL_NAME (@parent_object_id, ic.column_id ), ic. is_descending_key
            from sys .indexes i
            inner join sys. index_columns ic
            on i. object_id = ic.object_id and i .index_id = ic.index_id
            where i. object_id = @parent_object_id
            and i. name = OBJECT_NAME(@object_id )
            order by ic.key_ordinal ;
 
        OPEN ColumnCursor;
 
        SET @col1 = 1;
 
        FETCH NEXT FROM ColumnCursor INTO @COLUMN_NAME, @is_descending_key;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF (@col1 = 1)
                SET @col1 = 0
            ELSE
                SET @TSQL = @TSQL + ',';
 
            SET @TSQL = @TSQL + QUOTENAME(@COLUMN_NAME )
                      + ' '
                      + CASE @is_descending_key
                            WHEN 0 THEN 'ASC'
                            ELSE 'DESC'
                        END;
 
            FETCH NEXT FROM ColumnCursor INTO @COLUMN_NAME, @is_descending_key;
        END;
 
        CLOSE ColumnCursor;
        DEALLOCATE ColumnCursor;
 
        SET @TSQL = @TSQL + ')';
 
        END;
 
        SET @TSQL = @TSQL + ';'
    PRINT @TSQL ;
 
    FETCH NEXT FROM PKcursor INTO @object_id , @parent_object_id;
END;
 
CLOSE PKcursor;
DEALLOCATE PKcursor;

USE [ASPState]

SELECT *   
FROM [INFORMATION_SCHEMA]. [COLUMNS] AS c
        INNER JOIN [INFORMATION_SCHEMA].[TABLES] AS t
               ON [c]. [TABLE_CATALOG]      = [t]. [TABLE_CATALOG]
         and  [c]. [TABLE_SCHEMA]  = [t] .[TABLE_SCHEMA]
         and  [c]. [TABLE_NAME]            = [t]. [TABLE_NAME]
WHERE [t]. [TABLE_TYPE] LIKE 'base%'
AND [c]. [DATA_TYPE] LIKE '%char'
  