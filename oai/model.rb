# frozen_string_literal: true

require 'oai'

module ThothOAI
  # Model class for the OAI-PMH provider
  class Model < OAI::Provider::Model
    def earliest
      '2023-02-13T16:17:44Z'
    end

    def latest
      '2023-04-20T14:45:30Z'
    end
  end
end
