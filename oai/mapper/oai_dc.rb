# frozen_string_literal: true

module Thoth
  module Oai
    module Mapper
      # Class for mapping Thoth records to OAI DC format
      class OaiDc
        def initialize(input)
          @input = input
        end

        def map
          filter_empty({
                         id: @input['workId'],
                         identifiers: identifiers,
                         title: @input['fullTitle'],
                         creators: creators,
                         contributors: contributors,
                         rights: @input['license'],
                         date: @input['publicationDate'],
                         publisher: publisher,
                         languages: languages,
                         types: type,
                         subjects: subjects,
                         description: @input['longAbstract'],
                         relations: relations,
                         formats: format,
                         updated_at: updated_at
                       })
        end

        def identifiers
          work_id = "https://thoth.pub/books/#{@input['workId']}"
          doi = @input['doi']
          isbns = @input['publications'].map do |pub|
            pub['isbn'] ? "info:eu-repo/semantics/altIdentifier/isbn/#{pub['isbn']}" : nil
          end.compact
          arrayify(work_id) + arrayify(doi) + arrayify(isbns)
        end

        def creators
          arrayify(@input['creator']&.map { |c| c['fullName'] })
        end

        def contributors
          arrayify(@input['contributor']&.map { |c| c['fullName'] })
        end

        def publisher
          @input.dig('imprint', 'publisher', 'publisherName')
        end

        def languages
          arrayify(@input['language']&.map { |l| l['languageCode'].downcase })
        end

        def type
          work_type = @input['workType']&.downcase
          case work_type
          when 'journal_article'
            'issue'
          when 'book', 'book_set', 'edited_book', 'monograph', 'textbook'
            'book'
          when 'book_chapter'
            'chapter'
          end
        end

        def subjects
          @input['keywords']&.map { |k| k['subjectCode'] }
        end

        def relations
          @input['relations'].map do |rel|
            related_work = rel['relatedWork'] || {}
            [
              related_work['doi'],
              related_work['publications']&.map do |pub|
                pub['isbn'] ? "info:eu-repo/semantics/altIdentifier/isbn/#{pub['isbn']}" : nil
              end
            ].compact.flatten
          end&.flatten
        end

        def format
          types = {
            'PDF' => 'application/pdf',
            'EPUB' => 'application/epub+zip',
            'HTML' => 'text/html',
            'XML' => 'application/xml'
          }

          @input['publications']&.map do |pub|
            pub_type = pub['publicationType']
            types[pub_type] if types.key?(pub_type)
          end&.compact&.uniq
        end

        def updated_at
          Time.parse(@input['updatedAtWithRelations']) if @input['updatedAtWithRelations']
        end

        def arrayify(item)
          return [] if item.nil?

          Array(item).flatten.compact
        end

        def filter_empty(data)
          data.reject { |_k, v| v.nil? || (v.respond_to?(:empty?) && v.empty?) }
        end
      end
    end
  end
end
