module RailsExecution
  module PolicyHelper

    def display_owner?(owner)
      owner.present?
    end

    def display_decide?(task)
      task &&
        current_owner &&
        task.owner &&
        current_owner != task.owner &&
        task.syntax_status_good? &&
        !task.is_completed?
    end

    def display_reviewers?(task)
      task.task_reviews.exists?
    end

    def can_execute_task?(task)
      how_to_executable(task).blank?
    end

    def can_close_task?(task)
      task.in_processing?
    end

    def how_to_executable(task)
      return 'Script is empty' if task.script.blank?
      return "It's closed now" if task.is_closed?
      return "It's bad Syntax" if task.syntax_status_bad?
      return 'This task is not approved' unless task.is_approved?
      return 'No approval from any reviewer' if task.task_reviews.is_approved.empty?
    end

  end
end
