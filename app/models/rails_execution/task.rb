class RailsExecution::Task < RailsExecution::AppModel

  PROCESSING_STATUSES = %w(created reviewing approved)

  has_many :activities, class_name: 'RailsExecution::Activity'
  has_many :task_reviews, class_name: 'RailsExecution::TaskReview'
  attr_accessor :reviewer_ids

  validates :title, presence: true
  validates :status, presence: true

  enum status: {
    created: 'created',
    reviewing: 'reviewing',
    approved: 'approved',
    scheduled: 'scheduled',
    completed: 'completed',
    closed: 'closed',
  }, _prefix: :is

  scope :processing, -> { where(status: PROCESSING_STATUSES) }

  after_commit :create_activity, on: :create, if: :owner
  after_commit :update_activity, on: :update, if: :owner

  def script_editable?
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

  private

  def create_activity
    self.activities.create(owner: self.owner, message: 'Created the task')
  end

  def update_activity
    self.activities.create(owner: self.owner, message: 'Updated the Task')
  end

end
