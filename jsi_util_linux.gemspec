require_relative "lib/jsi_util_linux/version"

Gem::Specification.new do |spec|
  spec.name = "jsi_util_linux"
  spec.version = JSIUtilLinux::VERSION
  spec.authors = ["Ethan"]
  spec.email = ["ethan@unth.net"]

  spec.summary = "JSI + util-linux"
  spec.description = "util-linux utilities represented with JSI"
  spec.homepage = "https://github.com/notEthan/jsi_util_linux"
  spec.license = "MIT"

  spec.files = [
    'LICENSE.txt',
    'README.md',
    File.basename(__FILE__),
    *Dir['lib/**/*'],
  ].reject { |f| File.lstat(f).ftype == 'directory' }

  spec.require_paths = ["lib"]

  spec.add_dependency("jsi", "~> 0.8")
end
