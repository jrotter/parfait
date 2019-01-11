Gem::Specification.new do |s|
  s.name        = 'parfait'
  s.version     = '0.13.0'
  s.date        = '2019-01-11'
  s.summary     = 'Parfait'
  s.description = 'Parfait uses layers to simplify the creation and maintenance of your web browser test automation.'
  s.add_development_dependency 'minitest', '~> 0'
  s.add_development_dependency 'watir', '~> 6'
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
