require 'gig'

ignore_files = %w(
  .gitignore
  bin/c
  Gemfile
  Rakefile.rb
).map { |glob| Dir.glob(glob, File::FNM_DOTMATCH) }.inject([], &:|)

Gig.make_task(gemspec_filename: 'jsi_util_linux.gemspec', ignore_files: ignore_files)
