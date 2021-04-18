class EditionsController < ApplicationController
  before_action :set_edition, only: [:show, :update, :destroy]

  # GET /editions
  def index
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)

    if userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4"
      @editions = Edition.all
      render json: @editions
    else
      registries = Registry.where(:user_id => userAuth[0].id)
      arr = []
      for r in registries
        arr += Edition.where(:id => r[:edition_id])
      end
      render json: arr
    end



    # @editions = Edition.all
    # render json: @editions
  end

  # GET /editions/1
  def show
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)
    entrou = false

    if userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4"
      render json: @edition
    else
      coordRegistries = Registry.where(:user_id => userAuth[0].id)
      coordRegistries.each { |cr|
        if cr.edition_id == @edition[:id]
          entrou = true
          render json: @edition
        end
      }
      if entrou == false
        render json: {
          messages: "You don't have necessary authorization",
          is_success: false,
          data: {}
        }, status: :unauthorized
      end
    end



    # render json: @edition
  end

  # POST /editions
  def create
    tokenUser = @_request.headers["X-User-Token"]
    user = User.where(:authentication_token => tokenUser)
    passouTitle = false
    passouDescri = false

    if user[0].profile_id === "606ba30ce4eafb0f8756b9e4" || user[0].profile_id === "606baa53e4eafb10df0a47a3"
      @_params.each do |param|
        if param[0] == "title" && param[1].length > 5 && param[1].length < 151
          passouTitle = true
        end
        if param[0] == "description" && param[1].length > 5 && param[1].length < 301
          passouDescri = true
        end
      end
      if passouTitle == true && passouDescri == true
        @edition = Edition.new(edition_params)
        @edition.registry_ids = []
        @edition.proof_ids = []
        @edition.created_by = user[0].id
        @edition.save
        render json: @edition, status: :created, location: @edition
      else
        render json: @edition.errors, status: :unprocessable_entity
      end
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end





    # @edition = Edition.new(edition_params)
    #
    # if @edition.save
    #   render json: @edition, status: :created, location: @edition
    # else
    #   render json: @edition.errors, status: :unprocessable_entity
    # end
  end

  # PATCH/PUT /editions/1
  def update
    tokenUser = @_request.headers["X-User-Token"]
    @user = User.where(:authentication_token => tokenUser)
    passouTitle = false
    passouDescri = false

    if @user[0].profile_id === "606ba30ce4eafb0f8756b9e4" || @user[0].profile_id === "606baa53e4eafb10df0a47a3"
      @_params.each do |param|
        if param[0] == "title" && param[1].length > 5 && param[1].length < 151
          passouTitle = true
        end
        if param[0] == "description" && param[1].length > 5 && param[1].length < 301
          passouDescri = true
        end
      end

      if passouTitle == true && passouDescri == true
        @edition.update(edition_params)
        render json: @edition
      else
        render json: @edition.errors, status: :unprocessable_entity
      end
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end




    # if @edition.update(edition_params)
    #   render json: @edition
    # else
    #   render json: @edition.errors, status: :unprocessable_entity
    # end
  end

  # DELETE /editions/1
  def destroy
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)
    @proof = Proof.where(:edition_id => params[:id]) # todas as provas que fazem parte da edição a ser excluida
    @registries = Registry.where(:edition_id => params[:id])# todos os registros da edição a ser excluída

    if userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4"

      # dateTime = @edition[:start_date_time].to_datetime
      # strData = dateTime.strftime("%H:%M:%S:%p")
      # strTime = dateTime.strftime("%d/%m/%Y")
      # arrData= strTime.split('/')
      # p "arrData= #{arrData}"
      # p "teste= #{arrData[2].to_i > 1}"

      @proof.each.each do |proof|
        @question = Question.where(:proof_id => proof.id) # retorna todas as questões da prova de cada iteração
        @question.destroy_all
      end
      @proof.destroy_all
      @registries.destroy_all
      @edition.destroy
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end


    

    # @edition.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_edition
      @edition = Edition.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def edition_params
      params.require(:edition).permit(:title, :description, :start_date_time, :end_date_time)
    end
end
