class ReviewsController < ApplicationController
  before_action :set_review, only: %i[ show edit update destroy ]
  before_action:are_you_a_client
  # GET /reviews or /reviews.json
  def index
    @reviews = Review.all
    @recensito= params[:id]
    @reviewer= current_user.id
    if @recensito
      is_it_a_manager(User.find(@recensito))
    end
  end

  # GET /reviews/1 or /reviews/1.json
  def show
  end

  # GET /reviews/new
  def new
    @review = Review.new
    @reviewer= current_user.id
    @reviewed= params[:reviewed]
    is_it_a_manager(User.find(@reviewed))
  end

  # GET /reviews/1/edit
  def edit
    @reviewer= current_user.id
    @reviewed= Review.find(params[:id]).reviewed
  end

  # POST /reviews or /reviews.json
  def create
    @review = Review.new(review_params)
    @reviewed= review_params[:reviewed]
    respond_to do |format|
      if @review.save
        format.html { redirect_to "/reviews?id=" + @reviewed}
        format.json { render :show, status: :created, location: @review }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reviews/1 or /reviews/1.json
  def update
    @reviewed= review_params[:reviewed]
    if @review.reviewer.to_i==current_user.id 
      respond_to do |format|
        if @review.update(review_params)
          format.html { redirect_to "/reviews?id=" + @reviewed }
          format.json { render :show, status: :ok, location: @review }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @review.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /reviews/1 or /reviews/1.json
  def destroy
    if @review.reviewer.to_i==current_user.id 
      @review.destroy
    end

    respond_to do |format|
      format.html { redirect_to '/reviews?id='+@review.reviewed}
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @review = Review.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def review_params
      params.require(:review).permit(:reviewer, :reviewed, :stars, :testo)
    end
end
