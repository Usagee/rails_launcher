application 'index_only_application'
controller :welcome, only: :index
routes { root to: 'welcome#index' }
