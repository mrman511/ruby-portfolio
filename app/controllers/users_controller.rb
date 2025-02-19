class UsersController < ApplicationController
  # protect_from_forgery with: :null_session
  before_action :authorized, only: [ :index, :show, :update, :destroy ]
  # skip_before_action :authorized

  def index
    if current_user.has_role? :admin
      users = User.all
      render json: users
    else
      render json: { message: "Unauthorized to view content" }, status: :unauthorized
    end
  end

  def show
    user = User.find(params[:id])
    if current_user.id == user.id or current_user.has_role? :admin
      render json: user, status: :ok
    else
      render json: { message: "You are not authorized to view this content" }, status: :unauthorized
    end
  end

  def create
    user = User.create(permitted_params)
    if params[:avatar]
      user.avatar.attach(params[:avatar])
    end
    if user.save
      render json: user, status: :accepted
    else
      render json: user.errors, status: :bad_request
    end
  end

  def update
    user = User.find(params[:id])
    if current_user.id == user.id or current_user.has_role? :admin
      if user and !permitted_params.empty?
        update_user(user)
        render json: user, status: :ok
      else
        render json: user.errors, status: :unprocessable_entity
      end
    else
      render json: { message: "You are not authorized to view this content" }, status: :unauthorized
    end
  end

  def destroy
    user = User.find(params[:id])
    if current_user.id == user.id or current_user.has_role? :admin
      user.destroy
      render json: { message: "User Destroyed" }, status: :ok
    else
      render json: { message: "You are not authorized to view this content" }, status: :unauthorized
    end
  end

  private

  def update_user(user)
    if permitted_params[:first_name]
      user.update_attribute(:first_name, permitted_params[:first_name])
    end
    if permitted_params[:last_name]
      user.update_attribute(:last_name, permitted_params[:last_name])
    end
    if permitted_params[:email]
      user.update_attribute(:email, permitted_params[:email])
    end
    if permitted_params[:password]
      user.update_attribute(:password, permitted_params[:password])
    end
    if params[:avatar]
      user.avatar.purge
      user.avatar.attach(params[:avatar])
    end
  end

  def permitted_params
    params.permit(:first_name, :last_name, :email, :password)
  end
end
