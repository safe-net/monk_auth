class AddEmailToSnapLogin < ActiveRecord::Migration
  def change
    add_column :snap_logins, :email, :string
  end
end
