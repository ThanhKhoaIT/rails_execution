# frozen_string_literal: true

module RailsExecution
  class BaseController < ::ApplicationController

    clear_helpers

    include RailsExecution::BaseHelper
    include RailsExecution::PolicyHelper
    helper RailsExecution::RenderingHelper
    helper RailsExecution::PolicyHelper

    layout 'execution'

  end
end
