# This task write package definitions file stripping the version out of it
# ensuring that project version changes don't invalidate Docker cache.
namespace :ci do
  desc 'Writes package.cache.json stripping version'
  task :write_cache_package_file do
    next unless File.exist?('package.json')

    require 'json'
    package = JSON.parse(File.read('package.json'))
    package['version'] = '0.0.0'
    File.open('package.cache.json', 'w') do |f|
      f.write(JSON.pretty_generate(package))
    end
  end
end
