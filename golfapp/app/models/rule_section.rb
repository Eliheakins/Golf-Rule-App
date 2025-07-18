class RuleSection < ApplicationRecord
  belongs_to :parent, class_name: 'RuleSection', optional: true  
  has_and_belongs_to_many :user_queries
  has_many :children, class_name: 'RuleSection', foreign_key: 'parent_id', dependent: :destroy
  before_save :generate_and_set_embedding, if: :should_generate_embedding?
  scope :top_level, -> { where(parent_id: nil) }

  # Method to get all ancestors (parents, grandparents, etc.)
  def ancestors
    parents = []
    current = self
    # Recursively go up the tree, adding each parent to the beginning of the array
    while current.parent
      parents.unshift(current.parent)
      current = current.parent
    end
    parents
  end

  def self.nearest_neighbors(query_embedding, limit: 5, distance_metric: '<->')
    dimensions = query_embedding.length # This must be the exact dimension of your model's embeddings (e.g., 384 for sentence-transformers)

    # 1. Cast the query embedding (Ruby Array) to PostgreSQL's vector type for the operator.
    #    The '?' placeholder is replaced by the Ruby array, which Rails converts to a PG array literal.
    query_vector_sql = "ARRAY[?]::float[]::vector(#{dimensions})"

    # 2. Crucially, cast the 'embedding' column (which is float[]) to vector type for the operator.
    #    This tells PostgreSQL to treat the stored float array as a vector for this operation.
    embedding_column_cast_sql = "embedding::vector(#{dimensions})"

    # 3. Construct the ORDER BY clause using the cast column and the operator
    order_by_clause = case distance_metric
                      when '<->' then "#{embedding_column_cast_sql} <-> " # L2 distance (Euclidean)
                      when '<#>' then "#{embedding_column_cast_sql} <#> " # Negative inner product
                      when '<=>' then "#{embedding_column_cast_sql} <=> " # Cosine distance
                      else raise ArgumentError, "Unsupported distance metric: #{distance_metric}"
                      end

    # The final SQL query
    find_by_sql([
      "SELECT *, (#{order_by_clause} #{query_vector_sql}) AS distance
       FROM rule_sections
       ORDER BY distance ASC
       LIMIT ?",
      query_embedding, # This replaces the first '?' in query_vector_sql
      limit
    ])
  end

  # Example usage:
  # some_rule_section = RuleSection.create!(content: "...", embedding: [0.1, 0.2, 0.3])
  # query_vector = [0.1, 0.2, 0.29]
  # nearest = RuleSection.nearest_neighbors(query_vector, limit: 3, distance_metric: '<->')
  # nearest.each { |rs| puts "ID: #{rs.id}, Distance: #{rs.distance}" }

  private
  def should_generate_embedding?
    # Only generate embedding if content is present and embedding is not already set
    text_content.present? && (embedding.nil? || embedding.empty? || text_content_changed?)
  end

  # Calls the embedding service and sets the embedding attribute
  def generate_and_set_embedding
    if text_content.present? # Ensure there's content to embed
      Rails.logger.info "Generating embedding for RuleSection #{id || 'new'}..."
      service = HuggingFaceEmbeddingService.new
      new_embedding = service.get_embedding(text_content) # Assuming 'content' is the text source

      if new_embedding.is_a?(Array) && new_embedding.all? { |e| e.is_a?(Float) }
        self.embedding = new_embedding
        Rails.logger.info "Embedding generated successfully for RuleSection #{id || 'new'}."
      else
        Rails.logger.error "Failed to generate valid embedding for RuleSection #{id || 'new'}. Embedding remains nil."
        # Optionally, you might want to raise an error or set a flag here
        self.embedding = nil # Ensure it's nil if generation failed
      end
    else
      self.embedding = nil # Clear embedding if content is blank
      Rails.logger.warn "Skipping embedding generation for RuleSection #{id || 'new'}: Content is blank."
    end
  end
 
end
