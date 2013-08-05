class AddLocalStoreToProject < ActiveRecord::Migration
  def change
    add_column :projects, :local_store, :text
  end
end
