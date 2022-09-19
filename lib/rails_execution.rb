# frozen_string_literal: true

require 'rails_execution/version'
require 'rails_execution/error'
require 'rails_execution/config'
require 'rails_execution/app_model'
require 'rails_execution/engine'
require 'rails_execution/paging'
require 'rails_execution/files/uploader'
require 'rails_execution/files/reader'

module RailsExecution

  def self.configuration
    @configuration ||= RailsExecution::Config.new
    yield @configuration if block_given?
    @configuration
  end

end
