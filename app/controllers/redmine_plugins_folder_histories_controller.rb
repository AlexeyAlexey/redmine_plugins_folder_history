class RedminePluginsFolderHistoriesController < ApplicationController
  unloadable
  layout 'admin'

  helper :sort
  include SortHelper


  before_filter :require_admin


  def index

  	 

  	sort_init 'created_at', 'asc'
    sort_update %w(created_at)

    @limit = per_page_option
  	@changes_scope = RedminePluginsFolderHistory.where(nil)

    if !params[:created_at_from].blank? and !params[:created_at_to].blank?
      @changes_scope = @changes_scope.where("DATE(created_at) BETWEEN ? AND ?", params[:created_at_from], params[:created_at_to])
    end

  	@changes_pages = Paginator.new @changes_scope.count, @limit, params['page']

  	@offset ||= @changes_pages.offset

  	@changes = @changes_scope.order(sort_clause).limit(@limit).offset(@offset).to_a

  end

  def show
  	@changes = RedminePluginsFolderHistory.where("id=?", params["id"]).to_a.first
  end
end
