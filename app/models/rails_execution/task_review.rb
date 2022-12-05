class RailsExecution::TaskReview < RailsExecution::AppModel

  belongs_to :task

  validates :task, presence: true
  validates :status, presence: true

  enum status: {
    reviewing: 'reviewing',
    approved: 'approved',
    rejected: 'rejected',
  }, _prefix: :is

  scope :checked, -> { where(status: [:approved, :rejected]) }

end
