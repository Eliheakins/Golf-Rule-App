class CreateUserQueries < ActiveRecord::Migration[8.0]
  def change
    create_table :user_queries do |t|
      t.text :content
      t.text :response_text
      t.string :session_id
      t.integer :feedback
      t.references :rule_section, null: false, foreign_key: true

      t.timestamps
    end
  end
end

class EnableVectorExtension < ActiveRecord::Migration[7.1]
  def change
    enable_extension 'vector'
  end
end
