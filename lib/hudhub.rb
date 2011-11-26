%w(processor github hubot exceptions config job).each do |file|
  require File.join(File.dirname(__FILE__), 'hudhub', file)
end

class Hudhub
  def self.process_github_hook(github_token, github_payload)
    Hudhub::Github.new(github_token, github_payload).process
  end

  def self.process_hubot_request(hubot_token, branch)
    Hudhub::Hubot.new(hubot_token, branch).process
  end
end
