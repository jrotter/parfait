Gem::Specification.new do |s|
  s.name        = 'parfait'
  s.version     = '0.10.0'
  s.date        = '2016-02-15'
  s.summary     = 'Parfait'
  s.description = 'A base set of test operations for verification of web pages and the controls therein'
  s.add_development_dependency "minitest", [">= 0"]
  s.authors     = ["Jeremy Rotter"]
  s.email       = 'jeremy.rotter@gmail.com'
  s.files       = ['lib/parfait.rb',
                   'lib/parfait/application.rb',
                   'lib/parfait/page.rb',
                   'lib/parfait/region.rb',
                   'lib/parfait/control.rb',
                   'lib/parfait/artifact.rb']
  s.homepage    = 'https://github.com/jrotter/parfait'
  s.license     = 'MIT'
end
