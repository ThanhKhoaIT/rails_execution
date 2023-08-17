# frozen_string_literal: true

require 'haml'

module RailsExecution
  class Engine < ::Rails::Engine

    isolate_namespace ::RailsExecution

    initializer 'execution' do |app|
      if defined?(Sprockets)
        app.config.assets.precompile << 'executions/base.js'
        app.config.assets.precompile << 'executions/base.css'
        app.config.assets.precompile << 'executions/logo.png'
        app.config.assets.precompile << 'executions/robot.png'
        app.config.assets.precompile << 'executions/favicon.png'
        app.config.assets.precompile << 'executions/rejected.png'
        app.config.assets.precompile << 'executions/approved.png'
        app.config.assets.precompile << 'executions/bootstrap-icons.woff' # Icons font
      end
    end

  end
end
