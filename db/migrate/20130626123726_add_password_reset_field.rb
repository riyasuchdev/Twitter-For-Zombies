class AddPasswordResetField < ActiveRecord::Migration
  def up
    add_column :zombies, :password_reset_token, :string
    add_column :zombies, :password_expires_after, :datetime
  end

  def down
    remove_column :zombies, :password_reset_token
    remove_column :zombies, :password_expires_after
  end
end
