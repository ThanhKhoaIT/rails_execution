module RailsExecution
  module Services
    class Executor

      HIGHLIGHT = '=' * 20

      def initialize(task)
        @task = task
        @file_reader = ::RailsExecution.configuration.file_reader.new(task)
      end

      def call
        raise NotImplementedError
      end

      private

      attr_reader :task

      def file(name)
        @file_reader.get_file(name)
      end

      def info(object)
        model_name = object.respond_to?(:model_name) ? object.model_name.name : object.to_s
        message = model_name + '#' + object&.id.to_s
        log(message, nil)
      end

      def log(label = nil, message)
        label ||= Time.current

        Rails.logger.info("#{HIGHLIGHT} #{label}")
        Rails.logger.info(message) if message
      end

      def error!(label = nil, message)
        log(label, message)
        stop!
      end

      def stop!(message = nil)
        log('Rolling back...', message)
        raise :rollback
      end

    end
  end
end
