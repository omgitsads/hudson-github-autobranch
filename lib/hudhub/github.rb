class Hudhub
  class Github < Processor
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
end
