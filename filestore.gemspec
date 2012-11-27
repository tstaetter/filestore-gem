Gem::Specification.new do |s|
  s.name        = 'filestore'
  s.version     = '0.0.6'
  s.date        = '2012-11-27'
  s.summary     = "Simple file storage"
  s.description = "Organizes a file storage using the file system and some meta data"
  s.authors     = ["Thomas Stätter"]
  s.email       = 'thomas.staetter@gmail.com'
  s.files       = ["filestore.rb", "lib/filestore.rb", "lib/memory_meta.rb", "lib/log.rb", "lib/meta_manager.rb", "lib/multitenant_filestore.rb"]
  s.test_files	= ["test/tc_filestore.rb", "test/tc_multitenant.rb", "test/multi_store_test", "test/store_test", "test/testfile.txt"]
  s.homepage    = 'https://github.com/tstaetter/filestore-gem'
  s.required_ruby_version = '>= 1.9.3'
  s.requirements << 'gem uuidtools, log4r'
  s.add_runtime_dependency 'uuidtools', '~> 2.1.2', '>= 2.0'
  s.add_runtime_dependency 'log4r', '~> 1.1.10', '>= 1.0'
end