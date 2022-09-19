# frozen_string_literal: true

module RailsExecution
  module Files
    class Uploader

      def initialize(task, files, owner: nil)
        @task = task
        @files = files
        @owner = owner
      end

      def call
        raise ::NotImplementedError, 'File uploader'
      end

      private

      attr_reader :task
      attr_reader :files
      attr_reader :owner

    end
  end
end
