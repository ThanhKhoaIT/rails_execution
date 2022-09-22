module RailsExecution
  module Services
    class Approvement

      def initialize(task, reviewer: nil)
        @task = task || (raise 'task is blank')
        @reviewer = reviewer || (raise 'reviewer is blank')
      end

      def approve
        review.update(status: :approved)
        add_activity('approved')
      end

      def reject
        review.update(status: :rejected)
        add_activity('rejected')
      end

      private

      attr_reader :task
      attr_reader :reviewer

      def review
        @review ||= task.task_reviews.find_or_initialize_by(owner: reviewer)
      end

      def add_activity(status)
        task.activities.create(owner: reviewer, message: "Make to #{status}")
      end

    end
  end
end
