set @query_script_skip_cleanup := true;
set @query := 'delete from test12.some_table using `test12`.some_table where id < 10';
call _interpret(@query, false);
call _get_split_query_single_table (
   1, 10000, @query_type_supported, @tables_found, @table_schema, @table_name
);

select 
  @query_type_supported = 1
  and @tables_found = 'single' 
  and @table_schema = 'test12'
  and @table_name = 'some_table';
