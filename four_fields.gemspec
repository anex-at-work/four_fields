$:.push File.expand_path("../lib", __FILE__)
require File.join(File.dirname(__FILE__), 'lib/version')

Gem::Specification.new do |s|
  s.name = 'four_fields'
  s.version = FourFields::VERSION.dup
  s.platform = Gem::Platform::RUBY
  s.summary = 'Simple realization for storage without delete data, and tracking changes.'
  s.email = 'anex.work@gmail.com'
  s.description = 'Simple realization for storage without delete data, and tracking changes.'
  s.author = 'Alex Anzelm'
  
  s.require_paths = ['lib']
  s.files = Dir['lib/**/*.rb']
  s.test_files = Dir['test/**/*.rb']
  
  s.add_dependency 'squeel', '~>1.1'
  s.add_dependency 'devise', '~>3.0'
end
