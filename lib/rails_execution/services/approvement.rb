module RailsExecution
  module Services
    class Approvement

      def initialize(task, reviewer: nil)
        @task = task || (raise 'task is blank')
        @reviewer = reviewer || (raise 'reviewer is blank')
      end

      def approve
        task.update(status: :approved)
        review.update(status: :approved)
        add_activity('approved')
      end

      def reject
        review.update(status: :rejected)
        task.update(status: :rejected) if make_task_to_rejected?
        add_activity('rejected')
      end

      private

      attr_reader :task
      attr_reader :reviewer

      def review
        @review ||= task.task_reviews.find_or_initialize_by(owner: reviewer)
      end

      def add_activity(status)
        task.activities.create(owner: reviewer, message: "#{status.titleize} the task")
      end

      def make_task_to_rejected?
        task.task_reviews.is_approved.empty?
      end

    end
  end
end
