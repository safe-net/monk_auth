class CreateSnapLogins < ActiveRecord::Migration
  def change
    create_table :snap_logins do |t|
      t.string :token, null: false

      t.timestamps
    end
  end
end
