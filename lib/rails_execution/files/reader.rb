# frozen_string_literal: true

require 'net/http'
require 'tempfile'
require 'uri'

module RailsExecution
  module Files
    class Reader

      def initialize(task)
        @task = task
        @tempfile_by_name = {}
      end

      def call
        raise ::NotImplementedError, "load_files (Output: { 'file1' => 'file-url', file2 => 'file-url' })"
      end

      # Return: the Tempfile instance
      def get_file(name)
        return nil if name.blank?

        @file_url_by_name ||= call
        file_url = @file_url_by_name[name]
        return nil if file_url.blank?

        @tempfile_by_name[name] ||= save_to_tempfile(name, file_url)
      end

      private

      attr_reader :task

      def save_to_tempfile(file_name, url)
        file = open(url)
        return file if file.is_a?(Tempfile)

        raise "Unsupported the Filetype #{file.class.name}" unless file.is_a?(StringIO)

        file_extension = file.base_uri.path.split('.').last
        file_extension = ".#{file_extension}" if file_extension
        tempfile = Tempfile.new([file_name, file_extension])
        tempfile.binmode
        tempfile.write(file.string)
        tempfile
      end

    end
  end
end
