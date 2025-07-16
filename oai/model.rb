# frozen_string_literal: true

require_relative '../api/service'
require 'oai'

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

      def find(_selector, _options = {})
        []
      end
    end
  end
end
