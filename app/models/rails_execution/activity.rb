class RailsExecution::Activity < RailsExecution::AppModel

  belongs_to :task

  validates :task, presence: true
  validates :message, presence: true

end
