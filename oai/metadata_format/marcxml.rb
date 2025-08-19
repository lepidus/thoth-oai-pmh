# frozen_string_literal: true

require 'oai'

module Thoth
  module Oai
    module Metadata
      # MARCXML metadata format specification
      class MarcXML < OAI::Provider::Metadata::Format
        def initialize
          super
          @prefix = 'marcxml'
          @schema = 'https://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd'
          @namespace = 'https://www.loc.gov/standards/marcxml/'
        end
      end
    end
  end
end
