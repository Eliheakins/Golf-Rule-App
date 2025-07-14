require "application_system_test_case"

class UserQueriesTest < ApplicationSystemTestCase
  setup do
    @user_query = user_queries(:one)
  end

  test "visiting the index" do
    visit user_queries_url
    assert_selector "h1", text: "User queries"
  end

  test "should create user query" do
    visit user_queries_url
    click_on "New user query"

    fill_in "Content", with: @user_query.content
    fill_in "Feedback", with: @user_query.feedback
    fill_in "Response text", with: @user_query.response_text
    fill_in "Rule section", with: @user_query.rule_section_id
    fill_in "Session", with: @user_query.session_id
    fill_in "User", with: @user_query.user_id
    click_on "Create User query"

    assert_text "User query was successfully created"
    click_on "Back"
  end

  test "should update User query" do
    visit user_query_url(@user_query)
    click_on "Edit this user query", match: :first

    fill_in "Content", with: @user_query.content
    fill_in "Feedback", with: @user_query.feedback
    fill_in "Response text", with: @user_query.response_text
    fill_in "Rule section", with: @user_query.rule_section_id
    fill_in "Session", with: @user_query.session_id
    fill_in "User", with: @user_query.user_id
    click_on "Update User query"

    assert_text "User query was successfully updated"
    click_on "Back"
  end

  test "should destroy User query" do
    visit user_query_url(@user_query)
    click_on "Destroy this user query", match: :first

    assert_text "User query was successfully destroyed"
  end
end
