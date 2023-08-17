# frozen_string_literal: true

module RailsExecution
  class LabelsController < ::RailsExecution::BaseController

    def create
      raise(::RailsExecution::AccessDeniedError, 'Create label') unless can_create_task?

      @label = RailsExecution::Label.new(name: label_name)
      if @label.save
        updated_html = render_to_string(partial: 'rails_execution/tasks/label_collection_select', locals: { selected_label_ids: selected_label_ids })
        render json: { updated_html: updated_html }, status: 200
      else
        render json: @label.errors.full_messages.join(', '), status: 422
      end
    end

    private

    def label_name
      params[:label_name].downcase
    end

    def selected_label_ids
      params[:task_label_ids].to_a.append(@label.id)
    end

  end
end
