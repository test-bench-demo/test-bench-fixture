# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = 'TEMPLATE-GEM-NAME'
  s.version = '0.0.0.0'
  s.summary = "Some summary"
  s.description = ' '
  s.homepage = 'TEMPLATE-HOMEPAGE'
  s.license = 'TEMPLATE-LICENSE'

  s.authors = ['Brightworks Digital']
  s.email = 'development@brightworks.digital'

  s.required_ruby_version = ">= 3.0.0"
  s.platform = Gem::Platform::RUBY

  s.metadata['homepage_uri'] = s.homepage
  s.metadata['source_code_uri'] = 'https://github.com/TEMPLATE-GITHUB-ORG/TEMPLATE-REPO-NAME'
  s.metadata['allowed_push_host'] = ENV.fetch('RUBYGEMS_PRIVATE_AUTHORITY')

  s.require_paths = %w(lib)
  s.bindir = 'executables'

  s.executables = Dir.glob('executables/*').map { |executable| File.basename(executable) }

  s.files = Dir.glob('lib/**/*')
end
