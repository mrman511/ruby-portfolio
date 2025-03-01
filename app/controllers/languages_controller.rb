class LanguagesController < ApplicationController
  skip_before_action :authorized, only: [ :index, :show ]
  # before_action :is_admin, only: [ :create, :update, :destroy ]

  def index
    render json: Language.all, status: :ok
  end

  def show
    render json: {}, status: :ok
  end

  def create
    render json: {}, status: :ok
  end

  def update
    render json: {}, status: :ok
  end

  def destroy
    render json: {}, status: :ok
  end

end
