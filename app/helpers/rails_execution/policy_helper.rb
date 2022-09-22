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

    def current_owner
      return @current_owner if defined?(@current_owner)
      return nil if ::RailsExecution.configuration.owner_method.blank?

      @current_owner = self.send(::RailsExecution.configuration.owner_method)
    end

  end
end
