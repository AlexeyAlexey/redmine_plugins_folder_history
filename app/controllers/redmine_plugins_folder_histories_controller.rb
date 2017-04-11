class RedminePluginsFolderHistoriesController < ApplicationController
  unloadable
  layout 'admin'
  before_filter :require_admin


  def index

  	@changes = RedminePluginsFolderHistory.where(nil).last

  end

  def show
  end
end
