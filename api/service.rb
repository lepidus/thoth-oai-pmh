# frozen_string_literal: true

require_relative './client'
require_relative './queries'
require_relative '../oai/mapper/oai_dc'

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

      def records
        response = @client.execute(Thoth::Api::Queries::WORKS_QUERY)
        works = JSON.parse(response.body)['data']['works']
        works.map do |work|
          Thoth::Oai::Mapper::OaiDc.new(work).map
        end
      end

      private

      def fetch_datestamp(direction)
        response = @client.execute(Thoth::Api::Queries::TIMESTAMP_QUERY, { direction: direction })
        JSON.parse(response.body)['data']['works'].first['updatedAtWithRelations']
      end
    end
  end
end
