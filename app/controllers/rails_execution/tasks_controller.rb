# frozen_string_literal: true

module RailsExecution
  class TasksController < ::RailsExecution::BaseController

    def index
      paging = ::RailsExecution::Paging.new(page: params[:page], per_page: params[:per_page])
      @tasks = paging.call(RailsExecution::Task.processing.descending)
    end

    def new
      @task = RailsExecution::Task.new
    end

    def create
      @task = RailsExecution::Task.new({
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
        flash[:notice] = 'Create the request is successful!'
        redirect_to action: :index
      else
        render action: :new
      end
    end

    def show
    end

    def destroy
    end

    def edit
      @task = current_task
    end

    def update
      @task = current_task
      update_data = {
        title: params.dig(:task, :title),
        description: params.dig(:task, :description),
      }

      update_data[:script] = params.dig(:task, :script) if @task.script_editable?
      update_data[:status] = :reviewing if @task.is_approved?
      @task.assign_reviewers(params.dig(:task, :task_review_ids).to_a)
      @task.syntax_status = ::RailsExecution::Services::SyntaxChecker.new(update_data[:script]).call ? 'good' : 'bad'

      if @task.update(update_data)
        redirect_to action: :show
      else
        render action: :edit
      end
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

    private

    def reviewers
      @reviewers ||= ::RailsExecution.configuration.reviewers&.call.to_a.map do |reviewer|
        OpenStruct.new(reviewer)
      end
    end
    helper_method :reviewers

    def current_task
      @current_task ||= RailsExecution::Task.find(params[:id])
    end
    helper_method :current_task

    def reviewing_accounts
      @reviewing_accounts ||= current_task.task_reviews.where.not(owner_id: current_owner&.id)
    end
    helper_method :reviewing_accounts

  end
end
