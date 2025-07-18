class RuleSection < ApplicationRecord
  belongs_to :parent, class_name: 'RuleSection', optional: true
  has_many :children, class_name: 'RuleSection', foreign_key: 'parent_id', dependent: :destroy

   def self.nearest_neighbors(query_embedding, limit: 5, distance_metric: '<->')
    # Use raw SQL to leverage the pgvector extension on the database side
    # query_embedding must be a Ruby array of floats, which Rails will cast to a PG float array literal
    # for the SQL query.
    # The 'vector(D)' cast is crucial if your pgvector extension expects it,
    # otherwise, PostgreSQL might implicitly cast or error.
    # '<->' is L2 distance, '<#>' is negative inner product, '<=>' is cosine distance

    # Ensure query_embedding is an array and formatted correctly for SQL
    # For a float[] column, you'd pass a Ruby array, and it will be converted to '{1.0,2.0,3.0}' by Rails.
    # The ::vector(DIMENSIONS) cast is to ensure the right type for the pgvector operator.
    # Replace NNN with the actual dimension size of your vectors (e.g., 1536 for OpenAI ada-002)

    dimensions = query_embedding.length # Or hardcode your expected dimension, e.g., 1536
    vector_cast_sql = "ARRAY[?]::float[]::vector(#{dimensions})"


    order_by_clause = case distance_metric
                      when '<->' then 'embedding <-> ' # L2 distance (Euclidean)
                      when '<#>' then 'embedding <#> ' # Negative inner product
                      when '<=>' then 'embedding <=> ' # Cosine distance
                      else raise ArgumentError, "Unsupported distance metric: #{distance_metric}"
                      end

    find_by_sql([
      "SELECT *, (#{order_by_clause} #{vector_cast_sql}) AS distance
       FROM rule_sections
       ORDER BY distance ASC
       LIMIT ?",
      query_embedding,
      limit
    ])
  end

  # Example usage:
  # some_rule_section = RuleSection.create!(content: "...", embedding: [0.1, 0.2, 0.3])
  # query_vector = [0.1, 0.2, 0.29]
  # nearest = RuleSection.nearest_neighbors(query_vector, limit: 3, distance_metric: '<->')
  # nearest.each { |rs| puts "ID: #{rs.id}, Distance: #{rs.distance}" }


end
