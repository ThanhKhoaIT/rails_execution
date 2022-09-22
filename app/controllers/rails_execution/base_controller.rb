# frozen_string_literal: true

module RailsExecution
  class BaseController < ::ApplicationController

    clear_helpers

    helper RailsExecution::RenderingHelper
    helper RailsExecution::PolicyHelper
    include RailsExecution::PolicyHelper

    layout 'execution'

  end
end
