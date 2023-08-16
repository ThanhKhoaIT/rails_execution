# frozen_string_literal: true

module RailsExecution
  class Config

    DEFAULT_PER_PAGE = 20
    DEFAULT_FILE_TYPES = {
      '.png': 'image/png',
      '.gif': 'image/gif',
      '.jpg': 'image/jpg',
      '.jpeg': 'image/jpeg',
      '.pdf': 'application/pdf',
      '.csv': ['text/csv', 'text/plain'],
    }

    attr_accessor :solo_mode # Solo mode without reviewing process

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
    attr_accessor :file_uploader
    attr_accessor :file_reader
    attr_accessor :task_schedulable
    attr_accessor :task_scheduler # lambda
    attr_accessor :scheduled_task_remover # lambda
    attr_accessor :task_background
    attr_accessor :task_background_executor # lambda
    attr_accessor :acceptable_file_types

    # Logger
    attr_accessor :logging # lambda
    attr_accessor :logging_files

    # Paging
    attr_accessor :per_page

    # Notify
    attr_accessor :notifier

    def initialize
      self.solo_mode = true

      self.owner_model = defined?(::User) ? 'User' : nil
      self.owner_method = :current_user
      self.owner_name_method = :name
      self.owner_avatar = ->(_) { nil }

      self.file_upload = false
      self.acceptable_file_types = DEFAULT_FILE_TYPES
      self.file_uploader = ::RailsExecution::Files::Uploader
      self.file_reader = ::RailsExecution::Files::Reader

      self.task_schedulable = false
      self.task_scheduler = ->(_scheduled_at, _task_id) { nil }
      self.scheduled_task_remover = ->(_task_id) { nil }

      self.task_background = false
      self.task_background_executor = ->(_task_id) { nil }

      self.per_page = DEFAULT_PER_PAGE
      self.reviewers = -> { [] }

      self.task_creatable = ->(_user) { true }
      self.task_editable = ->(_user, _task) { true }
      self.task_closable = ->(_user, _task) { true }
      self.task_approvable = ->(_user, _task) { true }
      self.task_executable = ->(_user, _task) { true }

      self.logging = ->(_log_file, _task) {}
      self.logging_files = ->(_task) { [] }

      self.notifier = ::RailsExecution::Services::Notifier
    end

  end
end
