lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pronto/findbugs/version'

Gem::Specification.new do |spec|
  spec.name          = 'pronto-findbugs'
  spec.version       = Pronto::Findbugs::VERSION
  spec.authors       = ['Seiichi KONDO']
  spec.email         = ['seikichi@kmc.gr.jp']

  spec.summary       = 'Pronto runner for findbugs / spotbugs'
  spec.description   = <<-DESCRIPTION
    A pronto runner for findbugs and spotbugs.
    Pronto runs analysis quickly by checking only the relevant changes.
    Created to be used on pull requests, but suited for other scenarios as well.
  DESCRIPTION
  spec.homepage      = 'https://github.com/seikichi/pronto-findbugs'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0.62'
  spec.add_development_dependency 'test-unit', '~> 3.2.8'
end
