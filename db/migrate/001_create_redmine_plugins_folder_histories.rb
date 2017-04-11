class CreateRedminePluginsFolderHistories < ActiveRecord::Migration
  def change
    create_table :redmine_plugins_folder_histories do |t|
      t.string :total, default: ''
      t.text :plugins_changes
      t.text :plugins_list
      t.timestamps null: false
    end
  end
end
