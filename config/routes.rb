Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post :upload_image, to: 'images#upload_image'
  post :login, to: 'users#login'
end
