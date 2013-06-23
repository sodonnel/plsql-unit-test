Gem::Specification.new do |s| 
  s.name = "plsql_unit_test"
  s.version = "0.1.1"
  s.author = "Stephen O'Donnell"
  s.email = "stephen@betteratoracle.com"
  s.homepage = "http://betteratoracle.com"
  s.platform = Gem::Platform::RUBY
  s.summary = "A gem that monkey patches Test::Unit::TestCase to add some features to allow unit testing of PLSQL code"
  s.files = (Dir.glob("{test,lib}/**/*") + Dir.glob("[A-Z]*")).reject{ |fn| fn.include? "temp" }

  s.require_path = "lib"
  s.description  = "Monkey patches Test::Unit::TestCase to add some additional assert methods, a global database_interface object (via a class variable) and a few helper functions designed to enable plsql unit testing"
#  s.autorequire = "name"
#  s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.md"]
  s.add_dependency("data_factory", ">=0.1.2")
  s.add_dependency("simpleOracleJDBC", ">=0.1.1")
end
