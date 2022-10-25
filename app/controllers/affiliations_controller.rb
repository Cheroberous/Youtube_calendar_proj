class AffiliationsController < ApplicationController
  before_action :set_affiliation, only: %i[ show edit update destroy ]

  # GET /affiliations or /affiliations.json
  def index
    @affiliations = Affiliation.all
  end

  # GET /affiliations/1 or /affiliations/1.json
  def show
  end

  # GET /affiliations/new
  def new
    @affiliation = Affiliation.new
    @cliente= current_user.id
    @manager= params[:manager]
  end

  # GET /affiliations/1/edit
  def edit
  end

 # GET /affiliations/accept?id=...

  def accept
    @affiliazione= Affiliation.find(params[:id])
    @affiliazione.update_attribute(:status, "accepted")
  end

  # POST /affiliations or /affiliations.json
  def create
    @affiliation = Affiliation.new(affiliation_params)
    @cliente= affiliation_params[:cliente]
    @manager= affiliation_params[:manager]
    respond_to do |format|
      if @affiliation.save
        format.html { redirect_to "/cliente/managerprofile?id="+@manager}
        format.json { render :show, status: :created, location: @affiliation }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @affiliation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /affiliations/1 or /affiliations/1.json
  def update
    respond_to do |format|
      if @affiliation.update(affiliation_params)
        format.html { redirect_to affiliation_url(@affiliation), notice: "Affiliation was successfully updated." }
        format.json { render :show, status: :ok, location: @affiliation }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @affiliation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /affiliations/1 or /affiliations/1.json
  def destroy
    @manager=@affiliation.manager
    @affiliation.destroy

    respond_to do |format|
      if current_user.ruolo=="cliente"
        format.html { redirect_to "/cliente/managerprofile?id="+@manager }
      else 
        format.html { redirect_to "/manager/affiliazioni"}
      end
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_affiliation
      @affiliation = Affiliation.find(params[:id])
      @affiliation.update_attribute(:status, "accepted")
      respond_to do |format|
        format.html { redirect_to "/manager/affiliazioni"}
      end
    end

    # Only allow a list of trusted parameters through.
    def affiliation_params
      params.require(:affiliation).permit(:cliente, :manager, :status)
    end
end
