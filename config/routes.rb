Rails.application.routes.draw do

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
   
  match 'twilio/voice', to: 'twilio#voice', via: [:get, :post]
  get 'twilio/play_ai_voice', to: 'twilio#play_ai_voice'
  get 'audio/:filename', to: 'audio_files#show', as: :audio_file
  post 'twilio/loopback_callback', to: 'twilio#loopback_callback', as: :twilio_loopback_callback
end
