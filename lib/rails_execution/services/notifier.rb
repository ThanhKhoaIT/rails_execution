module RailsExecution
  module Services
    class Notifier

      def initialize(task)
        @task = task
      end

      def after_create; end
      def after_close; end
      def after_reopen; end
      def after_update_script(_editor, _reviewer_ids); end
      def after_assign_reviewers(_editor, _new_reviewer_ids); end
      def after_reject(_reviewer); end
      def after_approve(_reviewer); end
      def after_execute_success(_executor); end
      def after_execute_fail(_executor); end

      def add_comment(_commenter, _content); end

      private

      attr_reader :task

    end
  end
end
