Rails.application.routes.draw do
  resources :room, only: [:edit, :update]
  resources :subject, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :teacher, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :student, only: [:index, :new, :create, :edit, :update, :destroy]

  resources :teacher_subject_mapping, only: [:create]
  delete 'teacher_subject_mapping/delete'
  resources :student_subject_mapping, only: [:create]
  delete 'student_subject_mapping/delete'

  get 'schedulemaster/overlook', to: 'schedulemaster#overlook'
  resources :schedulemaster, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  post 'schedulemaster/queue_to_delayed_job'
  post 'schedulemaster/queue_to_aws_batch'

  resources :calculation_rule, only: [:edit, :update]

  resources :student_schedulemaster_mapping, only: [:new, :create]
  resources :teacher_schedulemaster_mapping, only: [:new, :create]
  resources :subject_schedulemaster_mapping, only: [:new, :create]
  put 'subject_schedulemaster_mapping', to: 'subject_schedulemaster_mapping#update'

  resources :timetable, only: [:index, :update]
  post 'timetable/update_master'
  resources :classnumber, only: [:index, :update, :destroy]

  resources :teacherrequest, only: [:index, :create]
  get 'teacherrequest/occupation_and_matching'
  post 'teacherrequest/bulk_create'
  put 'teacherrequest/update_master'
  delete 'teacherrequest/delete'
  delete 'teacherrequest/bulk_delete'

  resources :studentrequest, only: [:index, :create]
  get 'studentrequest/occupation_and_matching'
  post 'studentrequest/bulk_create'
  put 'studentrequest/update_master'
  delete 'studentrequest/delete'
  delete 'studentrequest/bulk_delete'

  put 'schedule/bulk_update', to: 'schedule#bulk_update'
  put 'schedule/bulk_reset', to: 'schedule#bulk_reset'
  resources :schedule, only: [:index, :update]

  resources :teacherschedule, only: [:index]
  resources :studentschedule, only: [:index]

  post 'login/logout'
  post 'login/auth'
  resources :login, only: [:index]

  root 'schedulemaster#index'
end
