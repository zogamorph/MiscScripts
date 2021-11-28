SELECT  OBJECT_NAME ([o]. [object_id]) AS ObjectName
      , [i]. [Name] AS IndexName
      , [i]. [index_id] AS IndexID
      , [i]. [type_desc] AS IndexType
      , [p]. [Rows]
      , [a]. [type_desc]
      , [a]. [total_pages]
      , [a]. [first_page]
      , [a]. [root_page]
      , [a]. [first_iam_page]
FROM    [sys]. [objects] AS o
INNER JOIN [sys].[indexes] i
        ON [i]. [object_id] = [o] .[object_id]
INNER JOIN [sys].[partitions] p
        ON [i]. [object_id] = [p] .[object_id]
           AND [i]. [index_id] = [p] .[index_id]
INNER JOIN [sys].[system_internals_allocation_units] a
        ON [p]. [partition_id] = [a] .[container_id]
WHERE   [p]. [index_id] < 2
        AND [o]. [type] = 'u'
        AND [a]. [type_desc] = 'IN_ROW_DATA'
ORDER BY [p].[rows] DESC