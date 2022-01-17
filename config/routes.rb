Rails.application.routes.draw do
  root "timesheets#index"
  
  resources :timesheets
end
