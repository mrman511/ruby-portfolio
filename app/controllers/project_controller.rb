class ProjectController < ApplicationController
  def index
    render json: Project.all, status: :ok
  end

  def show
    render json: Project.find(parmas[:id]), status: ok
  end

  def create
    project = Project.create(permitted_params)
    if params[:image]
      project.image.attach(params[:image])
    end
    if project.save
      render json: project, status: accepted
    else
      render json: project.errors, status: :bad_request
    end
  end

  def update
    project = Project.find(parmas[:id])
    update_user(project)
  end

  private

  def update_project(project)
    if permitted_params[:title]
      user.update_attribute(:title, permitted_params[:title])
    end
    if permitted_params[:description]
      user.update_attribute(:description, permitted_params[:description])
    end
    if permitted_params[:github_url]
      user.update_attribute(:github_url, permitted_params[:github_url])
    end
    if permitted_params[:live_url]
      user.update_attribute(:live_url, permitted_params[:live_url])
    end
    if params[:image]
      project.image.purge
      project.image.attach(params[:image])
    end
  end

  def permitted_params
    params.permit(:title, :description, :github_url, :live_url)
  end
end

