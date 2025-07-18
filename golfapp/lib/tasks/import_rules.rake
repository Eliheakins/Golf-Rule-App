# lib/tasks/import_rules.rake

namespace :import do
  desc "Imports golf rules from the flat JSON file into the database, inferring hierarchy from rule_id and sanitizing text"
  task rules: :environment do
    require 'json'

    file_path = Rails.root.join('db', 'data', 'flattened_golf_rules.json') # Ensure this path is correct for your file

    unless File.exist?(file_path)
      puts "Error: JSON file not found at #{file_path}"
      exit 1
    end

    puts "Starting import of golf rules from #{file_path}..."

    json_data = JSON.parse(File.read(file_path))

    rule_section_lookup = {}

    # It's still good practice to sort, as it typically ensures top-level rules are processed
    # before their deeper descendants, which helps with the lookup.
    json_data.sort_by { |rule| rule['rule_id'] }.each do |rule_data|
      rule_id = rule_data['rule_id']
      rule_title = rule_data['rule_title']
      raw_rule_text = rule_data['rule_text']
      official_url = rule_data['official_url']

      # Sanitize the rule_text
      sanitized_rule_text = raw_rule_text.to_s.gsub(/[\n\r]+/, ' ').gsub(/\s+/, ' ').strip

      # --- Start of improved parent finding logic ---
      parent_rule_section = nil
      current_rule_id_parts = rule_id.split('_')

      # Iterate from the immediate parent's ID string up to the top-level parent's ID string
      # For "10_1_a", this will first check "10_1", then "10"
      # For "10_2_b_1", this will first check "10_2_b", then "10_2", then "10"
      (current_rule_id_parts.length - 1).downto(1) do |i|
        potential_parent_id_string = current_rule_id_parts[0...i].join('_')

        if rule_section_lookup.key?(potential_parent_id_string)
          parent_rule_section = rule_section_lookup[potential_parent_id_string]
          # We found the closest existing parent, so break out of the loop
          break
        end
      end
      # --- End of improved parent finding logic ---

      # Create the RuleSection record
      rule_section = RuleSection.create!(
        title: rule_title,
        text_content: sanitized_rule_text,
        source_url: official_url,
        parent: parent_rule_section # Will be nil if no parent was found (top-level rule or orphaned)
      )

      # Store the newly created RuleSection in our lookup hash
      rule_section_lookup[rule_id] = rule_section

      puts "Created: #{rule_section.title} (ID: #{rule_section.id}, Parent ID: #{rule_section.parent_id || 'None'})"
    end

    puts "Import complete!"
  rescue JSON::ParserError => e
    puts "Error parsing JSON: #{e.message}"
  rescue StandardError => e
    puts "An error occurred during import: #{e.message}"
    puts e.backtrace.join("\n")
  end
end