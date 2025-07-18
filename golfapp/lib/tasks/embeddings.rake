# lib/tasks/embeddings.rake
namespace :embeddings do
  desc "Generates embeddings for all RuleSection records that don't have one"
  task populate_rule_sections: :environment do
    Rails.logger.info "Starting embedding population for RuleSections..."
    service = HuggingFaceEmbeddingService.new

    RuleSection.find_each do |rule_section|
      unless rule_section.embedding.present? && rule_section.embedding.is_a?(Array) && rule_section.embedding.any?
        Rails.logger.info "Processing RuleSection ID: #{rule_section.id}"
        embedding = service.get_embedding(rule_section.text_content)
        if embedding.is_a?(Array) && embedding.all? { |e| e.is_a?(Float) }
          rule_section.update_columns(embedding: embedding) # Use update_columns to skip callbacks
          Rails.logger.info "  - Embedding populated for ID: #{rule_section.id}"
        else
          Rails.logger.error "  - Failed to populate embedding for ID: #{rule_section.id}. API response invalid."
        end
      else
        Rails.logger.info "  - RuleSection ID: #{rule_section.id} already has an embedding. Skipping."
      end
    end

    Rails.logger.info "Embedding population complete."
  end
end