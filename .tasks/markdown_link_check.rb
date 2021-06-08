namespace :ci do
  desc 'Run markdown_link_check utility'
  task :markdown_link_check do
    check_files = Dir.glob('**/*.md').sort
    ignore_paths = %w[artifacts/]
    ignore_paths.each { |path| check_files -= Dir.glob(path) }

    cwd = Dir.pwd
    if ENV['DOCKER_TOOLBOX_INSTALL_PATH'] && Gem.win_platform?
      cwd = Dir.pwd.gsub('\\', '/').to_s
      letter = cwd.match(/^([a-zA-Z]):/) { |m| m[1].downcase }
      cwd = cwd.gsub(/^([a-zA-Z]):/, "/#{letter}")
    end

    puts "Checking #{check_files.length} Markdown files ...\n"

    config_file = ''
    config_file = ' -c markdown-link-check.json' if File.exist?('markdown-link-check.json')
    check_errors = 0

    check_files.sort.each do |f|
      # rubocop:disable Layout/LineLength
      system("docker run --rm -v \"#{cwd}:/directory\" -w /directory 662182053957.dkr.ecr.eu-west-1.amazonaws.com/docker-vendored-images/markdown-link-check:3.8.1-b1 #{f} -p#{config_file}")
      # rubocop:enable Layout/LineLength
      # rubocop:disable Style/SpecialGlobalVars
      check_errors += 1 unless $?.success?
      # rubocop:enable Style/SpecialGlobalVars
    end

    puts "\n#{check_errors} markdown_link_check error(s) found!\n" if check_errors.positive?
    exit 1 if check_errors.positive?
    puts "Done.\n"
  end
end
