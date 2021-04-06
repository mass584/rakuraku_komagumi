Rails.application.routes.draw do
  devise_for :users, controllers: {
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
  }
  defaults format: :html do
    resources :begin_end_time, only: [:update]
    resources :contract, only: [:index, :update]
    resources :groups, only: [:index, :create, :update, :destroy]
    resources :piece, only: [:index, :update]
    put 'piece/bulk_update', to: 'piece#bulk_update'
    resources :rooms, only: [:index, :update]
    resources :seat, only: [:index, :update]
    resources :students, only: [:index, :create, :update, :destroy]
    resources :student_request, only: [:create, :destroy]
    resources :student_subject, only: [:create, :destroy]
    resources :student_term, only: [:index, :show, :create, :update]
    get 'student_term/:id/schedule', to: 'student_term#schedule'
    resources :subject_term, only: [:index, :create]
    resources :teachers, only: [:index, :create, :update, :destroy]
    resources :teacher_term, only: [:index, :show, :create, :update]
    get 'teacher_term/:id/schedule', to: 'teacher_term#schedule'
    resources :teacher_subject, only: [:create, :destroy]
    resources :teacher_request, only: [:create, :destroy]
    resources :terms, only: [:index, :new, :create, :show, :update, :destroy]
    resources :timetable, only: [:index, :update]
    resources :tutorials, only: [:index, :create, :update, :destroy]
    root 'room#index'
  end
end
