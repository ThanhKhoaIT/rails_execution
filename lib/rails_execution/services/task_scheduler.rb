module RailsExecution
  module Services
    class TaskScheduler

      def self.call(task_id)
        self.new(task_id).call
      end

      def initialize(task_id)
        @task = Task.find(task_id)
      end

      def call
        task.with_lock do
          next unless task.is_approved? || task.is_processing? && task.scheduled_at.present?
          execute_service = ::RailsExecution::Services::Execution.new(task)
          if execute_service.call
            task.update(status: :completed) unless task.repeatable?
            task.activities.create(owner: task.owner, message: 'Execute: Task completed successfully')
            ::RailsExecution.configuration.notifier.new(task).after_execute_success(task.owner)
            ::RailsExecution::Services::CreateScheduledJob.new(task).call if task.repeatable?
          else
            task.update(status: :failed)
            ::RailsExecution.configuration.notifier.new(task).after_execute_fail(task.owner)
          end
        end
      end

      private

      attr_reader :task

    end
  end
end
