# frozen_string_literal: true

module RailsExecution
  class CommentsController < ::RailsExecution::BaseController

    def create
      @new_comment = current_task.comments.new(owner: current_owner, content: params.dig(:comment, :content))
      if @new_comment.save
        current_task.activities.create(owner: current_owner, message: "Added a comment: #{@new_comment.content.truncate(30)}")
        flash[:notice] = 'Your comment is added!'
        redirect_to task_path(current_task)
      else
        flash[:alert] = "Your comment can't adding!"
        render 'rails_execution/tasks/show'
      end
    end

    def update
      @comment = current_comment
      @comment.update(content: params.dig(:comment, :content))
      respond_to(&:js)
    end

    private

    def current_task
      @current_task ||= RailsExecution::Task.find(params[:task_id])
    end
    helper_method :current_task

    def current_comment
      @comment ||= current_task.comments.find(params[:id])
    end
    helper_method :current_comment

  end
end
