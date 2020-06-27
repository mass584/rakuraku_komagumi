Rails.application.routes.draw do
  resources :room, only: [:edit, :update]
  get 'room/login', to: 'room#login'
  post 'room/logout', to: 'room#logout'
  post 'room/auth', to: 'room#auth'

  resources :subject, only: [:index, :create, :update, :destroy]
  resources :student, only: [:index, :create, :update, :destroy]
  resources :teacher, only: [:index, :create, :update, :destroy]

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

  resources :timetable, only: [:index]
  put 'timetablemaster/:id', to: 'timetable#update_timetablemaster'
  put 'timetable/:id', to: 'timetable#update_timetable'

  resources :classnumber, only: [:index, :update, :destroy]

  resources :teacherrequest, only: [:index, :create, :destroy]
  put 'teacherrequestmaster/:id', to: 'teacherrequest#update_master'
  post 'teacherrequest/bulk_create'
  delete 'teacherrequest/bulk_delete'

  resources :studentrequest, only: [:index, :create, :destroy]
  put 'studentrequestmaster/:id', to: 'studentrequest#update_master'
  post 'studentrequest/bulk_create'
  delete 'studentrequest/bulk_delete'

  put 'schedule/bulk_update', to: 'schedule#bulk_update'
  put 'schedule/bulk_reset', to: 'schedule#bulk_reset'
  resources :schedule, only: [:index, :update]

  resources :teacherschedule, only: [:index]
  resources :studentschedule, only: [:index]

  root 'schedulemaster#index'
end
