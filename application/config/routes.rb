Rails.application.routes.draw do
  resources :begin_end_time, only: [:update]
  resources :contract, only: [:index, :update]
  resources :piece, only: [:index, :update]
  put 'piece/bulk_update', to: 'piece#bulk_update'
  devise_for :rooms, controllers: {
    registrations: 'rooms/registrations',
    sessions: 'rooms/sessions',
  }
  resources :seat, only: [:update]
  resources :student, only: [:index, :create, :update, :destroy]
  resources :student_request, only: [:create, :destroy]
  resources :student_subject, only: [:create, :destroy]
  resources :student_term, only: [:index, :show, :create, :update]
  resources :subject, only: [:index, :create, :update, :destroy]
  resources :subject_term, only: [:create]
  resources :teacher, only: [:index, :create, :update, :destroy]
  resources :teacher_term, only: [:index, :show, :create, :update]
  resources :teacher_subject, only: [:create, :destroy]
  resources :teacher_request, only: [:create, :destroy]
  resources :term, only: [:index, :create, :show, :update, :destroy]
  resources :timetable, only: [:index, :update]
  root 'term#index'
end
