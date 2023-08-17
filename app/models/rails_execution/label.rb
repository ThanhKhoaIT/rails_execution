class RailsExecution::Label < RailsExecution::AppModel
  SPECIAL_LABLES = ['scheduled', 'repeat']
  COLORS = 'red pink purple deep-purple indigo blue light-blue cyan teal green orange deep-orange brown grey blue-grey'.split

  has_many :task_labels, class_name: 'RailsExecution::TaskLabel'
  has_many :tasks, through: :task_labels

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  scope :normal, -> { where.not(name: SPECIAL_LABLES) }

  def color
    color_index = self.name.to_s.chars.sum(&:ord) % COLORS.size
    COLORS[color_index]
  end
end
