Gem::Specification.new do |s|
  s.name        = 'filestore'
  s.version     = '0.0.20'
  s.date        = '2014-02-02'
  s.summary     = "Simple file storage"
  s.description = "Organizes a file storage using the file system and some meta data"
  s.authors     = ["Thomas Stätter"]
  s.email       = 'thomas.staetter@gmail.com'
  s.files       = Dir.glob('lib/**/*.rb')
  s.test_files	= Dir.glob('test/**/*.rb')
  s.homepage    = 'https://github.com/tstaetter/filestore-gem'
  s.required_ruby_version = '>= 1.9.3'
  s.requirements << 'gem uuidtools'
  s.add_runtime_dependency 'uuidtools', '~> 2.1.2', '>= 2.0'
end