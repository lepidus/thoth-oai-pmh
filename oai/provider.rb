# frozen_string_literal: true

require 'oai'
require_relative 'model'

module Thoth
  module Oai
    # OAI-PMH Provider class
    class Provider < OAI::Provider::Base
      repository_name 'Thoth OAI-PMH Repository'
      repository_url 'https://oai.thoth.pub/'
      record_prefix 'thoth'
      admin_email 'support@thoth.pub'
      sample_id '5a08ff03-7d53-42a9-bfb5-7fc81c099c52'
      source_model Model.new
    end
  end
end
