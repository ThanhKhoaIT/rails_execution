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
        file_extension = URI(url).path.split('.').last
        file_extension = ".#{file_extension}" if file_extension
        tmp_file = Tempfile.new([file_name, file_extension])
        tmp_file.binmode
        open(url) do |url_file|
          tmp_file.write(url_file.read)
        end

        return tmp_file
      end

    end
  end
end
