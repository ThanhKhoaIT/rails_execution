module RailsExecution
  module Services
    class Executor

      def initialize(task)
        @task = task
        @file_reader = ::RailsExecution.configuration.file_reader.new(task)
      end

      def call
        raise NotImplementedError
      end

      private

      attr_reader :task

      def file(name)
        @file_reader.get_file(name)
      end

    end
  end
end
