module SamsonKubernetes
  class Engine < Rails::Engine
  end
end

Samson::Hooks.view :project_tabs_view, 'kubernetes_project/project_tab'
