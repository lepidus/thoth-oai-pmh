# frozen_string_literal: true

module Thoth
  module Oai
    # Thoth OAI-PMH record
    class Record
      attr_accessor :json_record

      def initialize(json_record)
        @json_record = json_record
      end

      def id
        @json_record[:id]
      end

      def updated_at
        Time.parse(@json_record[:updated_at])
      end
    end
  end
end
