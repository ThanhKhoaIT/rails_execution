class RailsExecution::Tasks::FilterService
  def initialize(tasks_query_object, params, current_user_id = nil)
    @tasks_query_object = tasks_query_object
    @params = params
    @current_user_id = current_user_id
  end

  def call
    filter_by_owner
    filter_by_label
    filter_by_keyword
    order_by_recently_updated

    @tasks_query_object.descending
  end

  private

  attr_reader :params
  attr_reader :current_user_id

  def filter_by_owner
    if params[:my_task] == '1' && current_user_id
      @tasks_query_object = @tasks_query_object.where(owner_id: current_user_id)
    elsif params[:owner_id].present?
      @tasks_query_object = @tasks_query_object.where(owner_id: params[:owner_id])
    end
  end

  def filter_by_label
    return if params[:label_id].blank?

    filtered_task_ids = RailsExecution::TaskLabel.where(label_id: params[:label_id]).select(:task_id)
    @tasks_query_object = @tasks_query_object.where(id: filtered_task_ids)
  end

  def filter_by_keyword
    return if params[:keyword].blank?

    @tasks_query_object = @tasks_query_object.where('rails_execution_tasks.title LIKE ?', "%#{params[:keyword]}%")
  end

  def order_by_recently_updated
    sort_by = if params[:recently_updated].blank?
                { updated_at: :desc }
              else
                params[:recently_updated] == '1' ? { updated_at: :desc } : { updated_at: :asc }
              end
    @tasks_query_object = @tasks_query_object.order(sort_by)
  end
end
