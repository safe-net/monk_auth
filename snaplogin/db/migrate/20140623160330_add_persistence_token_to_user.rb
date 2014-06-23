class AddPersistenceTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :persistence_token, :string, null: false, default: 'some token'
  end
end
