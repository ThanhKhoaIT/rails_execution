# frozen_string_literal: true

module RailsExecution
  class TasksController < ::RailsExecution::BaseController

    def index
      paging = ::RailsExecution::Services::Paging.new(page: params[:page], per_page: params[:per_page])
      processing_tasks = ::RailsExecution::Task.processing.descending.includes(:owner)
      @tasks = paging.call(processing_tasks)
    end

    def new
      raise(::RailsExecution::AccessDeniedError, 'Create task') unless can_create_task?

      @task = ::RailsExecution::Task.new
    end

    def create
      raise(::RailsExecution::AccessDeniedError, 'Create task') unless can_create_task?

      @task = ::RailsExecution::Task.new({
        status: :created,
        owner_id: current_owner&.id,
        owner_type: ::RailsExecution.configuration.owner_model.to_s,
        title: params.dig(:task, :title),
        description: params.dig(:task, :description),
        script: params.dig(:task, :script),
      })
      @task.assign_reviewers(params.dig(:task, :task_review_ids).to_a)
      @task.syntax_status = ::RailsExecution::Services::SyntaxChecker.new(@task.script).call ? 'good' : 'bad'

      if @task.save
        @task.add_files(params[:attachments]&.permit!.to_h, current_owner) if ::RailsExecution.configuration.file_upload
        flash[:notice] = 'Create the request is successful!'
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
        description: current_task.description,
        script: current_task.script,
      })
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
        current_task.activities.create(owner: current_owner, message: 'Closed the task')
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
      update_data = {
        title: params.dig(:task, :title),
        description: params.dig(:task, :description),
      }

      update_data[:script] = params.dig(:task, :script) if @task.in_processing?
      @task.assign_reviewers(params.dig(:task, :task_review_ids).to_a)
      @task.syntax_status = ::RailsExecution::Services::SyntaxChecker.new(update_data[:script]).call ? 'good' : 'bad'

      if @task.update(update_data)
        @task.add_files(params[:attachments]&.permit!.to_h, current_owner) if ::RailsExecution.configuration.file_upload
        @task.activities.create(owner: current_owner, message: 'Updated the Task')
        redirect_to action: :show
      else
        render action: :edit
      end
    end

    def completed
      paging = ::RailsExecution::Services::Paging.new(page: params[:page], per_page: params[:per_page])
      completed_tasks = ::RailsExecution::Task.is_completed.descending.includes(:owner)
      @tasks = paging.call(completed_tasks)
    end

    def closed
      paging = ::RailsExecution::Services::Paging.new(page: params[:page], per_page: params[:per_page])
      closed_tasks = ::RailsExecution::Task.is_closed.descending.includes(:owner)
      @tasks = paging.call(closed_tasks)
    end

    def reopen
      if current_task.update(status: :created)
        current_task.activities.create(owner: current_owner, message: 'Re-opened the Task')
        flash[:notice] = 'Your task is re-opened'
      else
        flash[:alert] = "Re-open is failed: #{current_task.errors.full_messages.join(', ')}"
      end
      redirect_to action: :show
    end

    def reject
      if ::RailsExecution::Services::Approvement.new(current_task, reviewer: current_owner).reject
        flash[:notice] = 'Your decision is updated!'
      else
        flash[:alert] = "Your decision is can't update!"
      end
      redirect_to action: :show
    end

    def approve
      if ::RailsExecution::Services::Approvement.new(current_task, reviewer: current_owner).approve
        flash[:notice] = 'Your decision is updated!'
      else
        flash[:alert] = "Your decision is can't update!"
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
        current_task.update(status: :completed)
        current_task.activities.create(owner: current_owner, message: 'Execute: The task is completed')
        flash[:notice] = 'This task is executed'
      else
        flash[:alert] = "Sorry!!! This task can't execute right now"
      end

      redirect_to(action: :show)
    end

    private

    def current_task
      @current_task ||= ::RailsExecution::Task.find_by(id: params[:id])
    end
    helper_method :current_task

    def reviewers
      @reviewers ||= ::RailsExecution.configuration.reviewers.call.map do |reviewer|
        ::OpenStruct.new(reviewer)
      end
    end
    helper_method :reviewers

    def task_logs
      @task_logs ||= ::RailsExecution.configuration.logging_files.call(current_task).select(&:present?)
    end
    helper_method :task_logs

    def task_attachment_files
      @task_attachment_files ||= ::RailsExecution.configuration.file_reader.new(current_task).call
    end
    helper_method :task_attachment_files

    def reviewing_accounts
      @reviewing_accounts ||= current_task.task_reviews
    end
    helper_method :reviewing_accounts

  end
end
