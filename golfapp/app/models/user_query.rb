class UserQuery < ApplicationRecord
  has_and_belongs_to_many :rule_sections

  # Assuming UserQuery has a 'content' field that holds the text to be embedded
  validates :content, presence: true

  validates :feedback, inclusion: { in: [-1, 0, 1], allow_nil: false }
  
  THUMBS_UP = 1
  THUMBS_DOWN = -1
  NO_FEEDBACK = 0

  before_save :generate_and_set_embedding, if: :should_generate_embedding?

  def self.nearest_neighbors(query_embedding, limit: 5, distance_metric: '<->')
    RuleSection.nearest_neighbors(query_embedding, limit: limit, distance_metric: distance_metric)
  end

  private

  def should_generate_embedding?
    # Only generate embedding if content is present and embedding is not already set
    content.present? && (embedding.nil? || embedding.empty? || content_changed?)
  end

  def generate_and_set_embedding
    if content.present? # Ensure there's content to embed
      Rails.logger.info "Generating embedding for UserQuery #{session_id || 'new'}..."
      service = HuggingFaceEmbeddingService.new
      new_embedding = service.get_embedding(content) # Assuming 'content' is the text source

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
