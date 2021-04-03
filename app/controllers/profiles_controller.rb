class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :update, :destroy]

  # GET /profiles
  def index
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)

    if userAuth[0].profile_id === 1
      @profiles = Profile.all
      render json: @profiles
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end



    # @profiles = Profile.all
    # render json: @profiles
  end

  # GET /profiles/1
  def show
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)

    if userAuth[0].profile_id === 1
      render json: @profile
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end




    # render json: @profile
  end

  # POST /profiles
  def create
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)
    if userAuth[0].profile_id === 1
      @profile = Profile.new(profile_params)
      if @profile.save
        render json: @profile, status: :created, location: @profile
      else
        render json: @profile.errors, status: :unprocessable_entity
      end
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end




    # @profile = Profile.new(profile_params)
    # if @profile.save
    #   render json: @profile, status: :created, location: @profile
    # else
    #   render json: @profile.errors, status: :unprocessable_entity
    # end
  end

  # PATCH/PUT /profiles/1
  def update
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)

    if userAuth[0].profile_id === 1
      if @profile.update(profile_params)
        render json: @profile
      else
        render json: @profile.errors, status: :unprocessable_entity
      end
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end






    # if @profile.update(profile_params)
    #   render json: @profile
    # else
    #   render json: @profile.errors, status: :unprocessable_entity
    # end
  end

  # DELETE /profiles/1
  def destroy
    tokenUser = @_request.headers["X-User-Token"]
    userAuth = User.where(:authentication_token => tokenUser)

    if userAuth[0].profile_id === 1
      @profile.destroy
    else
      render json: {
        messages: "You don't have necessary authorization",
        is_success: false,
        data: {}
      }, status: :unauthorized
    end




    # @profile.destroy
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_profile
    @profile = Profile.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def profile_params
    params.require(:profile).permit(:permission)
  end
end
