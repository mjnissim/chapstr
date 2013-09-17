class ChangeUserLocalStoreToSettings < ActiveRecord::Migration
  def change
    rename_column :projects, :local_store, :settings
  end
end
