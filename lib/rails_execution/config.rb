# frozen_string_literal: true

module RailsExecution
  class Config

    DEFAULT_PER_PAGE = 20
    DEFAULT_FILE_TYPES = {
      csv: 'text/plain',
      png: 'image/png',
      gif: 'image/gif',
      jpeg: 'image/jpeg',
      pdf: 'application/pdf',
    }

    attr_accessor :owner_method
    attr_accessor :owner_name_method
    attr_accessor :owner_avatar

    # Accessible check
    attr_accessor :task_viewable
    attr_accessor :task_editable
    attr_accessor :task_approvable
    attr_accessor :task_closable
    attr_accessor :task_commentable

    # Advanced
    attr_accessor :file_upload
    attr_accessor :file_types
    attr_accessor :file_uploader
    attr_accessor :file_reader

    # Paging
    attr_accessor :per_page

    def initialize
      self.owner_method = :current_user
      self.owner_name_method = :name
      self.owner_avatar = nil
      self.file_upload = false
      self.file_types = DEFAULT_FILE_TYPES.values
      self.file_uploader = RailsExecution::Files::Uploader
      self.file_reader = RailsExecution::Files::Reader
      self.per_page = DEFAULT_PER_PAGE
    end

  end
end
