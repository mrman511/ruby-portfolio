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
    @language = Language.find(params[:id])
    if update_language
      render json: @language, status: :accepted
    else
      render json: @language, status: :bad_request
    end
  end

  def destroy
    render json: {}, status: :ok
  end

  private

  def update_language
    updated = false
    if !permitted_params.empty?
      @language.update permitted_params
      updated = true
    end
    if params[:icon]
      @language.icon.purge
      @language.icon.attach(params[:icon])
      updated = true
    end
    updated
  end

  def permitted_params
    params.permit(:name)
  end

end
