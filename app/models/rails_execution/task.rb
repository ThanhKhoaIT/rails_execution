class RailsExecution::Task < RailsExecution::AppModel

  validates :status, presence: true

  enum status: {
    created: 'created',
    reviewing: 'reviewing',
    approved: 'approved',
    scheduled: 'scheduled',
    completed: 'completed',
    closed: 'closed',
  }, _prefix: :is

  scope :processing, -> { where(status: [:created, :reviewing, :approved]) }

end
