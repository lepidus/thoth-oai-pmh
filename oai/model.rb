# frozen_string_literal: true

require_relative '../api/service'
require 'oai'
require 'ostruct'

module Thoth
  module Oai
    # Model class for the OAI-PMH provider
    class Model < OAI::Provider::Model
      def initialize
        super
        @service = Thoth::Api::Service.new
      end

      def earliest
        @service.earliest
      end

      def latest
        @service.latest
      end

      def find(selector, _options = {})
        case selector
        when String
          record = @service.record(selector)
          OpenStruct.new(record) if record
        when :all
          @service.records.map { |record| OpenStruct.new(record) }
        end
      end
    end
  end
end
