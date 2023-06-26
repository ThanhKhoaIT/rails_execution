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

    def show_form_sidebar?(task)
      return false unless (task.new_record? || task.in_processing?)

      [
        ::RailsExecution.configuration.file_upload,
        !in_solo_mode? && ::RailsExecution.configuration.reviewers.present?,
      ].any?
    end

    def in_solo_mode?
      ::RailsExecution.configuration.solo_mode
    end

    def can_create_task?
      ::RailsExecution.configuration.task_creatable.call(current_owner)
    end

    def can_edit_task?(task)
      ::RailsExecution.configuration.task_editable.call(current_owner, task)
    end

    def can_close_task?(task)
      task.in_processing? && ::RailsExecution.configuration.task_closable.call(current_owner, task)
    end

    def can_execute_task?(task)
      how_to_executable(task).blank?
    end

    def how_to_executable(task)
      return 'Script is empty' if task.script.blank?
      return "Task is closed" if task.is_closed?
      return "It's bad Syntax" if task.syntax_status_bad?
      return "This task is being processed" if task.is_processing?

      unless in_solo_mode?
        return 'This task is not approved' unless task.is_approved?
        return 'No approval from any reviewer' if task.task_reviews.is_approved.empty?
      end

      return "Can't executable by app policy" unless ::RailsExecution.configuration.task_executable.call(current_owner, task)
    end

    def can_schedule_task?(task)
      how_to_schedulable(task).blank?
    end

    def how_to_schedulable(task)
      execute_message = how_to_executable(task)
      return execute_message if execute_message
      return "Time is not set for schedule" if task.scheduled_at.nil?
      return "Scheduled at time in the past" if task.scheduled_at.past?
    end

    def can_remove_scheduled_job?(task)
      task.jid.present?
    end

  end
end
