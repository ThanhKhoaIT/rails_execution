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

    # Owner display
    attr_accessor :owner_model
    attr_accessor :owner_method
    attr_accessor :owner_name_method
    attr_accessor :owner_avatar # lambda

    # Task control
    attr_accessor :reviewers # lambda

    # Accessible check
    attr_accessor :task_editable # lambda
    attr_accessor :task_closable # lambda
    attr_accessor :task_creatable # lambda
    attr_accessor :task_approvable # lambda
    attr_accessor :task_executable # lambda

    # Advanced
    attr_accessor :file_upload
    attr_accessor :file_types
    attr_accessor :file_uploader
    attr_accessor :file_reader

    # Paging
    attr_accessor :per_page

    def initialize
      self.owner_model = defined?(::User) ? 'User' : nil
      self.owner_method = :current_user
      self.owner_name_method = :name
      self.owner_avatar = ->(_) { nil }
      self.file_upload = false
      self.file_types = DEFAULT_FILE_TYPES.values
      self.file_uploader = ::RailsExecution::Files::Uploader
      self.file_reader = ::RailsExecution::Files::Reader
      self.per_page = DEFAULT_PER_PAGE
      self.reviewers = -> { [] }

      self.task_creatable = -> (_user) { true }
      self.task_editable = -> (_user, _task) { true }
      self.task_closable = -> (_user, _task) { true }
      self.task_approvable = -> (_user, _task) { true }
      self.task_executable = -> (_user, _task) { true }
    end

  end
end
