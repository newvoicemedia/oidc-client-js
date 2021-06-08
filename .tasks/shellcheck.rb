namespace :ci do
  desc 'Run shellcheck'
  task :shellcheck do
    check_files = Dir.glob('**/*.sh').sort
    ignore_paths = %w[artifacts/]
    ignore_paths.each { |path| check_files -= Dir.glob(path) }

    cwd = Dir.pwd
    if ENV['DOCKER_TOOLBOX_INSTALL_PATH'] && Gem.win_platform?
      cwd = Dir.pwd.gsub('\\', '/').to_s
      letter = cwd.match(/^([a-zA-Z]):/) { |m| m[1].downcase }
      cwd = cwd.gsub(/^([a-zA-Z]):/, "/#{letter}")
    end

    puts "Checking #{check_files.length} Shell Script files ...\n"

    check_errors = 0
    check_files.sort.each do |f|
      system("docker run --rm -v \"#{cwd}:/mnt\" 662182053957.dkr.ecr.eu-west-1.amazonaws.com/docker-vendored-images/shellcheck:0.7.0-b1 #{f}")
      # rubocop:disable Style/SpecialGlobalVars
      check_errors += 1 unless $?.success?
      # rubocop:enable Style/SpecialGlobalVars
    end

    puts "\n#{check_errors} ShellCheck error(s) found!\n" if check_errors.positive?
    exit 1 if check_errors.positive?
    puts "Done.\n"
  end
end
