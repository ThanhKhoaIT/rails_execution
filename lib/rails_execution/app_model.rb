# frozen_string_literal: true

model_klass = defined?(ApplicationRecord) ? ApplicationRecord : ActiveRecord::Base

class RailsExecution::AppModel < model_klass

  self.abstract_class = true

  belongs_to :owner, polymorphic: true

end
