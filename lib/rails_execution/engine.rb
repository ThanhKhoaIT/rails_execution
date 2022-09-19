# frozen_string_literal: true

module RailsExecution
  class Engine < ::Rails::Engine

    isolate_namespace ::RailsExecution

    initializer 'execution' do |app|
      if defined?(Sprockets)
        app.config.assets.precompile << 'executions/base.js'
        app.config.assets.precompile << 'executions/base.css'
        app.config.assets.precompile << 'executions/logo.png'
        app.config.assets.precompile << 'executions/favicon.png'
      end
    end

  end
end
