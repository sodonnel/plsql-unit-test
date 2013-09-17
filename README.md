# PLSQL Unit Test

This gem is intended to be used to test PLSQL code. Most of the test framework is provided by Test::Unit, and this gem simply adds a few convenience methods that are useful when unit testing PLSQL code.

# Dependencies

This gem depends on:

 * [SimpleOracleJDBC](http://rubygems.org/gems/simpleOracleJDBC) to provide a JDBC interface to Oracle
 * [Data_Factory](http://rubygems.org/gems/data_factory) to provide an mechanism for generating test data
 * The Oracle ojdbc6.jar drivers should be in the jruby lib directory

The gem also requires JRuby, mostly because SimpleOracleJDBC requires JRuby. It would be possible to make it run in MRI Ruby, but a different database interface would be required, using perhaps OCI8.

# How to Create a PLSQL Unit Test Suite

## Test Helper

First, create a new directory for the tests. Then create a file called test_helper.rb, it should contain something like the following:

    require 'rubygems'
    require 'plsql_unit_test'
    
    PLSQLUnitTest::Setup.connect('sodonnel',         # user
                                 'sodonnell',        # password
                                 'local11gr2.world', # service
                                 'localhost',        # IP address
                                 '1521')             # port

This code does two things. It loads the plsql\_unit\_test gem (which also requires SimpleOracleJDBC and data_factory), and then establishes a database interface / connection. The database interface is provided by an instance of SimpleOracleJDBC::Interface - check out the documentation of SimpleOracleJDBC to understand how to use it.

This single database interface is shared across all the test classes in the test suite. It is actually stored in a class instance variable called @@db_interface within the Test::Unit::TestCase class.

## Creating a Test

The test framework is all provided by Test::Unit, so tests can be coded in exactly the same way as usual - have a look at the Test::Unit documentation to learn about all the features of Test::Unit. An example of a very simple test is as follows:

    require './test_helper'
    
    class FirstTest < Test::Unit::TestCase
    
      def setup
      end
    
      def teardown
      end
    
      def test_db_connection_works
        query = @@db_interface.execute_sql("select 1 from dual")
        results = query.all_array
    
        assert_equal(1, results.length, 'There should be one row in     the result set')
        assert_equal(1, results[0][0], 'The first and only row in the     result set should contain the value 1') 
      end
    
    end

There are two important points:

 * Notice that the test_helper file is required as the first line of code. This is important as it connects to the database and loads the other required modules.
 * The variable @@db_interface is available for database interactions

## Running a Test

As with simple Test::Unit test suites, tests can be executed by simply passing the test filename to JRuby:

    $ jruby first_test_test.rb
    Run options:
    
    # Running tests:
    
    .
    
    Finished tests in 0.125000s, 8.0000 tests/s, 16.0000 assertions/s.
    
    1 tests, 2 assertions, 0 failures, 0 errors, 0 skips

## Test Runner

Ideally, there should be one Ruby test class for each PLSQL procedure, function or package under test. In a large application there could be many files, so there needs to be a way to run all the tests in the suite. Create a file called test_runner.rb in the same directory as the tests, and put the following code in it:

    current_dir = File.expand_path(File.dirname(__FILE__))
    
    # Find all files that end in _test.rb and require them ...
    files = Dir.entries(current_dir).grep(/^[^#].+_test\.rb$/).sort
    files.each do |f|
      require File.join(current_dir, f)
    end

Now all the test files in the directory can be executed with a single command:

    $ jruby test_runner.rb

For this code to work, all files that contain tests should have filenames that end in _test.rb.

# Additional Methods in Test::Unit::TestCase

PLSQL\_Unit\_Test adds a few extra methods to Test::Unit.

## Assert Methods

When testing database code, it can be useful to ensure a given table has zero, one or a number of rows for a given where clause.

To assert the users table has a single row for the username foouser:

    assert_table_has_one_row("users", 
                             "where username = 'foouser'",
                             "Ensure the users table has a single row")

Similarly, to ensure the users table does not have a row:

    assert_table_has_zero_rows("users", 
                               "where username = 'foouser'",
                               "Ensure the users table zero rows")

Finally, to check a table has a given number of rows:

    assert_table_has_many_rows("users",
                               10 
                               "where status = 'locked'"
                               "Ensure 10 users are locked")

It is also possible to pass an array as the where clause instead of a string. In this case, the first element of the array should be a string containing the where clause with bind variable placeholders. The remaining elements of the array are the bind variables. Ruby types are automatically converted to Oracle types by SimpleOracleJDBC behind the scenes. For example:

    assert_table_has_many_rows("users",
                               10 
                               ["where status = ?", 'locked']
                               "Ensure 10 users are locked")


## Set The Database Interface

An additional class method is available on Test::Unit::TestCase called set_db_interface. This stores the passed in object in @@db_interface. As this is a class variable, it is shared by all classes that sub-class Test::Unit::TestCase.

    Test::Unit::TestCase.set_db_interface(my_db_interface)

## Oracle Dates and Times

Two further helper methods are available to format a Ruby Time object as an Oracle to_date string:

    # Return a string representing the passed in Time object
    # as an Oracle to_date string, down to the second
    def time_as_oracle_dtm(time)
      "to_date('#{time.strftime('%Y%m%d %H:%M:%S')}', 'YYYYMMDD HH24:MI:SS')"
    end

    # Return a string representing the passed in Time object
    # as an Oracle to_date string, down to the day
    def time_as_oracle_dt(time)
      "to_date('#{time.strftime('%Y%m%d')}', 'YYYYMMDD')"
    end

# The Setup Class

The only other class in PLSQL\_Unit\_Test is the setup class, and it contains a single class method:

    def self.connect(user, password, service, host, port)
      # ...
    end

It takes the given parameters, creates an instance of SimpleOracleJDBC and passes it to both Test::Unit::TestCase and DataFactory::Base via their set_database_interface methods.
