namespace :ci do
  desc 'Print Rakefile.CI used environment variables'
  task :print_environment_vars do
    puts "\n> Current environment:"
    puts '>'

    %w[
      RUBY_VERSION
      BUILD_VERSION
      GIT_COMMIT_HASH
      PKI_PATH
      COMPOSE_FILE
      COMPOSE_PROJECT_NAME
      CI_STATSD_HOST
      CI_STATSD_PORT
      CI_BUILD_NUMBER
      CI_DOCKER_IMAGE
      CI_DOCKER_CONTAINER
      CI_DOCKER_TAG
    ].each { |variable| puts "> #{variable.ljust(20, ' ')} = #{ENV[variable] || '[not set]'}" }
  end
end
