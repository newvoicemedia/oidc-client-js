# rubocop:disable Metrics/BlockLength
namespace :ci do
  desc 'Sync project MarkDown files to Confluence'
  task :sync_wiki do
    require 'net/http'
    require 'find'
    require 'securerandom'

    puts ''
    puts 'Markdown to Confluence sync...'
    # Get all markdowns in folder & subfolders, but exclude certain directories
    md_file_paths = locate_md_files(Dir.pwd)
    items_to_process = md_file_paths.count

    puts ''
    puts "> Found '#{items_to_process} markdown files to upsert"
    item_number = 1

    md_file_paths.each do |mdfile|
      puts ''
      puts "> Processing file '#{item_number} of '#{items_to_process}"
      puts "> Current file is : '#{mdfile}"
      upsert_markdown_file(mdfile)
      item_number += 1
      puts '>'
    end

    puts
    puts '>'
    puts '> Documentation can be found at : https://confluence.vonage.com/display/systemdocs/CC+-+SystemDocs+Home'
    puts '>'
    puts
  rescue StandardError => e
    # Never break the build because of this.
    puts "Wiki sync failed!\n\n#{e}"
  end

  private

  def locate_md_files(initial_working_dir)
    md_file_paths = []
    ignores = %w[node_modules vendors vendor .vng-data]

    Find.find(initial_working_dir) do |path|
      name = File.basename(path)

      if FileTest.directory?(path)
        next unless ignores.include?(name)

        Find.prune
      elsif path.match(/\.md\Z/)
        md_file_paths.push path
      end
    end

    md_file_paths
  end

  def rel_path(mdfile)
    rel_path = Pathname.new(File.dirname(mdfile)).relative_path_from(Pathname.new(Dir.pwd)).to_s
    return "#{rel_path}/" if rel_path == '.'

    ".//#{rel_path}"
  end

  def upsert_markdown_file(mdfile)
    contents = File.open(mdfile, &:read)
    wikispace = 'systemdocs'
    rootpath = 'oidc-client-js'
    url = "https://c3-markdowntoconfluence.nvminternal.net/home/upsertsinglemarkdown?wikispace=#{wikispace}&filename=#{File.basename(mdfile)}&relativefilepath=#{rel_path(mdfile)}&rootfilepath=#{rootpath}"
    uri = URI(url)

    puts "> invoking HTTP POST: #{uri}"
    req = Net::HTTP::Post.new(uri, { 'X-Correlation-Id' => SecureRandom.uuid })
    req.body = contents
    req.content_type = 'text/plain'
    @response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    puts @response.body
    puts "FAILED TO UPSERT markdown file : '#{File.basename(mdfile)}'" unless @response.code == '200'
  end
end
# rubocop:enable Metrics/BlockLength
