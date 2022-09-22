# frozen_string_literal: true

RailsExecution::Engine.routes.draw do
  root to: 'dashboards#home'

  resources :tasks do
    member do
      patch :reject
      patch :approve
    end

    resources :comments, only: [:create, :update, :destroy]
  end
end
