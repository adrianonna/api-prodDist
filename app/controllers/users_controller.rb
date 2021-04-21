class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /users
  def index
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)

    if userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4"
      @users = User.all
      render json: @users
    elsif userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
      coordRegistries = Registry.where(:user_id => userAuth[0])
      arrUsers = []
      for r in coordRegistries
        users = User.where(:id => r.user_id) # Retorna todos os usuários das inscrições que o coord é inscrito
        arrUsers += users
      end
      render json: arrUsers
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end







    # @users = User.all
    # render json: @users
  end

  # GET /users/1
  def show
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)

    if userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4"
      render json: @user
    elsif userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
      userRegistries = Registry.where(:user_id => @user[:id])
      coordRegistries = Registry.where(:user_id => userAuth[0].id)
      if userRegistries != nil && coordRegistries != nil
        for cr in coordRegistries
          for ur in userRegistries
            if cr.edition_id == ur.edition_id # Se algum registro do coord for de alguma edição que o registro o user também faça parte desta edição
              render json: @user
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
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end







    # render json: @user
  end

  # POST /users
  # def create
  #   @user = User.new(user_params)

  #   if @user.save
  #     render json: @user, status: :created, location: @user
  #   else
  #     render json: @user.errors, status: :unprocessable_entity
  #   end
  # end

  # PATCH/PUT /users/1
  def update
    tokenUser = @_request.headers["X-User-Token"]
    user = User.where(:authentication_token => tokenUser)
    passouNome = false
    passouCpf =  false
    emailRepetido = false
    passouSenha = nil

    if user[0].profile_id === "606ba30ce4eafb0f8756b9e4" || user[0].profile_id === "606baa53e4eafb10df0a47a3"
      user_params.each do |param|
        if param[0] == "name" && param[1].scan(/\w+/).length == 2
          passouNome = true
        end
        if param[0] == "cpf" && param[1].length == 11
          passouCpf = true
          User.all.each do |u|
            emailRepetido = true if u.email === user.email
            passouCpf = false if u.cpf === user.cpf
          end
        end
        if param[0] == "password" || param[0] == "password_confirmation"
          passouSenha = param[1][/^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,10}$/]
        end
      end
      if passouNome == true && passouCpf == true && emailRepetido == false && passouSenha.class == String
        if @user.update(user_params)
          render json: @user
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      else
        render json: {
          messages: "Contains invalid values",
          is_success: false,
          data: {}
        }, status: :unprocessable_entity
      end
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end









    # if @user.update(user_params)
    #   render json: @user
    # else
    #   render json: @user.errors, status: :unprocessable_entity
    # end
  end

  # DELETE /users/1
  def destroy
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)
    p "@user= #{@user}"
    @coordRegistries = Registry.where(:user_id => @user[:id])

    if userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
      if @user[:id] == userAuth[0].id
        render json: {
          messages: "You don't have necessary authorization",
          is_success: false,
          data: {}
        }, status: :unauthorized
      else
        @coordRegistries.destroy
        @user.destroy
      end
    elsif userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4"
      @coordRegistries.destroy
      @user.destroy
    end








    # @user.destroy
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name, :cpf, :telephone, :profile_id)
  end
end
