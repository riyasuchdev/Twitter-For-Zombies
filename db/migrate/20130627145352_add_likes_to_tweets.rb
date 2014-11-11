class AddLikesToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :likes, :integer, default: 0
    add_column :tweets, :likedby, :text, default: ""
  end
end
