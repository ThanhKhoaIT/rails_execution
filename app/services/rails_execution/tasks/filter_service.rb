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

    return @tasks_query_object.descending
  end

  private

  attr_reader :params
  attr_reader :current_user_id

  def filter_by_owner
    if params[:filter_only_my_tasks] == '1' && current_user_id
      @tasks_query_object = @tasks_query_object.where(owner_id: current_user_id)
    elsif params[:owner_id].present?
      @tasks_query_object = @tasks_query_object.where(owner_id: params[:owner_id])
    end
  end

  def filter_by_label
    @tasks_query_object = @tasks_query_object.joins(:task_labels).where(rails_execution_task_labels: { label_id: params[:label_id] }) if params[:label_id].present?
  end

  def filter_by_keyword
    @tasks_query_object = @tasks_query_object.where("rails_execution_tasks.title LIKE ?", "%#{params[:keyword]}%") if params[:keyword].present?
  end

  def order_by_recently_updated
    @tasks_query_object = @tasks_query_object.order(updated_at: :desc) if params[:order_by_recently_updated] == '1'
  end

end
