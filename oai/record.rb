# frozen_string_literal: true

require 'oai'
require_relative '../api/service'
require_relative 'mapper/oai_dc'
require_relative 'mapper/oai_openaire'

module Thoth
  module Oai
    # Thoth OAI-PMH record
    class Record
      attr_accessor :json_record

      def initialize(json_record)
        @json_record = json_record
      end

      def id
        @json_record['workId']
      end

      def updated_at
        Time.parse(@json_record['updatedAtWithRelations'])
      end

      def sets
        publisher_name = @json_record.dig('imprint', 'publisher', 'publisherName')
        spec = publisher_name.downcase.gsub(/[^\w\s]/, '').gsub(' ', '-')
        OAI::Set.new(spec: spec, name: publisher_name)
      end

      def to_oai_dc
        Thoth::Oai::Mapper::OaiDc.new(@json_record).map
      end

      def to_oai_openaire
        Thoth::Oai::Mapper::OaiOpenaire.new(@json_record).map
      end

      def to_marcxml
        marcxml = Thoth::Api::Service.new.get_marcxml(id)

        raise OAI::FormatException unless marcxml

        marcxml
      end
    end
  end
end
