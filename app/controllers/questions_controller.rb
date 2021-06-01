class QuestionsController < ApplicationController
  before_action :set_question, only: [:show, :update, :destroy]

  # GET /questions
  def index
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)

    if userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4" || userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
      if userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
        coordRegistries = Registry.where(:user_id => userAuth[0].id) # Retorna os registros de cada edições deste coordenador
        arrProofs = []
        arrQuestions = []
        if coordRegistries != nil
          coordRegistries.each { |cr|
            arrProofs += Proof.where(:edition_id => cr.edition_id) # Retorna todas as provas onde a edição dessas provas forem iguais a edição do registro do coord
          }
          arrProofs.each { |p|
            arrQuestions += Question.where(:proof_id => p[:id])
          }
          render json: arrQuestions
        end
      elsif userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4"
        @questions = Question.all
        render json: @questions
      end
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end







    # @questions = Question.all
    # render json: @questions
  end


  def questoesParticipante
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)

      if userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
        userRegistries = Registry.where(:user_id => userAuth[0].id) # Retorna os registros de cada edições deste usuario
        arrProofs = []
        arrQuestions = []
        if userRegistries != nil
          userRegistries.each { |cr|
            arrProofs += Proof.where(:edition_id => cr.edition_id) # Retorna todas as provas onde a edição dessas provas forem iguais a edição do registro do coord
          }
          arrProofs.each { |p|
            arrQuestions += Question.where(:proof_id => p[:id])
          }
          render json: arrQuestions
        else
          render json: {
            messages: "You don't have necessary authorization",
            is_success: false,
            data: {}
          }, status: :unauthorized
        end
        elsif userAuth[0].profile_id === "606bcba2e4eafb10df0a47a4"
        render json: Question.collection.find({}, {projection: {answer1: 1, answer2: 1, answer3: 1,
                                                                            answer4: 1, answer5: 1, title: 1,
                                                                            created_at: 1, proof_id: 1, _id: 1}})
      else
        @questions = Question.all
        render json: @questions
      end
  end



  # GET /questions/1
  def show
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)
    entrou = false

    if userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4" || userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
      if userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
        proof = Proof.find(@question[:proof_id])
        coordRegistries = Registry.where(:user_id => userAuth[0].id) # Retorna os registros de cada edições deste coordenador
        coordRegistries.each { |cr|
          if cr.edition_id == proof.edition_id # Se a edição da prova for uma edição que o coord tem registro
            entrou = true
            render json: @question
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
        render json: @question
      end
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end





    # render json: @question
  end

  # POST /questions
  def create
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)
    passouTitle = false

    if userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4" || userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
      if userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
        proof = Proof.find(question_params[:proof_id]) # Prova relacionada a entidade questão
        coordRegistries = Registry.where(:user_id => userAuth[0].id) # Retorna todos os registros do coord
        coordRegistries.each { |cr|
          if cr.edition_id == proof.edition_id # Se a edição da prova for uma edição que o coord tem registro
            @question = Question.new(question_params)
            @_params.each do |param|
              if param[0] == "title" && param[1].length > 2 && param[1].length < 801
                passouTitle = true
              end
            end
            if passouTitle == true
              @proof = Proof.find(params[:proof_id])
              @proof.question_ids << @question.id
              @proof.update_attribute(:question_ids, @proof.question_ids)
              @question.save
              render json: @question, status: :created, location: @question
            else
              render json: {
                messages: "Contains invalid values",
                is_success: false,
                data: {}
              }, status: :unprocessable_entity
            end
          end
        }
        if @question == nil
          render json: {
            messages: "You don't have necessary authorization",
            is_success: false,
            data: {}
          }, status: :unauthorized
        end
      elsif userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4"
        @question = Question.new(question_params)
        @proof = Proof.find(params[:proof_id])
        @proof.question_ids << @question.id
        @proof.update_attribute(:question_ids, @proof.question_ids)
        @question.save
        render json: @question, status: :created, location: @question
      end
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end





    # @question = Question.new(question_params)
    # if @question.save
    #   render json: @question, status: :created, location: @question
    # else
    #   render json: @question.errors, status: :unprocessable_entity
    # end
  end

  # PATCH/PUT /questions/1
  def update
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)
    passouTitle = false
    entrou = false

    if userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4" || userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
      if userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
        proof = Proof.find(question_params[:proof_id])
        coordRegistries = Registry.where(:user_id => userAuth[0].id) # Retorna os registros de cada edições deste coordenador
        coordRegistries.each { |cr|
          if cr.edition_id == proof.edition_id # Se a edição da prova for uma edição que o coord tem registro
            entrou = true
            @_params.each do |param|
              if param[0] == "title" && param[1].length > 2 && param[1].length < 801
                passouTitle = true
              end
            end
            if passouTitle == true
              @question.update(question_params)
              render json: @question
            else
              render json: {
                messages: "Contains invalid values",
                is_success: false,
                data: {}
              }, status: :unprocessable_entity
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
          if param[0] == "title" && param[1].length > 2 && param[1].length < 801
            passouTitle = true
          end
        end
        if passouTitle == true
          @question.update(question_params)
          render json: @question
        else
          render json: {
            messages: "Contains invalid values",
            is_success: false,
            data: {}
          }, status: :unprocessable_entity
        end
      end
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end





    # if @question.update(question_params)
    #   render json: @question
    # else
    #   render json: @question.errors, status: :unprocessable_entity
    # end
  end

  # DELETE /questions/1
  def destroy
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)
    entrou = false

    if userAuth[0].profile_id === "606ba30ce4eafb0f8756b9e4" || userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
      if userAuth[0].profile_id === "606baa53e4eafb10df0a47a3"
        proof = Proof.find(@question[:proof_id])
        coordRegistries = Registry.where(:user_id => userAuth[0].id) # Retorna os registros de cada edições deste coordenador
        coordRegistries.each { |cr|
          if cr.edition_id == proof.edition_id # Se a edição da prova for uma edição que o coord tem registro
            entrou = true
            @question.destroy
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
        @question.destroy
      end
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end





    # @question.destroy
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_question
    @question = Question.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def question_params
    params.require(:question).permit(:title, :answer1, :answer2, :answer3, :answer4, :answer5, :right_answer, :proof_id)
  end
end
