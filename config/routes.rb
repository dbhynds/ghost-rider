Rails.application.routes.draw do

  devise_for :users
  root to: "commutes#index"

  get 'retrieve/buslines', to: 'retrieves#buslines'
  get 'retrieve/busdirections', to: 'retrieves#busdirections'
  get 'retrieve/busstops', to: 'retrieves#busstops'
  get 'retrieve/all', to: 'retrieves#all_cta_data'

  get 'prediction/:rt/:stpid', to: 'retrieves#prediction'

  get 'commutes/:id/ghosts/fetch', to: 'commutes#fetch_ghosts'
  get 'commutes/:id/ghosts/track', to: 'commutes#track_ghosts'
  get 'commutes/:id/ghosts', to: 'commutes#ghosts'
  get 'commutes/:id/reports', to: 'commutes#reports'
  resources :commutes

  get 'ghost_commutes/:id/track', to: 'ghost_commutes#track'
  resources :ghost_commutes


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
