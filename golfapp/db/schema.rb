# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_14_193320) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "rule_sections", force: :cascade do |t|
    t.string "title"
    t.text "text_content"
    t.string "source_url"
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "embedding", default: [], array: true
    t.index ["parent_id"], name: "index_rule_sections_on_parent_id"
  end

  create_table "user_queries", force: :cascade do |t|
    t.text "content"
    t.text "response_text"
    t.string "session_id"
    t.integer "feedback"
    t.bigint "rule_section_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rule_section_id"], name: "index_user_queries_on_rule_section_id"
  end

  add_foreign_key "rule_sections", "rule_sections", column: "parent_id"
  add_foreign_key "user_queries", "rule_sections"
end
