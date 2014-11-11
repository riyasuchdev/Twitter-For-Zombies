class AddAuthenticatiomToken < ActiveRecord::Migration
  def up
    add_column :zombies, :authentication_token, :string
  end

  def down
    remove_column :zombies, :authentication_token
  end
end
