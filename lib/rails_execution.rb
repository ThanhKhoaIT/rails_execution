# frozen_string_literal: true

require_relative "rails_execution/version"

module RailsExecution
  class Engine < ::Rails::Engine; end
  class Error < StandardError; end
end
