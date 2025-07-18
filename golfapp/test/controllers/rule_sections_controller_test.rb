require "test_helper"

class RuleSectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rule_section = rule_sections(:one)
  end

  test "should get index" do
    get rule_sections_url
    assert_response :success
  end

  test "should get new" do
    get new_rule_section_url
    assert_response :success
  end

  test "should create rule_section" do
    assert_difference("RuleSection.count") do
      post rule_sections_url, params: { rule_section: { parent_id: @rule_section.parent_id, source_url: @rule_section.source_url, text_content: @rule_section.text_content, title: @rule_section.title } }
    end

    assert_redirected_to rule_section_url(RuleSection.last)
  end

  test "should show rule_section" do
    get rule_section_url(@rule_section)
    assert_response :success
  end

  test "should get edit" do
    get edit_rule_section_url(@rule_section)
    assert_response :success
  end

  test "should update rule_section" do
    patch rule_section_url(@rule_section), params: { rule_section: { parent_id: @rule_section.parent_id, source_url: @rule_section.source_url, text_content: @rule_section.text_content, title: @rule_section.title } }
    assert_redirected_to rule_section_url(@rule_section)
  end

  test "should destroy rule_section" do
    assert_difference("RuleSection.count", -1) do
      delete rule_section_url(@rule_section)
    end

    assert_redirected_to rule_sections_url
  end
end
