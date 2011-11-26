module Hudhub
  class Hubot < Processor
    def process
      check_hubot_token
      config.base_jobs.each do |base_job_name|
        Job.find_or_create_copy(base_job_name, branch).run!
      end
    end

    def branch
      @branch ||= "master"
    end

    protected
    def initialize(hubot_token, branch)
      @hubot_token = hubot_token
      @branch = branch
    end

    def check_hubot_token
      raise InvalidGithubToken unless @hubot_token == config.hubot_token
      log "hubot token is valid"
    end
  end
end

