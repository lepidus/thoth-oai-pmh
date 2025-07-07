# frozen_string_literal: true

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
  response.gsub(
    '<?xml version="1.0" encoding="UTF-8"?>',
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<?xml-stylesheet type=\"text/xsl\" href=\"/oai2.xsl\"?>"
  )
end

get '/oai2.xsl' do
  content_type 'text/xsl; charset=utf-8'

  begin
    File.read(File.join(settings.root, 'assets', 'oai2.xsl'))
  rescue Errno::ENOENT
    status 404
    'XSL stylesheet not found'
  end
end

not_found do
  content_type 'text/html; charset=utf-8'

  <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <title>404 - Page Not Found</title>
      <style>
        body { font-family: Arial, sans-serif; margin: 40px; text-align: center; }
        h1 { color: #666; }
      </style>
    </head>
    <body>
      <h1>404 - Page Not Found</h1>
      <p>The requested page was not found.</p>
      <p><a href="/oai">OAI-PMH Interface</a></p>
    </body>
    </html>
  HTML
end
