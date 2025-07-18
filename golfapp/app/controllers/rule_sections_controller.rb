class RuleSectionsController < ApplicationController
  before_action :set_rule_section, only: %i[ show edit update destroy ]

  # GET /rule_sections or /rule_sections.json
  def index
    @top_level_rule_sections = RuleSection.top_level.includes(:children)
    @top_level_rule_sections = @top_level_rule_sections.sort_by do |rs|
      rs.title.scan(/\d+|\D+/).map { |s| s.match?(/\d/) ? s.to_i : s }
    end
  end

  # GET /rule_sections/1 or /rule_sections/1.json
  def show
  end

  # GET /rule_sections/new
  def new
    @rule_section = RuleSection.new
  end

  # GET /rule_sections/1/edit
  def edit
  end

  # POST /rule_sections or /rule_sections.json
  def create
    @rule_section = RuleSection.new(rule_section_params)

    respond_to do |format|
      if @rule_section.save
        format.html { redirect_to @rule_section, notice: "Rule section was successfully created." }
        format.json { render :show, status: :created, location: @rule_section }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @rule_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rule_sections/1 or /rule_sections/1.json
  def update
    respond_to do |format|
      if @rule_section.update(rule_section_params)
        format.html { redirect_to @rule_section, notice: "Rule section was successfully updated." }
        format.json { render :show, status: :ok, location: @rule_section }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @rule_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rule_sections/1 or /rule_sections/1.json
  def destroy
    @rule_section.destroy!

    respond_to do |format|
      format.html { redirect_to rule_sections_path, status: :see_other, notice: "Rule section was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rule_section
      @rule_section = RuleSection.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def rule_section_params
      params.expect(rule_section: [ :title, :text_content, :source_url, :parent_id ])
    end
end
