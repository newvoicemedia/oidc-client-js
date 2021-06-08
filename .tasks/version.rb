# Based on lib/project/project_extensions.rb version method
def project_version
  require 'json'
  JSON.parse(File.read("#{Dir.pwd}/package.json"))['version']
rescue StandardError => e
  puts "Unable to parse version! Error: #{e}"
  exit 1
end

def build_version
  "#{@version}+#{ENV['CI_BUILD_NUMBER']}"
end

ENV['CI_BUILD_NUMBER'] ||= '0'
@version = project_version
@build_version = build_version
ENV['BUILD_VERSION'] = @build_version

desc 'Project version (ex: 0.2.0)'
task :version do
  puts @version
end

desc 'Return version including appended CI_BUILD_NUMBER (ex: 0.2.0+10)'
task :build_version do
  puts @build_version
end
