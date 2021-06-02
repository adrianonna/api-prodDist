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
      arrEditionCoord = []
      for registry_id in userAuth[0].registry_ids
        registroCoordenador = Registry.where(:id => registry_id)
        edicaoCoordenador = Edition.where(:id => registroCoordenador[0].edition_id)
        arrEditionCoord += edicaoCoordenador
      end
      arrRegistriesUsuarios = []
      for edicaoCoordenador in arrEditionCoord
        registrosUsuarios = Registry.where(:edition_id => edicaoCoordenador.id)
        arrRegistriesUsuarios += registrosUsuarios
      end
      render json: arrRegistriesUsuarios
    else
      registries = Registry.where(:user_id => userAuth[0].id)
      render json: registries
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
      if userAuth[0].id != @registry[:user_id]
        render json: {
          messages: "You don't have necessary authorization",
          is_success: false,
          data: {}
        }, status: :unauthorized
      else
        render json: @registry
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
            userRegistro = User.where(:id => registry_params[:user_id])
            if userRegistro[0].profile_id === "606bcba2e4eafb10df0a47a4"
              @registry.arrResposta = []
            end
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
            userRegistro = User.where(:id => registry_params[:user_id])
            if userRegistro[0].profile_id === "606bcba2e4eafb10df0a47a4"
              @registry.arrResposta = []
            end
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
  # O adm pode editar qualquer registro
  # O coord pode editar apenas registros que estejam na mesma edicão que a dele
  # O participante não pode editar nenhum registro
  def update
    tokenUser = @_request.headers['X-User-Token']
    userAuth = User.where(:authentication_token => tokenUser)

    if userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4" || userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
      if userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
        registriesCoord = Registry.where(:user_id => userAuth[0].id)
        for r in registriesCoord
          if r.edition_id == @registry[:edition_id]
            p "O PARTICIPANTE ESTA VINCULADO NA MESMA EDICAO DA(O) COORDENADOR(A) OU É SEU PROPRIO REGISTRO"
            edition = Edition.where(:id => @registry[:edition_id]) # Só irá retornar uma, pois cada registro está está vinculado a uma edição
            arrDataEdition = edition[0].end_date_time.to_datetime.strftime('%d/%m/%Y').split('/') # Aqui tenho a array com data final da edicao do registro
            arrDataRegistry = Time.new.to_datetime.strftime('%d/%m/%Y').split('/') # Aqui tenho o array com a data que esta sendo modificado
            if arrDataRegistry[2] <= arrDataEdition[2]
              if arrDataRegistry[1] <= arrDataEdition[1]
                if arrDataRegistry[0] <= arrDataEdition[0]
                  if @registry.update(registry_params)
                    render json: @registry
                  else
                    render json: @registry.errors, status: :unprocessable_entity
                  end
                elsif arrDataRegistry[0] > arrDataEdition[0] && arrDataRegistry[1] < arrDataEdition[1]
                  if @registry.update(registry_params)
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
            p "O PARTICIPANTE NÃO ESTA VINCULADO NA MESMA EDICAO DA(O) COORDENADOR(A) OU NÃO É SEU PROPRIO REGISTRO"
            render json: {
              messages: "You don't have necessary authorization",
              is_success: false,
              data: {}
            }, status: :unauthorized
          end
        end
      else
        p "SE CAIR AQUI É PQ É ADM"
        edition = Edition.where(:id => @registry[:edition_id]) # Só irá retornar uma, pois cada registro está está vinculado a uma edição
        arrDataEdition = edition[0].end_date_time.to_datetime.strftime('%d/%m/%Y').split('/') # Aqui tenho a array com data final da edicao do registro
        arrDataRegistry = Time.new.to_datetime.strftime('%d/%m/%Y').split('/') # Aqui tenho o array com a data que esta sendo modificado
        if arrDataRegistry[2] <= arrDataEdition[2]
          if arrDataRegistry[1] <= arrDataEdition[1]
            if arrDataRegistry[0] <= arrDataEdition[0]
              if @registry.update(registry_params)
                render json: @registry
              else
                render json: @registry.errors, status: :unprocessable_entity
              end
            elsif arrDataRegistry[0] > arrDataEdition[0] && arrDataRegistry[1] < arrDataEdition[1]
              if @registry.update(registry_params)
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
    user = User.where(:id => @registry[:user_id]) # Pega o usuário do registro
    possuiReg = false

    if userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4" || userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
      if userAuth[0].profile_id === "606baa53e4eafb10df0a47a3" # coord
        registriesCoord = Registry.where(:user_id => userAuth[0].id) # Pega todos os registros do coord
        if user[0].profile_id === "606ba30ce4eafb0f8756b9e4" || user[0].profile_id === "606baa53e4eafb10df0a47a3" # Se o usuário do registro for coord ou adm
          render json: {
            messages: "You don't have necessary authorization",
            is_success: false,
            data: {}
          }, status: :unauthorized
        else # Se o usuário do registro for participante
          edition = Edition.where(:id => @registry[:edition_id]) # Retorna a edição do participante baseado no registro dele
          p "edition= #{edition[0]}"
          p "edition.registry_ids= #{edition[0].registry_ids}"
          for r in registriesCoord
            if r.edition_id == @registry[:edition_id] # Verifica se o usuário participante possui registro na mesma edicão do coord
              possuiReg = true
              p "ANTES edition[0].registry_ids= #{edition[0].registry_ids}"
              for registry_id in edition[0].registry_ids # percorre array de registros da edicao do participante para remover desta edicao
                if registry_id == @registry[:id]
                  p "registry_id= #{registry_id}"
                  p "@registry.id= #{@registry[:id]}"
                  p "edition[0].registry_ids.class= #{edition[0].registry_ids.class}"
                  edition[0].registry_ids.delete(@registry[:id])
                  edition[0].registry_ids.delete(registry_id)
                  p "DEPOIS edition[0].registry_ids= #{edition[0].registry_ids}"
                end
              end
              @registry.destroy
            end
          end
          if possuiReg == false
            render json: {
              messages: "You don't have necessary authorization",
              is_success: false,
              data: {}
            }, status: :unauthorized
          end
        end
      else
        @registry.destroy
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
    params.require(:registry).permit(:state, :city, :school, :edition_id, :user_id, :arrResposta)
  end
end
