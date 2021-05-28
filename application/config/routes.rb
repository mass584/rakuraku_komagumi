Rails.application.routes.draw do
  devise_for :users, controllers: {
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
  }

  namespace :optimization, defaults: { format: 'json' } do
    resources :terms, only: [:show, :update]
    resources :logs, only: [:update]
  end

  defaults format: :html do
    resources :begin_end_times, only: [:update], defaults: { format: 'json' }
    resources :contracts, only: [:index]
    resources :groups, only: [:index]
    resources :groups, only: [:create, :update, :destroy], defaults: { format: 'js' }
    resources :group_contracts, only: [:update], defaults: { format: 'json' }
    resources :optimization_logs, only: [:create, :update], defaults: { format: 'json' }
    resources :rooms, only: [:index]
    resources :rooms, only: [:create, :update], defaults: { format: 'js' }
    resources :students, only: [:index]
    resources :students, only: [:create, :update, :destroy], defaults: { format: 'js' }
    resources :student_optimization_rules, only: [:update], defaults: { format: 'js' }
    resources :student_vacancies, only: [:update], defaults: { format: 'json' }
    resources :teachers, only: [:index]
    resources :teachers, only: [:create, :update, :destroy], defaults: { format: 'js' }
    resources :teacher_optimization_rules, only: [:update], defaults: { format: 'js' }
    resources :teacher_vacancies, only: [:update], defaults: { format: 'json' }
    resources :terms, only: [:index, :show] do
      get :schedule
    end
    resources :terms, only: [:create, :update], defaults: { format: 'js' }
    resources :term_groups, only: [:create, :update], defaults: { format: 'js' }
    resources :term_overall_schedules, only: [:create], defaults: { format: 'json' }
    post 'term_schedules/bulk_reset', to: 'term_schedules#bulk_reset', defaults: { format: 'json' }
    resources :term_schedules, only: [:create], defaults: { format: 'json' }
    get 'term_students/bulk_schedule', to: 'term_students#bulk_schedule'
    post 'term_students/bulk_schedule_notification', to: 'term_students#bulk_schedule_notification', defaults: { format: 'json' }
    resources :term_students, only: [:index] do
      get :vacancy
      get :schedule
    end
    resources :term_students, only: [:create, :update], defaults: { format: 'js' }
    get 'term_teachers/bulk_schedule', to: 'term_teachers#bulk_schedule'
    post 'term_teachers/bulk_schedule_notification', to: 'term_teachers#bulk_schedule_notification', defaults: { format: 'json' }
    resources :term_teachers, only: [:index] do
      get :vacancy
      get :schedule
    end
    resources :term_teachers, only: [:create, :update], defaults: { format: 'js' }
    resources :term_tutorials, only: [:create], defaults: { format: 'js' }
    resources :timetables, only: [:index]
    resources :timetables, only: [:update], defaults: { format: 'json' }
    resources :tutorials, only: [:index]
    resources :tutorials, only: [:create, :update, :destroy], defaults: { format: 'js' }
    resources :tutorial_contracts, only: [:update], defaults: { format: 'json' }
    resources :tutorial_pieces, only: [:index]
    resources :tutorial_pieces, only: [:update], defaults: { format: 'json' }
    root 'terms#index'
  end
end
