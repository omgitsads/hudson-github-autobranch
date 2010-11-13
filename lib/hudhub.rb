class Hudhub
  def self.process_github_hook(github_token, github_payload)
    Hudhub.new(github_token, github_payload).process
  end

  def self.config
    @@config ||= Hudhub::Config.new
  end

  attr_reader :branch

  def config
    self.class.config
  end

  def initialize(github_token, github_payload)
    @github_token = github_token
    @github_payload = JSON.parse(github_payload)
  end

  def process
    check_github_token
    create_hudson_job_if_needed
    run_hudson_job!
  end

  def branch
    @branch ||= @github_payload.delete("ref").split("refs/heads/").last
  end

  protected

  def check_github_token
    raise InvalidGithubToken unless @github_token == config.github_token
  end

  def create_hudson_job_if_needed
    unless job_exists_for_branch?
      create_job_for_branch!
    end
  end

  def job_exists_for_branch?
    !!hudson_job
  end

  def hudson_job
    @job ||= Hudson::Job.find(hudson_job_name)
  end

  def create_job_for_branch!
    Hudson::Job.create!(hudson_job_name, new_job.data)
  end

  def new_job
    @new_job ||= job.clone.update_branch(branch)
  end

  def run_hudson_job!
    Hudson::Job.run!(hudson_job_name)
  end

  # hudson's job name for the branch
  def hudson_job_name
    "#{config.base_job} (#{branch})"
  end

  class InvalidGithubToken < Exception
  end

  class Config
    def initialize
      path = File.join(File.dirname(__FILE__), '..', CONFIG_FILE)
      @config = YAML.load_file(path)
    end

    def github_token
      @config['github_token']
    end

    def hudson_url
      @config['hudson_url']
    end

    def base_job
      @config['base_job']
    end

    def username
      @config['username']
    end

    def password
      @config['password']
    end
  end

  class Hudson
    class Job
      include HTTParty

      base_uri Hudhub.config.hudson_url
      if Hudhub.config.username
        basic_auth Hudhub.config.username, Hudhub.config.password
      end
      headers 'Content-type' => 'text/xml'

      def self.find(job_name)
        url = "/job/#{escape(job_name)}/config.xml"
        response = get(url)
        case response.code
        when 200
          Job.new(response.response.body)
        when 404
          nil
        else
          puts "Error while getting '#{url}'"
          raise response.response
        end
      end

      def self.create!(job_name, job_data)
        url = "/createItem?name=#{escape(job_name)}"
        response = post(url, :body => job_data)
        case response.code
        when 200
          return true
        else
          puts "Error while posting '#{url}'"
          puts response.parsed_response
          raise response.response
        end
      end

      def self.run!(job_name)
        url = "/job/#{escape(job_name)}/build?delay=0sec"
        response = get(url)
        case response.code
        when 200
          true
        else
          puts "Error while getting '#{url}'"
          raise response.response
        end
      end

      # Hudson requires to escape spaces only.
      def self.escape(str)
        str.gsub(' ', '%20')
      end

      attr_reader :data

      def initialize(hash)
        @data = hash
      end

      def update_branch(branch)
        self.data.gsub!(/<name>[^<]+/, "<name>#{branch}")
      end
    end
  end
end
