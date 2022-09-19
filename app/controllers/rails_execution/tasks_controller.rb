# frozen_string_literal: true

module RailsExecution
  class TasksController < ::RailsExecution::BaseController

    def index
      paging = ::RailsExecution::Paging.new(page: params[:page], per_page: params[:per_page])
      @tasks = paging.call(RailsExecution::Task.processing)
    end

    def new
    end

    def create
    end

    def show
    end

    def destroy
    end

    def edit
    end

    def update
    end

  end
end
