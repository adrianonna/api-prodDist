class ProofsController < ApplicationController
  before_action :set_proof, only: [:show, :update, :destroy]

  # GET /proofs
  def index
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)

    if userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4" || userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
      if userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
        coordRegistries = Registry.where(:user_id => userAuth[0].id) # Retorna os registros de cada edições deste coordenador
        arrProofs = []
        if coordRegistries != nil
          coordRegistries.each { |cr|
            arrProofs += Proof.where(:edition_id => cr.edition_id) # Retorna todas as provas onde a edição dessas provas forem iguais a edição do registro do coord
          }
          render json: arrProofs
        end
      elsif userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4"
        @proofs = Proof.all
        render json: @proofs
      end
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end



    # @proofs = Proof.all
    # render json: @proofs
  end

  # GET /proofs/1
  def show
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)
    entrou = false

    if userAuth[0].profile_id === "606baa53e4eafb10df0a47a3" || userAuth[0].profile_id === "606bcba2e4eafb10df0a47a4"
      userRegistries = Registry.where(:user_id => userAuth[0].id)
      userRegistries.each { |cr|
        if cr.edition_id == @proof[:edition_id]
          entrou = true
          render json: @proof
        end
      }
      if entrou == false
        render json: {
          messages: "You don't have necessary authorization",
          is_success: false,
          data: {}
        }, status: :unauthorized
      end
    elsif userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4"
      render json: @proof
    end



    # render json: @proof
  end

  # POST /proofs
  def create
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)
    passouDescri = false
    entrou = false

    if userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4" || userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
      if userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
        coordRegistries = Registry.where(:user_id => userAuth[0].id) # Retorna os registros de cada edições deste coordenador
        coordRegistries.each { |cr|
          if cr.edition_id == proof_params[:edition_id]
            entrou = true
            @_params.each do |param|
              if param[0] == "description" && param[1].length > 5 && param[1].length < 301
                passouDescri = true
              end
            end
            if passouDescri == true
              @proof = Proof.new(proof_params)
              @proof.save
              render json: @proof, status: :created, location: @proof
            else
              render json: @proof.errors, status: :unprocessable_entity
            end
          end
        }
        if entrou == false
          render json: {
            messages: "You don't have necessary authorization",
            is_success: false,
            data: {}
          }, status: :unauthorized
        end
      elsif userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4"
        @_params.each do |param|
          if param[0] == "description" && param[1].length > 5 && param[1].length < 301
            passouDescri = true
          end
        end
        if passouDescri == true
          @proof = Proof.new(proof_params)
          @proof.save
          render json: @proof, status: :created, location: @proof
        else
          render json: @proof.errors, status: :unprocessable_entity
        end
      end
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end



    # @proof = Proof.new(proof_params)
    # if @proof.save
    #   render json: @proof, status: :created, location: @proof
    # else
    #   render json: @proof.errors, status: :unprocessable_entity
    # end
  end

  # PATCH/PUT /proofs/1
  def update
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)
    passouDescri = false
    entrou = false

    if userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4" || userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
      if userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
        coordRegistries = Registry.where(:user_id => userAuth[0].id)
        coordRegistries.each { |cr|
          if cr.edition_id == proof_params[:edition_id]
            entrou = true
            @_params.each do |param|
              if param[0] == "description" && param[1].length > 5 && param[1].length < 301
                passouDescri = true
              end
            end
            if passouDescri == true
              @proof.update(proof_params)
              render json: @proof
            else
              render json: @proof.errors, status: :unprocessable_entity
            end
          end
        }
        if entrou == false
          render json: {
            messages: "You don't have necessary authorization",
            is_success: false,
            data: {}
          }, status: :unauthorized
        end
      elsif userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4"
        @_params.each do |param|
          if param[0] == "description" && param[1].length > 5 && param[1].length < 301
            passouDescri = true
          end
        end
        if passouDescri == true
          @proof.update(proof_params)
          render json: @proof
        else
          render json: @proof.errors, status: :unprocessable_entity
        end
      end
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end



    # if @proof.update(proof_params)
    #   render json: @proof
    # else
    #   render json: @proof.errors, status: :unprocessable_entity
    # end
  end

  # DELETE /proofs/1
  def destroy
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)
    @questions = Question.where(:proof_id => @proof[:id])
    entrou = false

    if userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4" || userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"

      # arrDataEdition = @proof[:start_date_time].to_datetime.strftime('%d/%m/%Y').split('/')
      # arrDataNow = Time.new.to_datetime.strftime('%d/%m/%Y').split('/')
      # p "arrDataEdition= #{arrDataEdition}"
      # p "arrDataNow= #{arrDataNow}"

      if userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
        coordRegistries = Registry.where(:user_id => userAuth[0].id)
        coordRegistries.each { |cr|
          if cr.edition_id == @proof[:edition_id]
            entrou = true
            @questions.destroy
            @proof.destroy
            userProof = User.where(:id => @proof[:user_id]) # Retorna o usuário dessa prova
            userRegistries = Registry.where(:user_id => userProof[0].id) #pegar todos os registros do usuário a cima
            for registry in userRegistries # Para cada registro desse usuário
              if registry.edition_id == @proof[:edition_id] # Se a edição desse registro for igual a edição da prova a ser excluida
                registry.destroy
              end
            end
          end
        }
        if entrou == false
          render json: {
            messages: "You don't have necessary authorization",
            is_success: false,
            data: {}
          }, status: :unauthorized
        end
      elsif userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4"
        @questions.destroy
        @proof.destroy
      end
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end


    # @proof.destroy
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_proof
    @proof = Proof.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def proof_params
    params.require(:proof).permit(:description, :start_date_time, :end_date_time, :edition_id, :user_id)
  end
end
