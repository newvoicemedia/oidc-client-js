# frozen_string_literal: true

# Auto-generated file by Vonage CLI
# Skeleton rakefile based on service configuration and runtimes that should cover majority of use cases
# This file is only created when it is not present, any further customisation is not overwritten when rendering
# If you find further improvements to make the template more generic please contact the
# Engineering Enablement Team (https://confluence.vonage.com/display/ENG/CC+-+Engineering+Enablement+Home).



@version = JSON.parse(File.read('./package.json'))['version']
@build_version = ENV['BUILD_VERSION'] || 'dev'
@project_name = ENV['CI_SERVICE_NAME'] || 'oidc-client-js'
@base_file_name = "#{@project_name}-#{@build_version}"
@artifacts_dir = 'artifacts'

# build ------------------------------------------------------------------------

desc 'Build using yarn'
task :build do
  sh 'yarn build'
end



