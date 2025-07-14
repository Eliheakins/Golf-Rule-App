require "application_system_test_case"

class RuleSectionsTest < ApplicationSystemTestCase
  setup do
    @rule_section = rule_sections(:one)
  end

  test "visiting the index" do
    visit rule_sections_url
    assert_selector "h1", text: "Rule sections"
  end

  test "should create rule section" do
    visit rule_sections_url
    click_on "New rule section"

    fill_in "Parent", with: @rule_section.parent_id
    fill_in "Source url", with: @rule_section.source_url
    fill_in "Text content", with: @rule_section.text_content
    fill_in "Title", with: @rule_section.title
    click_on "Create Rule section"

    assert_text "Rule section was successfully created"
    click_on "Back"
  end

  test "should update Rule section" do
    visit rule_section_url(@rule_section)
    click_on "Edit this rule section", match: :first

    fill_in "Parent", with: @rule_section.parent_id
    fill_in "Source url", with: @rule_section.source_url
    fill_in "Text content", with: @rule_section.text_content
    fill_in "Title", with: @rule_section.title
    click_on "Update Rule section"

    assert_text "Rule section was successfully updated"
    click_on "Back"
  end

  test "should destroy Rule section" do
    visit rule_section_url(@rule_section)
    click_on "Destroy this rule section", match: :first

    assert_text "Rule section was successfully destroyed"
  end
end
