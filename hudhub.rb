require './init'

get '/' do

end

post '/:github_token' do
  Hudhub.process_github_hook(params[:github_token], params[:payload])
end

