class Hudhub
  def self.process_github_hook(github_token, github_payload)
    Hudhub.new(github_token, github_payload).process
  end

  def self.config
    @@config ||= Hudhub::Config.new
  end

  def config
    self.class.config
  end

  # 1. Check github token is valid.
  # 2. For each base_jobs:
  #   2.1. find or create a copy of the base_job for the current branch
  #   2.2. run the job
  def process
    check_github_token
    config.base_jobs.each do |base_job_name|
      if branch_deleted?
        Job.delete!(base_job_name, branch)
      else
        Job.find_or_create_copy(base_job_name, branch).run!
      end
    end
  end

  def branch
    @branch ||= @github_payload.delete("ref").split("refs/heads/").last
  end

  def branch_deleted?
    !!@github_payload["deleted"]
  end

  protected

  def initialize(github_token, github_payload)
    @github_token = github_token
    @github_payload = JSON.parse(github_payload)
  end

  def check_github_token
    raise InvalidGithubToken unless @github_token == config.github_token
    log "github token is valid"
  end

end

%w(exceptions config job).each do |file|
  require File.join(File.dirname(__FILE__), 'hudhub', file)
end
