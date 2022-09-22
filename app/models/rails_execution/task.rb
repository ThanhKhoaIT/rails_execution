class RailsExecution::Task < RailsExecution::AppModel

  PROCESSING_STATUSES = %w(created reviewing approved)

  has_many :task_reviews
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

end
