# frozen_string_literal: true

# Auto-generated file by Vonage CLI
# Skeleton rakefile based on service configuration and runtimes that should cover majority of use cases
# This file is only created when it is not present, any further customisation is not overwritten when rendering
# If you find further improvements to make the template more generic please contact the
# Engineering Enablement Team (https://confluence.vonage.com/display/ENG/CC+-+Engineering+Enablement+Home).



@artifacts_dir = 'artifacts'

# build ------------------------------------------------------------------------

desc 'Build using yarn'
task :build do
  sh 'yarn build'
  sh 'yarn test'
end

desc 'Package'
task :package do
  puts 'deleting'
  FileUtils.rm_rf(@artifacts_dir)
  puts 'deleted'
  FileUtils.mkdir(@artifacts_dir)
  FileUtils.cp_r("dist/.", "#{@artifacts_dir}/dist/", verbose: true)
  FileUtils.cp_r("lib/.","#{@artifacts_dir}/lib/", verbose: true)
  FileUtils.cp_r("package.json", "#{@artifacts_dir}/.", verbose: true)
end
