class CreateRedminePluginsFolderHistories < ActiveRecord::Migration
  def change
    create_table :redmine_plugins_folder_histories do |t|
      t.string :total, default: ''
      t.text :plugins_changes
      t.text :plugins_list
      t.boolean :was_changed, default: false
      t.boolean :was_added,   default: false
      t.boolean :was_deleted, default: false
      t.timestamps null: false
    end
  end
end
