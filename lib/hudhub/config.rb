class Hudhub::Config
  def initialize
    path = File.join(File.dirname(__FILE__), '..', '..', CONFIG_FILE)
    @config = YAML.load_file(path)
  end

  def github_token
    @config['github_token']
  end

  def hudson_url
    @config['hudson_url']
  end

  def base_jobs
    ([@config['base_job']] + (@config['base_jobs'] || [])).uniq.compact
  end

  def username
    @config['username']
  end

  def password
    @config['password']
  end
end # Class Config
