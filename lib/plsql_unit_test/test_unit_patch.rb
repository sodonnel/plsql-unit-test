class Test::Unit::TestCase

  # Sets the class instance variable @@db_interface to the
  # object that is passed in
  def self.set_database_interface(interface)
    @@db_interface = interface
  end

  # Used to assert / test a given table has only a single row.
  # If a where clause is passed, it should start with 'where'. The table
  # name and where clause are used to form a select statement in the form:
  #
  #    "select count(*) from #{table} #{where_clause}"
  #
  # @example Assert the users table has a single row for user foouser
  #     assert_table_has_one_row('users',
  #                              "where username = 'foouser'",
  #                              "Ensure the users table has a single row")
  #
  # It is possible to pass an array for the where clause, where the first
  # element is the where string with bind placeholders, and the remaining
  # elements are the bind variables:
  #
  # @example Assert the users table has a single row for user foouser
  #     assert_table_has_one_row('users',
  #                              ["where username = ?", 'foouser'],
  #                              "Ensure the users table has a single row")
  #
  def assert_table_has_one_row(table, where_clause=nil, message=nil)
    assert_table_has_many_rows(table, 1, where_clause, message)
  end

  # Used to assert / test a given table has zero rows.
  # If a where clause is passed, it should start with 'where'. The table
  # name and where clause are used to form a select statement in the form:
  #
  #    "select count(*) from #{table} #{where_clause}"
  #
  # @example Assert the users table has zero rows for user foouser
  #     assert_table_has_zero_rows('users',
  #                                "where username = 'foouser'",
  #                                "Ensure the users table has zero rows")
  #
  # It is possible to pass an array for the where clause, where the first
  # element is the where string with bind placeholders, and the remaining
  # elements are the bind variables:
  #
  # @example Assert the users table has a single row for user foouser
  #     assert_table_has_zero_row('users',
  #                              ["where username = ?", 'foouser'],
  #                              "Ensure the users table has zero rows")
  #
  def assert_table_has_zero_rows(table, where_clause=nil, message=nil)
    assert_table_has_many_rows(table, 0, where_clause, message)
  end

  # Used to assert / test a given table has a given number of rows.
  # If a where clause is passed, it should start with 'where'. The table
  # name and where clause are used to form a select statement in the form:
  #
  #    "select count(*) from #{table} #{where_clause}"
  #
  # @example Assert the users table has zero rows for user foouser
  #     assert_table_has_many_rows('users',
  #                                 10
  #                                "where status = 'locked'",
  #                                "Ensure the users table has 10 locked rows")
  #
  # It is possible to pass an array for the where clause, where the first
  # element is the where string with bind placeholders, and the remaining
  # elements are the bind variables:
  #
  # @example Assert the users table has a single row for user foouser
  #     assert_table_has_many_rows('users',
  #                              ["where status = ?", 'locked'],
  #                              "Ensure the users table has 10 locked rows")
  #
  def assert_table_has_many_rows(table, row_count, where_clause=nil, message=nil)
    where = where_clause
    binds = Array.new
    if where_clause and where_clause.is_a? Array
      where = where_clause.shift
      binds = where_clause
    end
    results = @@db_interface.execute_sql("select count(*) from #{table} #{where}", *binds).all_array
    message = build_message(message, "A count of <?> was expected but was <?> for <?> <?>", row_count.to_s, results[0][0].to_i, table, where_clause)
    assert_block(message) do
      row_count == results[0][0].to_i
    end
  end

  # Returns a string representing an Ruby Time object in Oracle to_date
  # format, accurate to a second.
  def time_as_oracle_dtm(time)
    "to_date('#{time.strftime('%Y%m%d %H:%M:%S')}', 'YYYYMMDD HH24:MI:SS')"
  end

  # Returns a string representing an Ruby Time object in Oracle to_date
  # format, accurate to a day.
  def time_as_oracle_dt(time)
    "to_date('#{time.strftime('%Y%m%d')}', 'YYYYMMDD')"
  end

end
