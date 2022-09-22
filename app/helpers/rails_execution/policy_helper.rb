module RailsExecution
  module PolicyHelper

    def display_owner?(owner)
      owner.present?
    end

    def display_decide?(task)
      task && current_owner && task.owner && current_owner != task.owner
    end

    def display_reviewers?(task)
      task.task_reviews.exists?
    end

  end
end
