class UserQueriesController < ApplicationController
  before_action :set_user_query, only: %i[ show edit update destroy ]

  # GET /user_queries or /user_queries.json
  def index
    @user_queries = UserQuery.all
  end

  # GET /user_queries/1 or /user_queries/1.json
  def show
  end

  # GET /user_queries/new
  def new
    @user_query = UserQuery.new
  end

  # GET /user_queries/1/edit
  def edit
  end

  # POST /user_queries or /user_queries.json
  def create
    @user_query = UserQuery.new(user_query_params)

    respond_to do |format|
      if @user_query.save
        if @user_query.embedding.present?
          nearest_neighbors = RuleSection.nearest_neighbors(@user_query.embedding, limit: 5, distance_metric: '<->')
          @user_query.rule_sections.concat(nearest_neighbors)
        else
          # Log a warning for debugging
          Rails.logger.warn "Embedding not generated for UserQuery #{@user_query.id}. Skipping nearest neighbors association."
          # Optionally, add a flash message to inform the user (e.g., if finding rules is critical)
          flash[:alert] = "User query created, but could not find related rules due to an embedding issue."
        end

        format.html { redirect_to @user_query, notice: "User query was successfully created." }
        format.json { render :show, status: :created, location: @user_query }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user_query.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_queries/1 or /user_queries/1.json
  def update
    if @user_query.update(user_query_params)
      respond_to do |format|
        format.html { redirect_to @user_query, notice: "Feedback updated successfully." } 
        format.turbo_stream
        format.json { render :show, status: :ok, location: @user_query }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@user_query, partial: "user_queries/user_query", locals: { user_query: @user_query }) }
        format.json { render json: @user_query.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_queries/1 or /user_queries/1.json
  def destroy
    @user_query.destroy!

    respond_to do |format|
      format.html { redirect_to user_queries_path, status: :see_other, notice: "User query was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_query
      @user_query = UserQuery.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def user_query_params
      params.expect(user_query: [ :content, :response_text, :user_id, :session_id, :feedback, :rule_section_id ])
    end
end
