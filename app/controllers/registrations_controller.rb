class RegistrationsController < Devise::RegistrationsController
  before_action :ensure_params_exist, only: :create
  # sign up
  def create
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)
    userBanco = User.first
    user = User.new user_params
    passouNome = false
    passouCpf =  false
    emailRepetido = false
    passouSenha = nil


    if userBanco == nil # Se for a primeiro execução, não vai existir usuário no banco e vai entrar aqui
      perfil = Profile.new
      perfil.permission = 'Administrador'
      perfil.save
      user.profile_id = perfil.id
      user_params.each do |param|
        if param[0] == "name" && param[1].scan(/\w+/).length == 2
          passouNome = true
        end
        if param[0] == "cpf" && param[1].length == 11
          passouCpf = true
        end
      end
      if passouNome == true && passouCpf == true
        if user.save
          render json: {
            messages: "Sign Up Successfully",
            is_success: true,
            data: {user: user}
          }, status: :ok
        else
          render json: {
            messages: "Sign Up Failded",
            is_success: false,
            data: {}
          }, status: :unprocessable_entity
        end
      else
        render json: {
          messages: "Contains invalid values",
          is_success: false,
          data: {}
        }, status: :unprocessable_entity
      end
    elsif userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4" || userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
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
      if passouNome == true && passouCpf == true && emailRepetido == false && passouSenha.class == String && user.save
        render json: {
          messages: "Sign Up Successfully",
          is_success: true,
          data: {user: user}
        }, status: :ok
      else
        render json: {
          messages: "Sign Up Failded",
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



    # user = User.new user_params
    # if user.save
    #   render json: {
    #     messages: "Sign Up Successfully",
    #     is_success: true,
    #     data: {user: user}
    #   }, status: :ok
    # else
    #   render json: {
    #     messages: "Sign Up Failded",
    #     is_success: false,
    #     data: {}
    #   }, status: :unprocessable_entity
    # end
  end

  private
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name, :cpf, :telephone, :profile_id)
  end

  def ensure_params_exist
    return if params[:user].present?
    render json: {
      messages: "Missing Params",
      is_success: false,
      data: {}
    }, status: :bad_request
  end
end