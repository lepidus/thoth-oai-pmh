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
    end
  end
end
