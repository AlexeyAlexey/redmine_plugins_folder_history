class RedminePluginsFolderHistory < ActiveRecord::Base
  unloadable

  serialize :plugins_changes, JSON
  serialize :plugins_list, JSON
  

end
