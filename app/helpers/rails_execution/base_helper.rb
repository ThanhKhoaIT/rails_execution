module RailsExecution
  module BaseHelper
    include ActionView::Helpers::AssetUrlHelper

    def current_owner
      return @current_owner if defined?(@current_owner)
      return nil if ::RailsExecution.configuration.owner_method.blank?
      @current_owner = self.send(::RailsExecution.configuration.owner_method)
    end

    def normal_labels
      @normal_labels ||= RailsExecution::Label.normal
    end

  end
end
