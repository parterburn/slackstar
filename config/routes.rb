Rails.application.routes.draw do
  root to: 'application#root'
  get 'clear', to: 'application#clear'
end
