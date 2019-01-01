Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post :upload_image, to: 'images#upload_image'
  post :login, to: 'users#login'
  get :get_user, to: 'users#get_user'
  get :get_images, to: 'images#get_images'
  post :facepp_liveness_result, to: 'verification#facepp_liveness_result'
  get :get_verify_result, to: 'verification#get_verify_result'
end
