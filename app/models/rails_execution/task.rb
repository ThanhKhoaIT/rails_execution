class RailsExecution::Task < RailsExecution::AppModel

  PROCESSING_STATUSES = %w(created reviewing approved rejected)

  has_many :activities, class_name: 'RailsExecution::Activity'
  has_many :comments, class_name: 'RailsExecution::Comment'
  has_many :task_reviews, class_name: 'RailsExecution::TaskReview'
  attr_accessor :reviewer_ids

  validates :title, presence: true
  validates :status, presence: true

  enum status: {
    created: 'created',
    reviewing: 'reviewing',
    approved: 'approved',
    rejected: 'rejected',
    completed: 'completed',
    closed: 'closed',
  }, _prefix: :is

  enum syntax_status: {
    bad: 'bad',
    good: 'good',
  }, _prefix: true

  scope :processing, -> { where(status: PROCESSING_STATUSES) }

  before_update :re_assign_status
  after_commit :create_activity, on: :create, if: :owner

  def in_processing?
    PROCESSING_STATUSES.include?(self.status)
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

  def reviewer_ids
    self.task_reviews.pluck(:owner_id)
  end

  def add_files(attachments, current_owner)
    ::RailsExecution.configuration.file_uploader.new(self, attachments, owner: current_owner).call
  end

  private

  def create_activity
    self.activities.create(owner: self.owner, message: 'Created the task')
  end

  def re_assign_status
    return if self.is_completed? || self.is_closed?

    if self.is_approved? && self.script_changed?
      self.status = :reviewing
      self.task_reviews.update_all(status: :reviewing)
    end
  end

end
