# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record'
require 'active_record'

module RailsExecution
  module Generators
    class InstallGenerator < Rails::Generators::Base

      include ActiveRecord::Generators::Migration

      source_root File.join(__dir__, 'templates')

      def copy_migration
        migration_template 'install.rb', 'db/migrate/install_execution.rb', migration_version: migration_version
      end

      def copy_config
        template 'config.rb', 'config/initializers/rails_execution.rb'
      end

      def mount_engine
        route "mount RailsExecution::Engine, at: 'execution'"
      end

      private

      def migration_version
        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end

    end
  end
end
