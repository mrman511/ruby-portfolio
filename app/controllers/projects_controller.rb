class ProjectsController < ApplicationController
  skip_before_action :authorized, only: [ :index, :show ]
  before_action :is_admin
  skip_before_action :is_admin, only: [ :index, :show ]
  before_action :set_up
  skip_before_action :set_up, only: [ :index, :create, :add_framework_use_case, :remove_framework_use_case ]
  before_action :set_project_framework, only: [ :add_framework_use_case, :remove_framework_use_case ]

  def index
    render json: Project.all, status: :ok
  end

  def show
    render json: @project, status: :ok
  end

  def create
    project = Project.create(permitted_params)
    if params[:image]
      project.image.attach(params[:image])
    end
    if project.save
      render json: project, status: :ok
    else
      render json: project.errors, status: :bad_request
    end
  end

  def update
    if update_project
      render json: @project, status: :ok
    else
      render json: @project, status: :bad_request
    end
  end

  def add_framework
    @project.add_framework(@framework.id)
    render json: @project, status: :ok
  end

  def remove_framework
    @project.remove_framework(@framework.id)
    render json: @project, status: :ok
  end

  def add_framework_use_case
    @project_framework.add_use_case(params[:use_case_name])
    render json: @project, status: :ok
  end

  def remove_framework_use_case
    @project_framework.remove_use_case(params[:use_case_id])
    render json: @project, status: :ok
  end

  def destroy
    @project.destroy
    render json: { message: "Project destroyed" }, status: :ok
  end

  private

  def set_up
    if params[:id]
      set_project
    end
    if params[:framework_id]
      set_framework
    end
  end

  def set_project
    @project = Project.find(params[:id])
  end

  def set_framework
    @framework = Framework.find(params[:framework_id])
  end

  def set_project_framework
    @project_framework = ProjectFramework.where(project_id: params[:id], framework_id: params[:framework_id]).first
  end

  def update_project
    updated = false
    if !permitted_params.empty?
      @project.update permitted_params
      updated = true
    end
    if params[:image]
      @project.image.purge
      @project.image.attach(params[:image])
      updated = true
    end
    updated
  end

  def permitted_params
    params.permit(:title, :description, :github_url, :live_url, :role)
  end
end
