module RailsExecution
  module Services
    class RemoveScheduledJob

      def initialize(task)
        @task = task
      end

      def call
        return if task.jid.blank?

        task.update(jid: nil) if ::RailsExecution.configuration.scheduled_task_remover.call(task.jid)
      end

      private

      attr_reader :task
    end
  end
end
