class AddFolowingToZombies < ActiveRecord::Migration
  def change
    add_column :zombies, :following, :text, default:""
  end
end
