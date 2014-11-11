class AddPasswordHashAndPasswordSaltToZombies < ActiveRecord::Migration
  def change
    add_column :zombies, :password_hash, :string
    add_column :zombies, :password_salt, :string
  end
end
