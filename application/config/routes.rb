Rails.application.routes.draw do
  devise_for :users, controllers: {
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
  }
  defaults format: :html do
    resources :begin_end_times, only: [:update], defaults: { format: 'json' }
    resources :contracts, only: [:index]
    resources :contracts, only: [:update], defaults: { format: 'json' }
    resources :groups, only: [:index]
    resources :groups, only: [:create, :update, :destroy], defaults: { format: 'js' }
    resources :piece, only: [:index, :update]
    put 'piece/bulk_update', to: 'piece#bulk_update'
    resources :rooms, only: [:index, :update]
    resources :seat, only: [:index, :update]
    resources :students, only: [:index]
    resources :students, only: [:create, :update, :destroy], defaults: { format: 'js' }
    resources :student_request, only: [:create, :destroy]
    resources :student_subject, only: [:create, :destroy]
    get 'student_term/:id/schedule', to: 'student_term#schedule'
    resources :subject_term, only: [:index, :create]
    resources :teachers, only: [:index]
    resources :teachers, only: [:create, :update, :destroy], defaults: { format: 'js' }
    get 'teacher_term/:id/schedule', to: 'teacher_term#schedule'
    resources :teacher_subject, only: [:create, :destroy]
    resources :teacher_request, only: [:create, :destroy]
    resources :terms, only: [:index, :new, :create, :show, :update, :destroy]
    resources :term_teachers, only: [:index, :create, :update]
    resources :term_students, only: [:index, :create, :update]
    resources :timetables, only: [:index]
    resources :timetables, only: [:update], defaults: { format: 'json' }
    resources :tutorials, only: [:index]
    resources :tutorials, only: [:create, :update, :destroy], defaults: { format: 'js' }
    root 'room#index'
  end
end
