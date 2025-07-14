# config/initializers/pgvector.rb
require 'pgvector'

ActiveSupport.on_load(:active_record) do
  # This registers the 'vector' type with ActiveRecord's PostgreSQL adapter
  # using the correct type class for pgvector gem version 0.2.2
  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.register_type 'vector', Pgvector::Vector::Type.new
end