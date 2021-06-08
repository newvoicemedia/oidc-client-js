def pretty_duration(milliseconds)
  return '' unless milliseconds

  hours, milliseconds   = milliseconds.divmod(1000 * 60 * 60)
  minutes, milliseconds = milliseconds.divmod(1000 * 60)
  seconds, milliseconds = milliseconds.divmod(1000)

  output = ''
  output << "#{hours}h" unless hours.zero?
  output << "#{minutes}m" unless minutes.zero?
  output << "#{seconds}s" unless seconds.zero?
  output << "#{milliseconds}ms" unless milliseconds.zero?
  output
end

def result_and_metrics(stage_name, stage, start_time, failed)
  duration = (Time.now.to_f - start_time) * 1000
  puts "> #{stage_name} #{failed ? 'FAILED' : 'completed'} after #{pretty_duration(duration)}"

  return if @statsd_client.nil?

  @statsd_client.timing("build,project=#{@build_metric_id},stageName=#{stage_name},stage=#{stage},result=#{failed ? 'failure' : 'success'}", duration)
end

# Regular docker-compose operations will load .env COMPOSE_FILE defined values.
# For Rakefile.CI we only load CI safe compose files. For more on CLI usage with
# Docker Compose and what is supported read: https://git.io/JqZuP
def compose_path
  path = ''
  path << 'docker-compose.ci.yml;' if File.exist?('./docker-compose.ci.yml')
  path << 'docker-compose.ci.user.yml;' if File.exist?('./docker-compose.ci.user.yml')
  path << 'docker-compose.test.yml;' if File.exist?('./docker-compose.test.yml')
  path << 'docker-compose.test.db.yml;' if File.exist?('./docker-compose.test.db.yml')
  path << 'docker-compose.e2e.yml;' if File.exist?('./docker-compose.e2e.yml')
  path.chomp(';')
end

def trap_unset_environment_variable(name)
  return if ENV[name]

  compose_path.split(';').each do |compose_file|
    next unless File.readlines(compose_file).grep(/\$\{#{name}\}/).size.positive?

    raise "#{name} is not set, required by #{compose_file}"
  end
end

def trap_missing_artifactory_credentials
  return unless ENV['ARTIFACTORY_USER'].nil? || ENV['ARTIFACTORY_SECRET'].nil?

  puts 'Missing Artifactory credentials! Visit: https://git.io/Jk6q1.'
  exit 1
end
