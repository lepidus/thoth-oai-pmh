require 'oai'
require_relative 'model'

module ThothOAI
  class Provider < OAI::Provider::Base
    repository_name 'Thoth OAI-PMH Repository'
    repository_url 'http://localhost:4567/oai'
    record_prefix 'thoth'
    admin_email 'admin@example.com'
    source_model Model.new

    register_format(OAI::Provider::Metadata::DublinCore.instance)
  end
end
