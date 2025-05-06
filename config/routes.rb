Rails.application.routes.draw do

  post '/orders', to: 'orders#create'
  post '/orders/:id/lock', to: 'orders#lock'
  get '/sku-summary/:sku', to: 'order#sku_summary'
end
