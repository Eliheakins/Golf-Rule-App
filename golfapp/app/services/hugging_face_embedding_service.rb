# app/services/hugging_face_embedding_service.rb
require 'faraday'
require 'json'

class HuggingFaceEmbeddingService
  MODEL_API_URL = "https://ta18b9e24sua1twz.us-east-1.aws.endpoints.huggingface.cloud"
  def initialize(api_token: ENV.fetch("HUGGING_FACE_API_TOKEN"))
    @api_token = api_token
    @connection = Faraday.new(url: MODEL_API_URL) do |faraday|
      faraday.request :json 
      faraday.response :json
      faraday.adapter Faraday.default_adapter 
    end
  end

  def get_embedding(text)
    response = @connection.post do |req|
      req.headers['Authorization'] = "Bearer #{@api_token}"
      req.body = { inputs: text.to_s, options: { wait_for_model: true } } 
    end

    if response.success?
      embedding = response.body.first
      if embedding.is_a?(Array) && embedding.all? { |e| e.is_a?(Float) }
        embedding
      else
        Rails.logger.error "HuggingFaceEmbeddingService: Unexpected embedding format: #{response.body.inspect}"
        nil
      end
    else
      Rails.logger.error "HuggingFaceEmbeddingService: API request failed: #{response.status} - #{response.body['error']}"
      nil
    end
  rescue Faraday::Error => e
    Rails.logger.error "HuggingFaceEmbeddingService: Network error: #{e.message}"
    nil
  end
end