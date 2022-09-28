# frozen_string_literal: true

require 'rails/generators'

module RailsExecution
  module Generators
    class FileUploadGenerator < Rails::Generators::Base

      source_root File.join(__dir__, 'templates')

      def copy_config
        template 'file_uploader.rb', 'lib/rails_execution/file_uploader.rb'
        template 'file_reader.rb', 'lib/rails_execution/file_reader.rb'
      end

    end
  end
end
