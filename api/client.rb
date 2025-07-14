# frozen_string_literal: true

require 'faraday'

module Thoth
  module Api
    # Client class for interacting with the Thoth GraphQL API
    class Client
      def initialize
        @conn = Faraday.new(
          url: 'https://api.thoth.pub/graphql',
          headers: { 'Content-Type' => 'application/json' }
        )
      end

      def execute(query, variables = {})
        @conn.post('', { query: query, variables: variables }.to_json)
      end
    end
  end
end
