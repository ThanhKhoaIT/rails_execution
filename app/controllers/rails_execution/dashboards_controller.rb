# frozen_string_literal: true

module RailsExecution
  class DashboardsController < ::RailsExecution::BaseController

    def home
      @in_processing_count = ::RailsExecution::Task.processing.count
      @tasks_count = ::RailsExecution::Task.group(:status).count
    end

    def insights
      @tasks_by_week = ::RailsExecution::Task
        .where(created_at: 10.weeks.ago.beginning_of_day..Time.current)
        .group('YEAR(created_at)', 'WEEK(created_at)')
        .count
      respond_to(&:json)
    end

    private

    def show_insights_chart?
      ::RailsExecution::Task.exists?(created_at: 100.year.ago..1.weeks.ago)
    end
    helper_method :show_insights_chart?

  end
end
