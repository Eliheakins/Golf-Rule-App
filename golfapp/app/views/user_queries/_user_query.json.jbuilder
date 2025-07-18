json.extract! user_query, :id, :content, :response_text, :user_id, :session_id, :feedback, :rule_section_id, :created_at, :updated_at
json.url user_query_url(user_query, format: :json)
