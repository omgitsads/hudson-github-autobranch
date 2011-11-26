require './init'

class Hudhub
  class Rackapp < Sinatra::Base
    get '/' do

    end

    post '/github/:github_token' do
      Hudhub.process_github_hook(params[:github_token], params[:payload])
    end

    get '/hubot/:hubot_token' do
      Hudhub.process_hubot_request(params[:hubot_token], params[:branch])
    end
  end
end
