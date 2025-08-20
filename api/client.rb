# frozen_string_literal: true

require 'faraday'

module Thoth
  module Api
    # Client class for interacting with the Thoth GraphQL API
    class Client
      def execute_query(query, variables = {})
        uri = 'https://api.thoth.pub/graphql'
        params = { query: query, variables: variables }.to_json
        headers = { 'Content-Type' => 'application/json' }

        Faraday.post(uri, params, headers)
      end

      def send_request(specification_id, work_id)
        uri = "https://export.thoth.pub/specifications/#{specification_id}/work/#{work_id}"
        headers = { 'Content-Type' => 'text/xml' }

        Faraday.get(uri, nil, headers)
      end
    end
  end
end
