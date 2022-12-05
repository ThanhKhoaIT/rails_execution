# frozen_string_literal: true

module RailsExecution
  module Files
    class Uploader

      def initialize(task, inputs, owner: nil)
        @task = task
        @files = files_filter(inputs).compact
        @owner = owner
      end

      def call
        raise ::NotImplementedError, 'File uploader'
      end

      private

      attr_reader :task
      attr_reader :files
      attr_reader :owner

      def files_filter(inputs)
        inputs.map do |_multiple, attachment|
          next if attachment['name'].blank?
          next if attachment['file'].blank?
          next unless attachment['file'].content_type.in?(acceptable_file_types)

          OpenStruct.new({
            name: attachment['name'],
            file: attachment['file'],
          })
        end
      end

      def acceptable_file_types
        ::RailsExecution.configuration.acceptable_file_types.values.flatten
      end

    end
  end
end
