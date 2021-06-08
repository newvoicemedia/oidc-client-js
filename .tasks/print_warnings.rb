namespace :ci do
  desc 'Print Rakefile.CI warnings'
  task :print_warnings do
    warnings = []
    warnings.push('Could not load statsd-ruby gem!') unless @statsd_gem_loaded
    warnings.push("StatsD host #{@statsd_host} unreachable!") if @statsd_host_unreachable
    warnings.push('Unable to parse Git commit hash!') if @git_commit_hash.nil? || @git_commit_hash.empty?

    warnings.push('VOLTA_NPM_TOKEN not set!') if ENV['VOLTA_NPM_TOKEN'].nil?
    next if warnings.empty?

    puts '>'
    warnings.each { |warning| puts "> #{'Warning:'.yellow} #{warning}" }
    puts
  end
end
