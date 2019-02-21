class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.integer :comment_id
      t.integer :parent_comment_id
      t.integer :user_id
      t.integer :child_count

      t.timestamps
    end
  end
end
