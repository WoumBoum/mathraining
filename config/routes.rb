Ombtraining::Application.routes.draw do

  resources :corrections


  resources :solvedexercises
  resources :solvedqcms
  resources :solvedchoices


  resources :qcms, only: [:update, :edit, :destroy] do
    match '/order_plus', to: 'qcms#order_plus',
      as: :order_plus
    match '/order_minus', to: 'qcms#order_minus',
      as: :order_minus
    match '/put_online', to: 'qcms#put_online',
      as: :put_online
    match '/manage_choices', to: "qcms#manage_choices"
    match '/add_choice', to: "qcms#add_choice"
    match '/update_choice/:id', to: "qcms#update_choice", as: :update_choice
    match '/remove_choice/:id', to: "qcms#remove_choice", as: :remove_choice
    match '/switch_choice/:id', to: "qcms#switch_choice", as: :switch_choice
  end
  
  resources :exercises, only: [:update, :edit, :destroy] do
    match '/order_plus', to: 'exercises#order_plus',
      as: :order_plus
    match '/order_minus', to: 'exercises#order_minus',
      as: :order_minus
    match '/put_online', to: 'exercises#put_online',
      as: :put_online
  end


  resources :theories, only: [:update, :edit, :destroy] do
    match '/order_plus', to: 'theories#order_plus',
      as: :order_plus
    match '/order_minus', to: 'theories#order_minus',
      as: :order_minus
    match '/put_online', to: 'theories#put_online',
      as: :put_online
    match '/read', to: 'theories#read', as: :read
    match '/unread', to: 'theories#unread', as: :unread
    match '/latex', to: 'theories#latex', as: :latex
  end
  
  resources :problems, only: [:update, :edit, :destroy] do
    match '/order_plus', to: 'problems#order_plus',
      as: :order_plus
    match '/order_minus', to: 'problems#order_minus',
      as: :order_minus
    match '/put_online', to: 'problems#put_online',
      as: :put_online
    resources :submissions, only: [:create, :show] do
      resources :corrections, only: [:create]
    end
  end

  mathjax 'mathjax'
  
  resource :prerequisites # missing a 's' here ?
  resources :sections
  
  match '/graph_prerequisites', to: "prerequisites#graph_prerequisites"
  match '/add_prerequisite', to: "prerequisites#add_prerequisite"  
  match '/remove_prerequisite', to: "prerequisites#remove_prerequisite"  
    
  resources :chapters do
    match '/warning', to: 'chapters#warning'
    match '/put_online', to: 'chapters#put_online'
    match '/manage_sections', to: 'chapters#new_section'
    match '/add_section/:id', to: 'chapters#create_section',
      as: :add_section
    match '/remove_section/:id', to: 'chapters#destroy_section',
      as: :remove_section
      
    resources :theories, only: [:new, :create]
    resources :exercises, only: [:new, :create]
    resources :qcms, only: [:new, :create]
    resources :problems, only: [:new, :create]
  end

  resources :users do
    match '/add_administrator', to: 'users#create_administrator',
      as: :add_administrator
  end
  
  resources :sessions, only: [:new, :create, :destroy]

  root to: 'static_pages#home'

  match '/help', to: 'static_pages#help'
  match '/essai', to: 'static_pages#essai'

  match '/about', to: 'static_pages#about'

  match '/contact', to: 'static_pages#contact'

  match '/signup', to: 'users#new'
  match '/signin', to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete

end
