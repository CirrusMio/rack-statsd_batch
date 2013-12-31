Gem::Specification.new do |s|
  s.specification_version = 2
  s.required_rubygems_version = Gem::Requirement.new(">= 0")

  s.name              = 'rack-statsd_batch'
  s.version           = '0.0.1'
  s.date              = '2013-12-13'

  s.summary     = 'Send metrics data to statsd after your request'
  s.description = 'Exposes a metrics collector to the request environment and flushes the data to statsd when the request is finished. Batches the data to send as few packets as possible.'

  s.authors  = ['xtoddx (Todd Willey)']
  s.email    = 'xtoddx@gmail.com'
  s.homepage = 'http://github.com/CirrusMio/rack-statsd_batch'
  s.license  = 'MIT'

  s.require_paths = %w[lib]

  s.add_development_dependency('minitest')

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- tests/*`.split("\n")
end
