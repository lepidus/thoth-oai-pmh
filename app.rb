require_relative 'oai/provider'
require 'sinatra'

configure do
  set :oai_provider, ThothOAI::Provider.new
end

get '/' do
  redirect '/oai'
end

get '/oai' do
  content_type 'application/xml; charset=utf-8'
  response = settings.oai_provider.process_request(params)
end
