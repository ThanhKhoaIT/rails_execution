class RailsExecution::Tasks::CreateService

  def initialize(params, current_owner)
    @params = params
    @current_owner = current_owner
    @task = nil
    @error = nil
  end

  def call
    initialize_task
    create_task
  rescue => e
    @error = e.to_s
  ensure
    return self
  end

  attr_reader :error
  attr_reader :task

  private

  attr_reader :params
  attr_reader :current_owner

  def initialize_task
    @task = ::RailsExecution::Task.new({
      status: :created,
      owner_id: current_owner&.id,
      owner_type: ::RailsExecution.configuration.owner_model.to_s,
      title: params.dig(:task, :title),
      description: params.dig(:task, :description),
      script: params.dig(:task, :script),
      scheduled_at: parsed_scheduled_at,
      repeat_mode: params.dig(:task, :repeat_mode)
    })

    @task.assign_reviewers(params.dig(:task, :task_review_ids).to_a)
    @task.assign_labels(params[:task_label_ids].to_a)
    @task.syntax_status = ::RailsExecution::Services::SyntaxChecker.new(@task.script).call ? 'good' : 'bad'
  end

  def scheduled_at
    @scheduled_at ||= params.dig(:task, :scheduled_at)
  end

  def parsed_scheduled_at
    @parsed_scheduled_at ||= scheduled_at.blank? ? nil : Time.zone.parse(scheduled_at)
  rescue
    raise 'Invalid input for scheduling time'
  end

  def create_task
    if @task.save
      @task.add_files(params[:attachments]&.permit!.to_h, current_owner) if ::RailsExecution.configuration.file_upload
      ::RailsExecution.configuration.notifier.new(@task).after_create
    else
      raise @task.errors.messages.values.flatten.first
    end
  end
end
