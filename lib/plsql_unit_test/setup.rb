module PLSQLUnitTest
  class Setup

    # Establishes a database connection using the SimpleOracleJDBC::Interface 
    # class. This interface is then passed to both Test::Unit::TestCase
    # and DataFactory::Base using their set_database_interface methods.
    #
    # After calling this method, the class instance variable @@db_interface
    # will be available in all sub-classes of Test::Unit::TestCase and can 
    # be used for database interactions.
    def self.connect(user, password, service, host, port)
      interface = SimpleOracleJDBC::Interface.create(user,
                                                     password,
                                                     service,
                                                     host,
                                                     port
                                                     )

      Test::Unit::TestCase.set_database_interface(interface)
      DataFactory::Base.set_database_interface interface
    end
  end
end	