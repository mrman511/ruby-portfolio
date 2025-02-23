class ProjectsController < ApplicationController
  skip_before_action :authorized, only: [ :index, :show ]
  before_action :is_admin, only: [ :create, :update, :destroy ]

  def index
    render json: Project.all, status: :ok
  end

  def show
    render json: Project.find(params[:id]), status: :ok
  end

  def create
    project = Project.create(permitted_params)
    if params[:image]
      project.image.attach(params[:image])
    end
    if project.save
      render json: project, status: :accepted
    else
      render json: project.errors, status: :bad_request
    end
  end

  def update
    @project = Project.find(params[:id])
    if update_project
      render json: @project, status: :accepted
    else
      render json: @project, status: :bad_request
    end
  end

  def destroy
    project = Project.find(params[:id])
    project.destroy
    render json: { message: "Project destroyed" }, status: :ok
  end

  private

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
