# frozen_string_literal: true

require 'oai'
require_relative 'model'

module Thoth
  module Oai
    # OAI-PMH Provider class
    class Provider < OAI::Provider::Base
      repository_name 'Thoth OAI-PMH Repository'
      repository_url 'http://localhost:4567/oai'
      record_prefix 'thoth'
      admin_email 'admin@example.com'
      source_model Model.new

      register_format(OAI::Provider::Metadata::DublinCore.instance)
    end
  end
end
