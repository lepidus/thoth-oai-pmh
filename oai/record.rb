# frozen_string_literal: true

module Thoth
  module Oai
    # Thoth OAI-PMH record
    class Record
      attr_accessor :id, :doi, :publications, :full_title, :creators,
                    :contributors, :license, :publication_date, :publisher,
                    :languages, :work_type, :keywords, :abstract,
                    :relations, :updated_at

      def initialize(attributes = {})
        attributes.each do |name, value|
          instance_variable_set("@#{name}", value)
        end
      end

      def map_oai_dc
        {
          identifiers: [:doi, :publications.map { |pub| pub['isbn'] }, :id],
          title: :full_title,
          creators: :creators,
          contributors: :contributors,
          license: :license,
          date: :publication_date,
          publisher: :publisher,
          language: :languages,
          type: :type,
          subject: :keywords,
          description: :abstract,
          relations: :relations,
          updatedAt: :updated_at
        }
      end
    end
  end
end
