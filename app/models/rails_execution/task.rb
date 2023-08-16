class RailsExecution::Task < RailsExecution::AppModel

  PROCESSING_STATUSES = %w(created reviewing approved processing rejected)
  ACTIVE_REPEAT_MODE = %w(hourly daily weekly monthly annually weekdays)

  has_many :activities, class_name: 'RailsExecution::Activity'
  has_many :comments, class_name: 'RailsExecution::Comment'
  has_many :task_reviews, class_name: 'RailsExecution::TaskReview'
  has_many :task_labels, class_name: 'RailsExecution::TaskLabel'
  has_many :labels, through: :task_labels
  attr_accessor :reviewer_ids

  validates :title, presence: true
  validates :status, presence: true
  validate :validate_scheduled_at, if: :scheduled_at_changed?

  before_validation :auto_assign_labels

  enum status: {
    created: 'created',
    reviewing: 'reviewing',
    approved: 'approved',
    processing: 'processing', # Processing by background job
    completed: 'completed',
    failed: 'failed',
    rejected: 'rejected',
    closed: 'closed',
  }, _prefix: :is

  enum syntax_status: {
    bad: 'bad',
    good: 'good',
  }, _prefix: true

  enum repeat_mode: {
    none: 'Does not repeat',
    hourly: 'Hourly',
    daily: 'Daily',
    weekly: 'Weekly',
    monthly: 'Monthly',
    annually: 'Anually',
    weekdays: 'Every weekday (Monday to Friday)',
  }, _prefix: :repeat

  scope :processing, -> { where(status: PROCESSING_STATUSES) }

  before_update :re_assign_status
  after_commit :create_activity, on: :create, if: :owner

  def in_processing?
    PROCESSING_STATUSES.include?(self.status)
  end

  def scheduled?
    self.scheduled_at? && self.repeat_none?
  end

  def repeatable?
    ACTIVE_REPEAT_MODE.include?(self.repeat_mode)
  end

  def assign_reviewers(ids)
    ids.each do |id|
      next if id.blank?

      task_review = self.task_reviews.find_or_initialize_by({
        owner_id: id,
        owner_type: ::RailsExecution.configuration.owner_model.to_s,
      })
      task_review.status ||= :reviewing
    end
  end

  def assign_labels(ids)
    self.labels = RailsExecution::Label.where(id: ids.uniq)
  end

  def reviewer_ids
    self.task_reviews.pluck(:owner_id)
  end

  def add_files(attachments, current_owner)
    ::RailsExecution.configuration.file_uploader.new(self, attachments, owner: current_owner).call
  end

  def repeat_mode_select_options
    return RailsExecution::Task.repeat_modes if scheduled_at.nil?

    options = RailsExecution::Task.repeat_modes.dup
    options['hourly'] = self.scheduled_at.strftime('Hourly at minute %-M')
    options['daily'] = self.scheduled_at.strftime('Daily at %H:%M')
    options['weekly'] = self.scheduled_at.strftime('Weekly on %A at %H:%M')
    options['monthly'] = self.scheduled_at.strftime('Monthly on %-d at %H:%M')
    options['annually'] = self.scheduled_at.strftime('Annually on %B %-d at %H:%M')
    options['weekdays'] = self.scheduled_at.strftime('Every weekday (Monday to Friday) at %H:%M')
    return options
  end

  def next_time_at
    ::RailsExecution::Services::CreateScheduledJob.new(self).calculate_next_time_at.strftime("%Y-%m-%d %H:%M")
  end

  private

  def create_activity
    self.activities.create(owner: self.owner, message: 'Created the task')
  end

  def re_assign_status
    return if self.is_completed? || self.is_closed?

    if self.is_approved? && (self.script_changed? || self.scheduled_at_changed?)
      self.status = :reviewing
      self.task_reviews.update_all(status: :reviewing)
    end
  end

  def validate_scheduled_at
    return if self.scheduled_at.blank?

    errors.add(:scheduled_at, "Input schedule time #{scheduled_at} is in the past for non-repeat mode") if scheduled_at.past? && repeat_none?
  end

  def auto_assign_labels
    scheduled_label = RailsExecution::Label.find_or_create_by(name: :scheduled)
    repeat_label = RailsExecution::Label.find_or_create_by(name: :repeat)

    final_label_ids = self.label_ids - [scheduled_label.id, repeat_label.id]

    if self.scheduled?
      final_label_ids << scheduled_label.id
    elsif self.repeatable?
      final_label_ids << repeat_label.id
    end

    self.label_ids = final_label_ids
  end

end
