class Language::FrameworksController < ApplicationController
  skip_before_action :authorized, only: [ :index, :show ]
  before_action :set_up
  before_action :is_admin, only: [ :create, :update, :destroy, :add_use_case, :remove_use_case ]

  def index
    render json: @language.frameworks, status: :ok
  end

  def show
    render json: @framework, status: :ok
  end

  def create
    @framework = Framework.new(permitted_params)
    @framework.language = @language
    if params[:icon].present?
      set_icon
    end
    if @framework.save
      render json: @framework, status: :accepted
    else
      render json: @framework.errors, status: :bad_request
    end
  end

  def update
    if update_framework
      render json: @framework, status: :accepted
    else
      render json: @framework, status: :bad_request
    end
  end

  def destroy
    @framework.destroy
    render json: { message: "Framework destroyed" }, status: :ok
  end

  def add_use_case
    if use_case_params.present?
      use_case = @framework.add_use_case(use_case_params)
      render json: @framework, status: :accepted
    else
      render json: @framework, status: :bad_request
    end
  end

  def remove_use_case
    @framework.remove_use_case(params[:use_case_id])
    render json: @framework, status: :accepted
  end

  private

  def set_up
    set_language
    set_framework
  end

  def set_language
    @language = Language.find(params[:language_id])
  end

  def set_framework
    if params[:id]
      @framework = Framework.find(params[:id])
      if @framework.language != @language
        raise ActiveRecord::RecordNotFound
      end
    end
  end

  def set_icon
    @framework.icon.purge
    @framework.icon.attach(params[:icon])
  end

  def update_framework
    updated = false
    if !permitted_params.empty?
      @framework.update permitted_params
      updated = true
    end
    if params[:icon]
      set_icon
      updated = true
    end
    updated
  end

  def permitted_params
    params.permit(:name)
  end

  def use_case_params
    params.permit(:name)
  end
end
