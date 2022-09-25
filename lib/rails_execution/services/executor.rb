module RailsExecution
  module Services
    class Executor

      def initialize(task)
        @task = task
      end

      def call
        raise NotImplementedError
      end

      private

      attr_reader :task

    end
  end
end
