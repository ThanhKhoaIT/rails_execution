class RailsExecution::Label < RailsExecution::AppModel
  SPECIAL_LABLES = ['scheduled', 'repeat']

  has_many :task_labels, class_name: 'RailsExecution::TaskLabel'
  has_many :tasks, through: :task_labels

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  scope :normal, -> { where.not(name: SPECIAL_LABLES) }
end
