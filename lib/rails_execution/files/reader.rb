# frozen_string_literal: true

require 'net/http'
require 'tempfile'
require 'uri'

module RailsExecution
  module Files
    class Reader

      def initialize(task)
        @task = task
      end

      # Return: the Tempfile instance
      def get_file(name)
        return nil if name.blank?

        @file_url_by_name ||= load_files!
        file_url = @file_by_name[name]
        return nil if file_url.blank?

        @tempfile_by_name[name] ||= save_to_tempfile(name, file_url)
      end

      private

      attr_reader :task

      def load_files
        raise ::NotImplementedError, "load_files (Output: { 'file1' => 'file-url', file2 => 'file-url' })"
      end

      def save_to_tempfile(file_name, url)
        uri = ::URI.parse(url)
        ::Net::HTTP.start(uri.host, uri.port) do |http|
          resp = http.get(uri.path)
          file = ::Tempfile.new(file_name, Dir.tmpdir, 'wb+')
          file.binmode
          file.write(resp.body)
          file.flush
          file
        end
      end

    end
  end
end
