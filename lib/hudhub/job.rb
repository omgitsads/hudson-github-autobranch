class Hudhub
  class Job
    class Http
      include HTTParty

      base_uri Hudhub.config.hudson_url
      basic_auth(Hudhub.config.username, Hudhub.config.password) if Hudhub.config.username
      headers 'Content-type' => 'text/xml'
      # I get timeout errors on heroku but not on local env. Is that because of REE-1.8.7 ?
      # Workaround: Set the timeout to 10 seconds and rescue timeout errors.
      default_timeout 8
    end

    def self.find_or_create_copy(base_name, branch)
      job_name = name_for_branch(base_name, branch)

      if job = Job.find(job_name)
        return job
      end

      log "Job #{job_name} does not exists for branch #{branch}. Creating it..."
      base_job = Job.find(base_name)
      raise "Base job #{base_name} does not exists!" unless base_job

      Job.copy!(base_job, branch)
    end

    def self.find(job_name)
      url = "/job/#{job_name}/config.xml"
      response = Http.get(url)
      case response.code
      when 200
        Job.new(job_name, response.response.body)
      when 404
        nil
      when 401
        raise AuthenticationFailed
      else
        log "Error while getting '#{url}'"
        raise response.response
      end
    end

    # Creates a new job using the configuration of the :based_job for the given :branch
    def self.copy!(base_job, branch)
      log "Copying #{base_job.name} to #{name_for_branch(base_job.name, branch)}"
      job = base_job.clone
      job.update_branch!(branch)

      url = "/createItem?name=#{job.name}"
      response = Http.post(url, :body => job.data)

      unless response.code == 200
        log "Error while posting '#{url}'"
        log response.parsed_response
        raise response.response
      end

      job
    end

    def self.delete!(base_name, branch)
      job_name = name_for_branch(base_name, branch)
      log "Deleting '#{job_name}'"
      url = "/job/#{job_name}/doDelete"
      Http.post(url)
    end

    # Substitute master by the branch name.
    # If master is not part of the base_job_name we append the branch name.
    def self.name_for_branch(base_name, branch)
      if base_name["master"]
        base_name.gsub("master", branch)
      else
        "#{base_name}-#{branch}"
      end
    end

    attr_accessor :name, :data

    def run!
      log "Running #{name}!"
      url = "/job/#{name}/build"

      begin
        response = Http.get(url)
        case response.code
        when 200
          true
        else
          log "Error while getting '#{url}'"
          raise response.response
        end
      rescue Timeout::Error
        log "Timeout... That could happen on heroku deployment. The job should be running however."
        return true
      end
    end

    # Update the name and data for the given branch name
    def update_branch!(branch)
      self.name = Job.name_for_branch(self.name, branch)
      self.data.gsub!(/<name>[^<]+/, "<name>#{branch}")

      self
    end

    protected

    def initialize(name, plain_xml)
      @name = name
      @data = plain_xml
    end

  end # class Job
end # class Hudhub
