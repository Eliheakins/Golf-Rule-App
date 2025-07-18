class CreateUserQueries < ActiveRecord::Migration[8.0]
  def change
    create_table :user_queries do |t|
      t.text :content
      t.string :session_id, null: true
      t.string :user_id, null: true
      t.integer :feedback, default: 0

      t.timestamps
    end
  end
end
