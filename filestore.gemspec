Gem::Specification.new do |s|
  s.name        = 'filestore'
  s.version     = '0.0.2'
  s.date        = '2012-11-22'
  s.summary     = "Simple file storage"
  s.description = "Organizes a file storage using the file system and some meta data"
  s.authors     = ["Thomas Stätter"]
  s.email       = 'thomas.staetter@gmail.com'
  s.files       = ["lib/filestore.rb", "lib/memory_meta.rb", "lib/log.rb", "lib/meta_manager.rb", "lib/multitenant_filestore.rb"]
  s.test_files	= ["test/tc_filestore.rb", "test/tc_multitenant.rb"]
  s.homepage    = 'https://www.xing.com/profile/thomas.staetter'
  s.required_ruby_version = '>= 1.9.3'
  s.requirements << 'gem uuidtools, log4r'
  s.add_runtime_dependency 'uuidtools', '~> 2.1.2', '>= 2.0'
  s.add_runtime_dependency 'log4r', '~> 1.1.10', '>= 1.0'
end