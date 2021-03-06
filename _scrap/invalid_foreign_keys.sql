-- 
-- Foreign keys on MyISAM tables; on differing types
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW invalid_foreign_keys AS
  SELECT 
    KEY_COLUMN_USAGE.TABLE_SCHEMA,
    KEY_COLUMN_USAGE.TABLE_NAME,
    KEY_COLUMN_USAGE.CONSTRAINT_NAME,
    CONCAT(
      'ALTER TABLE `', KEY_COLUMN_USAGE.TABLE_SCHEMA, '`.`', KEY_COLUMN_USAGE.TABLE_NAME, 
      '` ADD CONSTRAINT `', KEY_COLUMN_USAGE.CONSTRAINT_NAME, 
      '` FOREIGN KEY (', GROUP_CONCAT(CONCAT('`', KEY_COLUMN_USAGE.COLUMN_NAME, '`') ORDER BY KEY_COLUMN_USAGE.ORDINAL_POSITION), ')', 
      ' REFERENCES `', KEY_COLUMN_USAGE.REFERENCED_TABLE_SCHEMA, '`.`', KEY_COLUMN_USAGE.REFERENCED_TABLE_NAME, 
      '` (', GROUP_CONCAT(CONCAT('`', KEY_COLUMN_USAGE.REFERENCED_COLUMN_NAME, '`')), ')',
      ' ON DELETE ', REFERENTIAL_CONSTRAINTS.DELETE_RULE, 
      ' ON UPDATE ', REFERENTIAL_CONSTRAINTS.UPDATE_RULE
    ) AS create_statement,
    GROUP_CONCAT(CONCAT(referencing_columns.data_type, IF(LOCATE('unsigned', referencing_columns.COLUMN_TYPE) > 0, ' unsigned', ''))) as ref_types,
    GROUP_CONCAT(referenced_columns.column_type) as refd_types
  FROM 
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
    INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS USING(CONSTRAINT_SCHEMA, CONSTRAINT_NAME)
    INNER JOIN INFORMATION_SCHEMA.TABLES AS referencing_table 
      ON (
        referencing_table.TABLE_SCHEMA = KEY_COLUMN_USAGE.TABLE_SCHEMA 
        AND referencing_table.TABLE_NAME = KEY_COLUMN_USAGE.TABLE_NAME
      )
    INNER JOIN INFORMATION_SCHEMA.TABLES AS referenced_table 
      ON (
        referenced_table.TABLE_SCHEMA = KEY_COLUMN_USAGE.REFERENCED_TABLE_SCHEMA 
        AND referenced_table.TABLE_NAME = KEY_COLUMN_USAGE.REFERENCED_TABLE_NAME
      )
    INNER JOIN INFORMATION_SCHEMA.COLUMNS AS referencing_columns 
      ON (
        referencing_columns.TABLE_SCHEMA = KEY_COLUMN_USAGE.TABLE_SCHEMA 
        AND referencing_columns.TABLE_NAME = KEY_COLUMN_USAGE.TABLE_NAME 
        AND referencing_columns.COLUMN_NAME = KEY_COLUMN_USAGE.COLUMN_NAME
      )
    INNER JOIN INFORMATION_SCHEMA.COLUMNS AS referenced_columns 
      ON (
        referenced_columns.TABLE_SCHEMA = KEY_COLUMN_USAGE.REFERENCED_TABLE_SCHEMA 
        AND referenced_columns.TABLE_NAME = KEY_COLUMN_USAGE.REFERENCED_TABLE_NAME 
        AND referenced_columns.COLUMN_NAME = KEY_COLUMN_USAGE.REFERENCED_COLUMN_NAME
      )
  WHERE 
    KEY_COLUMN_USAGE.REFERENCED_TABLE_SCHEMA IS NOT NULL
    and KEY_COLUMN_USAGE.table_schema='test'
  GROUP BY
    KEY_COLUMN_USAGE.TABLE_SCHEMA, 
      KEY_COLUMN_USAGE.TABLE_NAME, 
      KEY_COLUMN_USAGE.CONSTRAINT_NAME
;

