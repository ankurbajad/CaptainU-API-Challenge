Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      devise_for :users, controllers: { registrations: 'api/v1/registrations', sessions: 'api/v1/sessions' , passwords: 'api/v1/passwords' }
      delete 'signout' => 'sessions#destroy'
      resources :tournaments
    end
  end
end
