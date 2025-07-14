# frozen_string_literal: true

module Thoth
  module Api
    module Graphql
      # Base class for GraphQL queries
      class Base
        def self.query
          raise NotImplementedError, 'Subclasses must implement a query method'
        end
      end
    end
  end
end
