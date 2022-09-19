class RailsExecution::Comment < RailsExecution::AppModel

  belongs_to :task

  validates :task, presence: true
  validates :content, presence: true

end
