Rails.application.routes.draw do
  devise_for :users, controllers: {
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
  }
  defaults format: :html do
    resources :begin_end_times, only: [:update], defaults: { format: 'json' }
    resources :contracts, only: [:index]
    resources :groups, only: [:index]
    resources :groups, only: [:create, :update, :destroy], defaults: { format: 'js' }
    resources :group_contracts, only: [:update], defaults: { format: 'json' }
    resources :rooms, only: [:index, :update]
    resources :seat, only: [:index, :update]
    resources :students, only: [:index]
    resources :students, only: [:create, :update, :destroy], defaults: { format: 'js' }
    resources :student_request, only: [:create, :destroy]
    resources :student_subject, only: [:create, :destroy]
    get 'student_term/:id/schedule', to: 'student_term#schedule'
    resources :teachers, only: [:index]
    resources :teachers, only: [:create, :update, :destroy], defaults: { format: 'js' }
    get 'teacher_term/:id/schedule', to: 'teacher_term#schedule'
    resources :teacher_subject, only: [:create, :destroy]
    resources :teacher_request, only: [:create, :destroy]
    resources :terms, only: [:index, :show]
    resources :terms, only: [:create], defaults: { format: 'js' }
    resources :term_groups, only: [:create], defaults: { format: 'js' }
    resources :term_students, only: [:index]
    resources :term_students, only: [:create, :update], defaults: { format: 'js' }
    resources :term_teachers, only: [:index]
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
