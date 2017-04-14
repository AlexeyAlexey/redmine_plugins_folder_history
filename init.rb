
Redmine::Plugin.register :redmine_plugins_folder_history do
  name 'Redmine Plugins Folder History plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  settings :default => {'empty' => true}, :partial => 'settings/redmine_plugins_folder_history/settings'

  menu :admin_menu, :plugins_folder_history, {:controller => 'redmine_plugins_folder_histories', :action => 'index', :project_id => nil}, :caption => :label_plugins_folder_history, :if => Proc.new {
    User.current.admin?
  }
end


ActionDispatch::Callbacks.to_prepare do
	if ActiveRecord::Base.connection.table_exists?(:redmine_plugins_folder_histories)
		begin
	      folders_db = RedminePluginsFolderHistory.last
	      last_plugins_changes = folders_db.try(:plugins_changes)
		   
		  cmd_ls = open("|ls -ls ./plugins")

		  line = (cmd_ls.gets || "").split(' ') #=> ["total", "176"]
          total = line[1] || ""

          folders = last_plugins_changes || {}
	      folders_list = {"list" => []}
          old_number_of_hashes = folders.map{|key, value| [key, value.size]} #[["plugin_name", "hash numbers"], ... ]
#
		  while (line = cmd_ls.gets)
		    folder_info = line.split(' ')
		    #=> ["4", "drwxr-xr-x", "9", "ubuntu", "ubuntu", "4096", "Dec", "26", "09:29", "email_notification_for_author_of_issue_where_status_in"]
		    folder_name = folder_info.last
		    folders_list["list"] << folder_name
		    	        
		    cmd_md5sum = open("|ls -alR ./plugins/#{folder_name} | md5sum")
		    md5sum_str = cmd_md5sum.gets
		    cmd_md5sum.close
		    
		    md5sum_str = md5sum_str.gsub(/[[:space:]]/, '')
		    
		    unless folders[folder_name].try(:include?, md5sum_str)
		      folders[folder_name] ||= {}
		      folder_info << "#{Time.now}"
              folders[folder_name][md5sum_str] = folder_info
		    end
		  end#while (line = cmd_ls.gets)

		  
          new_changes = RedminePluginsFolderHistory.new
          new_changes.total = total               #total
          new_changes.plugins_changes = folders   #{ "plugin_name" => {"hashes" => ["folder_info", ...]} }
          unless folders_db.nil?
            folders_list["deleted"] = folders_db.plugins_list["list"] - folders_list["list"] 
            folders_list["added"] = folders_list["list"] - folders_db.plugins_list["list"]

            new_number_of_hashes = folders.map{|key, value| [key, value.size]} #[["plugin_name", "hash numbers"], ... ]

            folders_list["changed"] = (old_number_of_hashes - new_number_of_hashes).map{|res| res.first}
          else
          	folders_list["deleted"] = []
          	folders_list["added"]   = []
          	folders_list["changed"] = []
          end
          new_changes.plugins_list = folders_list #{"list" => ["plugin_name", ...], "deleted" => [], "added" => []}
          
          new_changes.save
		rescue Exception => e

		  Rails.logger.error e
		ensure
		  cmd_ls.close
		end

	end

end


