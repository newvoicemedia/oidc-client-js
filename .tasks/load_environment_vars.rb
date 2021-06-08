@statsd_host = ENV['CI_STATSD_HOST'] || 'NVMDEV-WS20.dev.newvoicemedia.com'
@statsd_port = ENV['CI_STATSD_PORT'] || 8125
@statsd_host_unreachable = false
@statsd_client = nil
@build_metric_id = nil
@statsd_gem_loaded = false
begin
  require 'statsd'
  @statsd_gem_loaded = true
rescue LoadError
  # Fallback mode in case Gem can't be installed
end

VOID_OUTPUT = Gem.win_platform? ? 'NUL' : '/dev/null'

# rubocop:disable Metrics/BlockLength
namespace :ci do
  desc 'Loads provided environment variables and set defaults'
  task :load_environment_vars do
    dev_default_name = 'oidc-client-js'.downcase.tr('.', '-')

    ENV['CI_DOCKER_TAG'] ||= 'dev'
    ENV['CI_DOCKER_IMAGE'] ||= dev_default_name
    ENV['CI_DOCKER_CONTAINER'] ||= dev_default_name

    @build_container_name = ENV['CI_DOCKER_CONTAINER']

    @git_commit_hash = `git rev-parse --verify HEAD 2>#{VOID_OUTPUT}`.chomp
    ENV['GIT_COMMIT_HASH'] = @git_commit_hash unless @git_commit_hash.empty?

    ENV['PKI_PATH'] = '/etc/pki' if @is_ci

    ENV['COMPOSE_PATH_SEPARATOR'] = ';'
    ENV['COMPOSE_FILE'] ||= compose_path
    ENV['COMPOSE_PROJECT_NAME'] = ENV['CI_DOCKER_CONTAINER']

    # Artifactory
    trap_missing_artifactory_credentials
    ENV['ARTIFACTORY_ADDRESS'] ||= 'vonagecc.jfrog.io/vonagecc'
    ENV['ARTIFACTORY_URL'] ||= 'https://vonagecc.jfrog.io/vonagecc'

    if @statsd_gem_loaded && ENV['TEST'].nil?
      ENV['CI_STATSD_HOST'] = @statsd_host
      ENV['CI_STATSD_PORT'] = @statsd_port.to_s
      @build_metric_id = dev_default_name

      begin
        @statsd_client = Statsd.new(@statsd_host, @statsd_port.to_i).tap { |sd| sd.namespace = 'CI.DockerBuilds' }
      rescue SocketError => _e
        @statsd_client = nil
        @statsd_host_unreachable = true
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
