SELECT d. name
  , m .name
  , m .physical_name
  , m .size * 8
  , m .[type]
  FROM sys.master_files m
  INNER JOIN sys .databases d
    ON m .database_id = d.database_id
  ORDER BY 1
  , 2
  