class AddEmbeddingToQuery < ActiveRecord::Migration[8.0]
  def change
    add_column :user_queries, :embedding, :float, array: true, default: [] # 384 is embedding for MiniLM-L6-v2
  end
end
