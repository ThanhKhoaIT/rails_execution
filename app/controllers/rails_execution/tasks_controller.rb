# frozen_string_literal: true

module RailsExecution
  class TasksController < ::RailsExecution::BaseController
    LIMITED_FILTER_LIST = 100

    def index
      paging = ::RailsExecution::Services::Paging.new(page: params[:page], per_page: params[:per_page])
      processing_tasks = ::RailsExecution::Task.processing.preload(:owner, :labels)
      processing_tasks = ::RailsExecution::Tasks::FilterService.new(processing_tasks, params, current_owner&.id).call
      @comments_count_by_task_id = ::RailsExecution::Comment.where(task: processing_tasks).group(:task_id).count
      @tasks = paging.call(processing_tasks)
    end

    def new
      raise(::RailsExecution::AccessDeniedError, 'Create task') unless can_create_task?

      @task = ::RailsExecution::Task.new
    end

    def create
      raise(::RailsExecution::AccessDeniedError, 'Create task') unless can_create_task?

      result = ::RailsExecution::Tasks::CreateService.new(params, current_owner).call
      @task = result.task
      if result.error.nil?
        ::RailsExecution::Services::CreateScheduledJob.new(@task).call if in_solo_mode? && can_schedule_task?(@task)
        flash[:notice] = 'Create request successfully!'
        redirect_to action: :index
      else
        render action: :new
      end
    end

    def fork
      raise(::RailsExecution::AccessDeniedError, 'Fork task') unless can_create_task?

      @task = ::RailsExecution::Task.new({
        status: :created,
        owner_id: current_owner&.id,
        owner_type: ::RailsExecution.configuration.owner_model.to_s,
        title: current_task.title,
        scheduled_at: current_task.scheduled_at,
        repeat_mode: current_task.repeat_mode,
        description: current_task.description,
        script: current_task.script,
      })
      @task.labels = current_task.labels
      @task.syntax_status = ::RailsExecution::Services::SyntaxChecker.new(@task.script).call ? 'good' : 'bad'

      render action: :new
    end

    def show
    end

    def destroy
      unless can_close_task?(current_task)
        flash[:alert] = "You can't close this Task right now"
        redirect_to(:back) and return
      end

      if current_task.update(status: :closed)
        ::RailsExecution::Services::RemoveScheduledJob.new(current_task).call if can_remove_scheduled_job?(current_task)
        current_task.activities.create(owner: current_owner, message: 'Closed the task')
        ::RailsExecution.configuration.notifier.new(current_task).after_close
        redirect_to(action: :show) and return
      else
        flash[:alert] = "Has problem when close this Task: #{current_task.errors.full_messages.join(', ')}"
        redirect_to(:back) and return
      end
    end

    def edit
      raise(::RailsExecution::AccessDeniedError, 'Edit task') unless can_edit_task?(current_task)

      @task = current_task
    end

    def update
      raise(::RailsExecution::AccessDeniedError, 'Edit task') unless can_edit_task?(current_task)

      @task = current_task

      old_script = @task.script
      old_reviewer_ids = @task.task_reviews.pluck(:owner_id)
      checked_owner_ids = @task.task_reviews.checked.pluck(:owner_id)
      old_scheduled_at = @task.scheduled_at

      update_data = {
        title: params.dig(:task, :title),
        description: params.dig(:task, :description),
        scheduled_at: Time.zone.parse(params.dig(:task, :scheduled_at).to_s),
        repeat_mode: params.dig(:task, :repeat_mode),
      }

      update_data[:script] = params.dig(:task, :script) if @task.in_processing?
      @task.assign_reviewers(params.dig(:task, :task_review_ids).to_a)
      @task.assign_labels(params[:task_label_ids].to_a)
      @task.syntax_status = ::RailsExecution::Services::SyntaxChecker.new(update_data[:script]).call ? 'good' : 'bad'

      if @task.update(update_data)
        ::RailsExecution::Services::RemoveScheduledJob.new(@task).call if (old_script != @task.script || @task.scheduled_at != old_scheduled_at) && can_remove_scheduled_job?(@task)
        @task.add_files(params[:attachments]&.permit!.to_h, current_owner) if ::RailsExecution.configuration.file_upload
        @task.activities.create(owner: current_owner, message: 'Updated the Task')
        ::RailsExecution.configuration.notifier.new(@task).after_update_script(current_owner, checked_owner_ids) if old_script != @task.script
        ::RailsExecution.configuration.notifier.new(@task).after_assign_reviewers(current_owner, @task.task_reviews.reload.pluck(:owner_id) - old_reviewer_ids)
        redirect_to action: :show
      else
        render action: :edit
      end
    end

    def completed
      paging = ::RailsExecution::Services::Paging.new(page: params[:page], per_page: params[:per_page])
      completed_tasks = ::RailsExecution::Task.is_completed.includes(:owner, :comments, :labels)
      completed_tasks = ::RailsExecution::Tasks::FilterService.new(completed_tasks, params, current_owner&.id).call
      @tasks = paging.call(completed_tasks)
    end

    def closed
      paging = ::RailsExecution::Services::Paging.new(page: params[:page], per_page: params[:per_page])
      closed_tasks = ::RailsExecution::Task.is_closed.includes(:owner, :comments, :labels)
      closed_tasks = ::RailsExecution::Tasks::FilterService.new(closed_tasks, params, current_owner&.id).call
      @tasks = paging.call(closed_tasks)
    end

    def reopen
      if current_task.update(status: :created)
        ::RailsExecution::Services::CreateScheduledJob.new(current_task).call if in_solo_mode? && can_schedule_task?(current_task)
        current_task.activities.create(owner: current_owner, message: 'Re-opened the Task')
        ::RailsExecution.configuration.notifier.new(current_task).after_reopen
        flash[:notice] = 'Your task is re-opened'
      else
        flash[:alert] = "Re-open is failed: #{current_task.errors.full_messages.join(', ')}"
      end
      redirect_to action: :show
    end

    def reject
      if ::RailsExecution::Services::Approvement.new(current_task, reviewer: current_owner).reject
        ::RailsExecution::Services::RemoveScheduledJob.new(current_task).call if can_remove_scheduled_job?(current_task)
        ::RailsExecution.configuration.notifier.new(current_task).after_reject(current_owner)
        flash[:notice] = 'Your decision is updated!'
      else
        flash[:alert] = "Your decision is can't update!"
      end
      redirect_to action: :show
    end

    def approve
      if ::RailsExecution::Services::Approvement.new(current_task, reviewer: current_owner).approve
        ::RailsExecution::Services::CreateScheduledJob.new(current_task).call if can_schedule_task?(current_task)
        ::RailsExecution.configuration.notifier.new(current_task).after_approve(current_owner)
        flash[:notice] = 'Your decision is updated!'
      else
        flash[:alert] = "Your decision isn't updated!"
      end
      redirect_to action: :show
    end

    def execute
      unless can_execute_task?(current_task)
        flash[:alert] = "This task can't execute: #{how_to_executable(current_task)}"
        redirect_to(action: :show) and return
      end

      execute_service = ::RailsExecution::Services::Execution.new(current_task)
      if execute_service.call
        current_task.update(status: :completed) unless current_task.repeatable?
        current_task.activities.create(owner: current_owner, message: 'Execute: The task is completed')
        ::RailsExecution.configuration.notifier.new(current_task).after_execute_success(current_owner)
        flash[:notice] = 'This task is executed'
      else
        ::RailsExecution.configuration.notifier.new(current_task).after_execute_fail(current_owner)
        flash[:alert] = "Sorry!!! This task can't execute right now"
      end

      redirect_to(action: :show)
    end

    def execute_in_background
      unless can_execute_task?(current_task)
        flash[:alert] = "This task can't execute: #{how_to_executable(current_task)}"
        redirect_to(action: :show) and return
      end
      RailsExecution::Services::BackgroundExecution.new(current_task, current_owner).setup
      redirect_to(action: :show)
    end

    private

    def current_task
      @current_task ||= ::RailsExecution::Task.find_by(id: params[:id])
    end
    helper_method :current_task

    def reviewers
      return @reviewers if defined?(@reviewers)

      list = ::RailsExecution.configuration.reviewers.call
      list = list.map { |reviewer| reviewer[:id] == current_owner.id ? nil : ::OpenStruct.new(reviewer) }
      @reviewers = list.compact
    end
    helper_method :reviewers

    def repeat_mode_options
      @repeat_mode_options ||= {
        'Does not repeat': :none,
        'Daily': :daily,
        'Weekly': :weekly,
        'Monthly': :monthly,
        'Anually': :anually,
        'Every Weekday': :weekdays,
      }
    end
    helper_method :repeat_mode_options

    def task_logs
      @task_logs ||= ::RailsExecution.configuration.logging_files.call(current_task)
    end
    helper_method :task_logs

    def task_attachment_files
      @task_attachment_files ||= ::RailsExecution.configuration.file_reader.new(current_task).call
    end
    helper_method :task_attachment_files

    def reviewing_accounts
      @reviewing_accounts ||= current_task.task_reviews.preload(:owner)
    end
    helper_method :reviewing_accounts

    def filter_owners
      @filter_owners ||= query_filter_owners
    end
    helper_method :filter_owners

    def query_filter_owners
      return ::RailsExecution.configuration.owner_model.constantize
        .where(id: RailsExecution::Task.select(:owner_id).distinct)
        .limit(LIMITED_FILTER_LIST)
    end

    def filter_labels
      @filter_labels ||= RailsExecution::Label.order(:name)
    end
    helper_method :filter_labels

    def current_filtered_owner
      @current_filtered_owner ||= ::RailsExecution.configuration.owner_model.constantize.find_by(id: params[:owner_id])
    end
    helper_method :current_filtered_owner

    def current_filtered_label
      @current_filtered_label ||= ::RailsExecution::Label.find_by(id: params[:label_id])
    end
    helper_method :current_filtered_label

  end
end
