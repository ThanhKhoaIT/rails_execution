module RailsExecution
  module Services
    class CreateScheduledJob
      NUMBER_OF_MONTHS = 12

      def initialize(task)
        @task = task
      end

      def call
        calculate_next_time_at
        create_schedule_job if next_time_at.future?
      end

      def calculate_next_time_at
        return task.scheduled_at unless task.repeatable?

        next_time_at = task.scheduled_at

        if task.repeat_weekdays?
          next_time_at += 1.day until next_time_at.future? && next_time_at.wday.between?(1, 5)
        else
          i = 1
          while next_time_at.past?
            next_time_at = task.scheduled_at + i.public_send(repeat_time_intervals[task.repeat_mode.to_sym])
            i += 1
          end
        end

        return next_time_at
      end

      private

      attr_reader :task

      def next_time_at
        @next_time_at ||= calculate_next_time_at
      end

      def repeat_time_intervals
        @repeat_time_intervals ||= {
          hourly: :hours,
          daily: :days,
          weekly: :weeks,
          monthly: :months,
          annually: :years,
        }
      end

      def create_schedule_job
        jid = ::RailsExecution.configuration.task_scheduler.call(next_time_at, task.id)
        task.update(
          scheduled_at: next_time_at,
          jid: jid.presence
        )
      end

    end
  end
end
