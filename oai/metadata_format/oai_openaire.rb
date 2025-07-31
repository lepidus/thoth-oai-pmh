# frozen_string_literal: true

module Thoth
  module Oai
    module Metadata
      # OpenAIRE metadata format specification
      class OpenAIRE < OAI::Provider::Metadata::Format
        def initialize
          super
          @prefix = 'oai_openaire'
          @schema = 'https://www.openaire.eu/schema/repo-lit/4.0/openaire.xsd'
          @namespace = 'http://namespace.openaire.eu/schema/oaire/'
          @fields = %i[title creator contributor fundingReference alternativeIdentifier
                       relatedIdentifier embargoPeriodDate language publisher publicationDate
                       resourceType description format resourceIdentifier accessRights
                       source subject licenseCondition coverage size geoLocation
                       resourceVersion fileLocation citationTitle citationVolume
                       citationIssue citationStartPage citationEndPage citationEdition
                       citationConferencePlace citationConferenceDate audience]
        end

        def header_specification
          {
            'xmlns:rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
            'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
            'xmlns:dc' => 'http://purl.org/dc/elements/1.1/',
            'xmlns:dcterms' => 'http://purl.org/dc/terms/',
            'xmlns:datacite' => 'http://datacite.org/schema/kernel-4',
            'xmlns:oaire' => 'http://namespace.openaire.eu/schema/oaire/',
            'xsi:schemaLocation' =>
              %(http://namespace.openaire.eu/schema/oaire/
                https://www.openaire.eu/schema/repo-lit/4.0/openaire.xsd).gsub(/\s+/, ' ')
          }
        end
      end
    end
  end
end
