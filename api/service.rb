# frozen_string_literal: true

require_relative './client'

module Thoth
  module Api
    # Service class for Thoth API interactions
    class Service
      def initialize(client = Thoth::Api::Client.new)
        @client = client
      end

      def latest
        fetch_datestamp('DESC')
      end

      def earliest
        fetch_datestamp('ASC')
      end

      private

      def fetch_datestamp(direction)
        query = <<~GRAPHQL
          query {
            works(
              order: {field: UPDATED_AT_WITH_RELATIONS, direction: #{direction}}
              workStatuses: [ACTIVE]
              limit: 1
            ) {
              updatedAtWithRelations
            }
          }
        GRAPHQL

        response = @client.execute(query)
        JSON.parse(response.body)['data']['works'].first['updatedAtWithRelations']
      end
    end
  end
end
