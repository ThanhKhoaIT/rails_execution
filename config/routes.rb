# frozen_string_literal: true

RailsExecution::Engine.routes.draw do
  root to: 'dashboards#home'

  resources :tasks
end
