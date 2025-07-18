class CreateJoinTableRuleSectionsUserQueries < ActiveRecord::Migration[8.0]
  def change
    create_join_table :rule_sections, :user_queries do |t|
      t.index [:rule_section_id, :user_query_id], name: 'index_rule_sections_user_queries_on_rule_section_and_user_query'
      t.index [:user_query_id, :rule_section_id], name: 'index_user_queries_rule_sections_on_user_query_and_rule_section'
    end
  end
end
