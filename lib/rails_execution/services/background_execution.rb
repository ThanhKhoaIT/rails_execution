module RailsExecution
  module Services
    class BackgroundExecution

      def self.call(task_id)
        self.new(::RailsExecution::Task.find(task_id)).call
      end

      def initialize(task, owner = nil)
        @task = task
        @owner = owner
      end

      def call
        task.with_lock do
          execute_service = ::RailsExecution::Services::Execution.new(task)
          if execute_service.call
            task.activities.create(message: 'Execute: The task is processed successfully by background job')

            if task.repeatable?
              task.update(status: :approved)
              task.activities.create(owner: owner, message: 'Set status to approved because the task is repeatable')
            else
              task.update(status: :completed)
              task.activities.create(owner: owner, message: 'Set status to completed because the task is not repeatable')
            end

            ::RailsExecution.configuration.notifier.new(task).after_execute_success(owner)
          else
            task.activities.create(message: 'Execute: The task failed to be processed by the background job')

            task.update(status: :approved)
            task.activities.create(owner: owner, message: 'Set task status to approved because the task is failed')
            ::RailsExecution.configuration.notifier.new(task).after_execute_fail(owner)
          end
        end
      end

      def setup
        task.with_lock do
          unless task.is_processing?
            task.update(status: :processing)
            task.activities.create(owner: owner, message: 'Process the task with background job')
            ::RailsExecution.configuration.task_background_executor.call(task.id)
          end
        end
      end

      private

      attr_reader :task
      attr_reader :owner

    end
  end
end
