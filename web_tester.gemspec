Gem::Specification.new do |s|
  s.name        = 'web_tester'
  s.version     = '0.0.1'
  s.date        = '2015-01-23'
  s.summary     = 'WebTester'
  s.description = 'A base set of test operations for verification of web pages and the controls therein'
  s.add_development_dependency "minitest", [">= 0"]
  s.authors     = ["Jeremy Rotter"]
  s.email       = 'jeremy.rotter@gmail.com'
  s.files       = ['lib/web_tester.rb','lib/web_tester/page.rb','lib/web_tester/control.rb']
  s.homepage    = ''
  s.license     = 'MIT'
end
