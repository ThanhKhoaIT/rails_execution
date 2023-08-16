# frozen_string_literal: true

RailsExecution::Engine.routes.draw do
  root to: 'dashboards#home'

  resource :dashboards, only: [] do
    get :insights
  end

  resources :tasks do
    member do
      get :fork
      patch :reopen
      patch :reject
      patch :approve
      patch :execute
      patch :execute_in_background
    end

    collection do
      get :completed
      get :closed
    end

    resources :comments, only: [:create, :update, :destroy]
  end
  resources :labels, only: [:create]
end
