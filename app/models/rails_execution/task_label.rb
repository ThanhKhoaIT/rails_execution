class RailsExecution::TaskLabel < RailsExecution::AppModel
  belongs_to :task, class_name: 'RailsExecution::Task'
  belongs_to :label, class_name: 'RailsExecution::Label'

  validates :task, uniqueness: { scope: :label }
end
