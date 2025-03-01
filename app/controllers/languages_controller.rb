class LanguagesController < ApplicationController
  skip_before_action :authorized, only: [ :index, :show ]
  before_action :is_admin, only: [ :create, :update, :destroy ]

  def index
    render json: Language.all, status: :ok
  end

  def show
    render json: Language.find(params[:id]), status: :ok
  end

  def create
    language = Language.create(permitted_params)
    if params[:icon]
      language.icon.attach(params[:icon])
    end
    if language.save
      render json: language, status: :accepted
    else
      render json: language.errors, status: :bad_request
    end
  end

  def update
    render json: {}, status: :ok
  end

  def destroy
    render json: {}, status: :ok
  end

  private

  def permitted_params
    params.permit(:name)
  end

end
