class AddGravatorUrlToZombies < ActiveRecord::Migration
  def change
    add_column :zombies, :gravatarurl, :string
  end
end
