ActionController::Routing::Routes.draw do |map|

  map.connect 'users/login', :controller => 'users', :action => 'login'
  map.connect 'users/logout', :controller => 'users', :action => 'logout'
  map.connect 'rss_items/sample_by_target', :controller => 'rss_items', :action => 'sample_by_target'
  map.connect 'rss_items/get_one_to_rate', :controller => 'rss_items', :action => 'get_one_to_rate'
  map.connect 'quote_targets/charts', :controller => 'quote_targets', :action => 'charts'
  map.connect 'classified_people/classify', :controller => 'classified_people', :action => 'classify'

  map.resources :classified_person_categories

  map.resources :classified_people

  map.resources :rss_item_scores

  map.resources :classification_strategies

  map.resources :classified_paragraphs

  map.resources :exchanges

  map.resources :neural_populations

  map.resources :predictions

  map.resources :neural_strategies

  map.resources :quote_values

  map.resources :quote_targets

  map.resources :rss_items

  map.resources :rss_targets

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "quote_targets"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
