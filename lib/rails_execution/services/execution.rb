module RailsExecution
  module Services
    class Execution

      def self.call(task_id)
        self.new(::RailsExecution::Task.find(task_id)).call
      end

      def initialize(task)
        @task = task
      end

      def call
        return if bad_syntax?

        build_execution_file!
        load_execution_file!
        is_successful = false
        begin
          setup_logger!
          execute_class!
          is_successful = true
        rescue
          is_successful = false
        ensure
          restore_logger!
          storing_log_file!
          return is_successful
        end
      end

      private

      attr_reader :task
      attr_reader :class_name

      def bad_syntax?
        !::RailsExecution::Services::SyntaxChecker.new(task.script).call
      end

      def build_execution_file!
        @class_name = "RailsExecutionID#{task.id}Time#{task.updated_at.to_i}Executor"
        ruby_code = <<~RUBY
          class #{class_name} < ::RailsExecution::Services::Executor
            def call
              task.with_lock do
                stop!('Task is being executed by another process') if task.is_processing? && task.jid.blank?

                task.update!(status: :processing)
                #{task.script}
              end
            end
          end
        RUBY

        @file = ::Tempfile.new([class_name, '.rb'])
        @file.binmode
        @file.write(ruby_code)
        @file.flush
        @file
      end

      def load_execution_file!
        load @file.path
      end

      def setup_logger!
        @model_logger = ::ActiveRecord::Base.logger
        @rails_logger = ::Rails.logger
        @tempfile = ::Tempfile.new(["rails_execution_#{Time.current.strftime('%Y%m%d_%H%M%S')}", '.log'])
        ::ActiveRecord::Base.logger = ::Logger.new(@tempfile.path)
        ::Rails.logger = ::ActiveRecord::Base.logger
      end

      def execute_class!
        class_name.constantize.new(task).call
      end

      def storing_log_file!
        ::RailsExecution.configuration.logging.call(@tempfile, task)
      end

      def restore_logger!
        ::ActiveRecord::Base.logger = @model_logger
        ::Rails.logger = @rails_logger
      end

    end
  end
end
