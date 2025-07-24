# frozen_string_literal: true

require 'oai'
require_relative 'model'

module Thoth
  module Oai
    # OAI-PMH Provider class
    class Provider < OAI::Provider::Base
      repository_name 'Thoth OAI-PMH Repository'
      repository_url 'http://thoth.pub/oai'
      record_prefix 'thoth'
      admin_email 'info@thoth.pub'
      source_model Model.new

      register_format(OAI::Provider::Metadata::DublinCore.instance)
    end
  end
end
