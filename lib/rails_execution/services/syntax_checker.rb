module RailsExecution
  module Services
    class SyntaxChecker
      OK_MESSAGE = 'Syntax OK'

      def initialize(code)
        @code = code
      end

      def call
        init_tempfile
        return is_ok?
      end

      private

      attr_reader :code

      def init_tempfile
        @file = ::Tempfile.new('syntax_checker')
        @file.binmode
        @file.write(code)
        @file.flush
        @file
      end

      def is_ok?
        result = `cat #{@file.path} | ruby -c`
        result.strip == OK_MESSAGE
      rescue SyntaxError
        return false
      end

    end
  end
end
