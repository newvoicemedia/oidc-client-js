# rubocop:disable Metrics/BlockLength
namespace :docker do
  desc 'Dump logs from current project Docker services'
  task :dump_logs do
    services_list = `docker-compose ps --services`.split("\n").reject { |service| service.start_with?('WARNING') }
    # Ensure we have artifacts folder in case no packaging occurred.
    FileUtils.mkdir(@artifacts_dir) unless Dir.exist?(@artifacts_dir)

    services_list.each do |service|
      sh("docker-compose logs --no-color -t #{service} > artifacts/container.#{service}.log")
    rescue StandardError => _e
      puts "#{'Warning:'.yellow} Could not save Docker logs for #{service}!"
    end
  rescue StandardError => _e
    puts "#{'Warning:'.yellow} Could not save Docker logs!"
  end

  desc 'Login to development ECR'
  task :login_to_ecr do
    puts '> Checking for AWS developmentaws Profile'
    system('aws configure --profile developmentaws list')
    # rubocop:disable Layout/LineLength
    raise 'Missing AWS developmentaws profile please visit this site how to add a new profile: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html' unless $CHILD_STATUS.exitstatus.zero?

    # rubocop:enable Layout/LineLength

    puts '> Auto-login to AWS ECR...'
    stdout_str, stderr_str, status = command_exec('aws --version')
    raise "Unable to identify AWS CLI version:\n\n#{stderr_str}" unless status.exitstatus.zero?

    if stdout_str.include?('aws-cli/1.')
      login_command = `aws ecr get-login --region eu-west-1 --no-include-email --profile developmentaws`.chomp
      `#{login_command}`
    else
      `aws ecr get-login-password --region eu-west-1 --profile developmentaws | docker login --username AWS --password-stdin https://662182053957.dkr.ecr.eu-west-1.amazonaws.com/`
    end

    raise 'ECR login failed!' unless $CHILD_STATUS.exitstatus.zero?

    puts '> ECR login successful.'
  end

  desc 'Validade Docker Compose files'
  task :validate_compose_files do
    puts '> Validating compose files'
    puts ">   #{ENV['COMPOSE_FILE'] || compose_path}"
    sh('docker-compose config -q')
  end

  private

  def command_exec(command)
    stdout_str, stderr_str, status = Open3.capture3(command)

    # Some binaries like aws, java and python (v2 at least) have a strange behaviour:
    #  - successful command execution, status code 0
    #  - stderr is swapped with stdout
    #
    # We need to observe this on other OSs - might be just a Dardwin issue.
    stdout_str = stderr_str if status.exitstatus.zero? && !stderr_str.empty?

    [stdout_str, stderr_str, status]
  rescue StandardError
    [nil, 'Unknown error', 1]
  end
end
# rubocop:enable Metrics/BlockLength
