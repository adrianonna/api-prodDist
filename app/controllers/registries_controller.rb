class RegistriesController < ApplicationController
  before_action :set_registry, only: [:show, :update, :destroy]

  # GET /registries
  def index
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)

    if userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4" # admin
      @registries = Registry.all
      render json: @registries
    elsif userAuth[0].profile_id === "606baa53e4eafb10df0a47a3" # coord
      arrEdition = []
      for registry_id in userAuth[0].registry_ids
        registroCoordenador = Registry.where(:id => registry_id)
        edicaoCoordenador = Edition.where(:id => registroCoordenador[0].edition_id)
        arrEdition += edicaoCoordenador
      end
      arrRegistries= []
      for edicaoCoordenador in arrEdition
        registrosUsuarios = Registry.where(:edition_id => edicaoCoordenador.id)
        arrRegistries += registrosUsuarios
      end
      render json: arrRegistries
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end



    # @registries = Registry.all
    # render json: @registries
  end

  # GET /registries/1
  def show
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)

    if userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4"
      render json: @registry
    elsif userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
      coordRegistries = Registry.where(:user_id => userAuth[0].id)
      userRegistries = Registry.where(:user_id => @registry[:user_id])
      if userRegistries != nil && coordRegistries != nil
        for cr in coordRegistries
          for ur in userRegistries
            if cr.edition_id == ur.edition_id
              render json: @registry
            else
              render json: {
                messages: "You don't have necessary authorization",
                is_success: false,
                data: {}
              }, status: :unauthorized
            end
          end
        end
      else
        render json: {
          messages: "You don't have necessary authorization",
          is_success: false,
          data: {}
        }, status: :unauthorized
      end
    else
      userRegistries = Registry.where(:user_id => @registry[:user_id])
      if userAuth[0].id != @registry[:user_id]
        render json: {
          messages: "You don't have necessary authorization",
          is_success: false,
          data: {}
        }, status: :unauthorized
      else
        render json: userRegistries
      end
    end





    # render json: @registry
  end

  # POST /registries
  def create
    tokenUser = @_request.headers['X-User-Token']
    userAuth = User.where(:authentication_token => tokenUser)

    if userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4" || userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
      @edition = Edition.find(params[:edition_id])
      arrDataEdition = @edition["end_date_time"].to_datetime.strftime('%d/%m/%Y').split('/')
      arrDataRegistry = Time.new.to_datetime.strftime('%d/%m/%Y').split('/')
      if arrDataRegistry[2] <= arrDataEdition[2]
        if arrDataRegistry[1] <= arrDataEdition[1]
          if arrDataRegistry[0] <= arrDataEdition[0]
            @registry = Registry.new(registry_params)
            @edition.registry_ids << @registry.id
            @edition.update_attribute(:registry_ids, @edition.registry_ids)
            @user = User.find(params[:user_id])
            @user.registry_ids << @registry.id
            @user.update_attribute(:registry_ids, @user.registry_ids)
              if @registry.save
                render json: @registry, status: :created, location: @registry
            else
              render json: @registry.errors, status: :unprocessable_entity
            end
          elsif arrDataRegistry[0] > arrDataEdition[0] && arrDataRegistry[1] < arrDataEdition[1]
            @registry = Registry.new(registry_params)
            @edition.registry_ids << @registry.id
            @edition.update_attribute(:registry_ids, @edition.registry_ids)

            @user = User.find(params[:user_id])
            @user.registry_ids << @registry.id
            @user.update_attribute(:registry_ids, @user.registry_ids)
            if @registry.save
              render json: @registry, status: :created, location: @registry
            else
              render json: @registry.errors, status: :unprocessable_entity
            end
          else
            render json: {
              messages: "You don't have necessary authorization",
              is_success: false,
              data: {}
            }, status: :unauthorized
          end
        else
          render json: {
            messages: "You don't have necessary authorization",
            is_success: false,
            data: {}
          }, status: :unauthorized
        end
      else
        render json: {
          messages: "You don't have necessary authorization",
          is_success: false,
          data: {}
        }, status: :unauthorized
      end
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end





    # @registry = Registry.new(registry_params)
    # if @registry.save
    #   render json: @registry, status: :created, location: @registry
    # else
    #   render json: @registry.errors, status: :unprocessable_entity
    # end
  end

  # PATCH/PUT /registries/1
  def update
    tokenUser = @_request.headers['X-User-Token']
    userAuth = User.where(:authentication_token => tokenUser)

    if userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4" || userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
      p "registry_params[:edition_id]= #{registry_params[:edition_id]}"
      p "registry_params[:state]= #{registry_params[:state]}"
      p "@registry= #{@registry[:edition_id]}"
      edition = Edition.where(:id => @registry[:edition_id]) # Só irá retornar uma, pois cada registro está está vinculado a uma edição
      arrDataEdition = edition[0].end_date_time.to_datetime.strftime('%d/%m/%Y').split('/')
      arrDataRegistry = Time.new.to_datetime.strftime('%d/%m/%Y').split('/')
      if arrDataRegistry[2] <= arrDataEdition[2]
        if arrDataRegistry[1] <= arrDataEdition[1]
          if arrDataRegistry[0] < arrDataEdition[0]
            if @registry.update(registry_params) # Verificar se é necessário fazer a mesma condicão do create para as datas
              render json: @registry
            else
              render json: @registry.errors, status: :unprocessable_entity
            end
          else
            render json: @registry.errors, status: :unprocessable_entity
          end
        else
          render json: @registry.errors, status: :unprocessable_entity
        end
      else
        render json: @registry.errors, status: :unprocessable_entity
      end
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end













    # if @registry.update(registry_params)
    #   render json: @registry
    # else
    #   render json: @registry.errors, status: :unprocessable_entity
    # end
  end

  # DELETE /registries/1
  def destroy
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)
    edition = Edition.where(:id => @registry[:edition_id]) # Retorna a edição desse registro
    proofs = Proof.where(:edition_id => edition[0].id) # Pego todas as provas dessa edição

    p "edition= #{edition[0]}"
    p "edition.registry_ids= #{edition[0].registry_ids}"

    if userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4" || userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
      if proofs.present?
        for p in proofs # Para cada prova dessa edição
          if p.user_id == @registry[:user_id] # Se a prova for do usuário do registro a ser excluído
            p.destroy
            question = Question.where(:proof_id => p.id) # Retorna todas as questões da prova a ser excluida
            question.destroy_all
          end
        end
        @registry.destroy
      else
        p "ANTES edition[0].registry_ids= #{edition[0].registry_ids}"
        for registry_id in edition[0].registry_ids #apagar o registro do array de registros da edicao, não está funcionando
          if registry_id == @registry.id
            p "registry_id= #{registry_id}"
            p "@registry.id= #{@registry.id}"
            p edition[0].registry_ids.class
            edition[0].registry_ids.delete(registry_id)
            # unset(edition[0].registry_ids[registry_id])
          end
        end
        p "DEPOIS edition[0].registry_ids= #{edition[0].registry_ids}"
        # @registry.destroy
      end

    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end








    # @registry.destroy
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_registry
    @registry = Registry.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def registry_params
    params.require(:registry).permit(:state, :city, :school, :edition_id, :user_id)
  end
end
