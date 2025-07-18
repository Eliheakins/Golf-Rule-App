# config/initializers/pgvector_manual_type_registration.rb

Rails.application.config.after_initialize do
  # Only apply if the current database adapter is PostgreSQL
  if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
    begin
      # Check if ActiveRecord has successfully established a connection.
      # This is critical for db:create, db:drop, which connect to template dbs.
      if ActiveRecord::Base.connected?
        conn = ActiveRecord::Base.connection.raw_connection

        if conn.is_a?(PG::Connection) && defined?(Pgvector::PG)
          # Check if type_map_for_results is already set by pgvector
          # Sometimes it is, sometimes it's not. This is a robust way.
          unless conn.type_map_for_results && conn.type_map_for_results.is_a?(PG::BasicTypeMapForResults) && conn.type_map_for_results.send(:registry).keys.include?(Pgvector::PG::VECTOR_OID)
            registry = PG::BasicTypeRegistry.new.define_default_types
            Pgvector::PG.register_vector(registry)
            conn.type_map_for_results = PG::BasicTypeMapForResults.new(conn, registry: registry)
            Rails.logger.info "Pgvector: Manually registered vector type with PG connection."
          end
        end
      end
    rescue PG::ConnectionBad => e
      # This error is expected if the database doesn't exist yet (e.g., during db:create)
      # or if connection parameters are wrong. We just log a warning and skip type registration for now.
      Rails.logger.warn "Pgvector initializer skipped: Could not connect to database. (Error: #{e.message})"
    end
  end
end