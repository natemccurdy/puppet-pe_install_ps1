require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'


Rake::Task[:lint].clear

PuppetLint.configuration.relative = true
PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"
PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send('disable_class_parameter_defaults')
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
exclude_paths = [
  "bundle/**/*",
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths

desc "Populate CONTRIBUTORS file"
task :contributors do
  system("git log --format='%aN' | sort -u > CONTRIBUTORS")
end

task :metadata do
  sh "metadata-json-lint metadata.json"
end

desc "Run a bunch of tests at once"
task :test => [
  :syntax,
  :lint,
  :spec,
  :metadata,
]

