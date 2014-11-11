class CreateZombies < ActiveRecord::Migration
  def change
    create_table :zombies do |t|
      t.string :username
      t.integer :age
      t.text :bio
      t.string :email
      t.boolean :rotting

      t.timestamps
    end
  end
end
