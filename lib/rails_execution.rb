# frozen_string_literal: true

require 'rails_execution/error'
require 'rails_execution/config'
require 'rails_execution/engine'
require 'rails_execution/version'
require 'rails_execution/app_model'
require 'rails_execution/files/reader'
require 'rails_execution/files/uploader'
require 'rails_execution/services/paging'
require 'rails_execution/services/executor'
require 'rails_execution/services/notifier'
require 'rails_execution/services/execution'
require 'rails_execution/services/background_execution'
require 'rails_execution/services/approvement'
require 'rails_execution/services/syntax_checker'
require 'rails_execution/services/task_scheduler'
require 'rails_execution/services/create_scheduled_job'
require 'rails_execution/services/remove_scheduled_job'

module RailsExecution

  def self.configuration
    @configuration ||= ::RailsExecution::Config.new
    yield @configuration if block_given?
    @configuration
  end

end
