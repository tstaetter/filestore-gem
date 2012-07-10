Gem::Specification.new do |s|
  s.name        = 'filestore'
  s.version     = '0.0.2'
  s.date        = '2012-07-11'
  s.summary     = "Simple file storage"
  s.description = "Organizes a file storage using the file system and some meta data"
  s.authors     = ["Thomas Stätter"]
  s.email       = 'thomas.staetter@gmail.com'
  s.files       = ["lib/filestore.rb", "lib/action.rb", "lib/log.rb", "lib/meta.rb"]
  s.test_files	= ["test/ts_gem.rb", "test/tc_action.rb", "test/tc_log.rb", "test/tc_meta.rb", 
  	"test/tc_filestore.rb", "test/move_from", "test/move_from/test-file-to-move"]
  s.homepage    = 'https://www.xing.com/profile/thomas.staetter'
  s.required_ruby_version = '>= 1.9.3'
  s.requirements << 'gem uuidtools'
  s.add_runtime_dependency 'uuidtools', '~> 2.1.2', '>= 2.0'
end