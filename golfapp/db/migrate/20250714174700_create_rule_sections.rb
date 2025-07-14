class CreateRuleSections < ActiveRecord::Migration[8.0]
  def change
    create_table :rule_sections do |t|
      t.string :title
      t.text :text_content
      t.string :source_url
      t.references :parent, null: false, foreign_key: true

      t.timestamps
    end
  end
end
