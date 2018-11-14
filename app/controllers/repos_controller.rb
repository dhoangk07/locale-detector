class ReposController < ApplicationController
  before_action :set_repo, only: %i[edit update show destroy subscribe unsubscribe]
  def index
    @repos = Repo.order(created_at: :DESC)
    if params[:search].present?
      @repos = @repos.search(params[:search])
    end
  end
  
  def new
    @repo = current_user.repos.build
  end
  
  def create
    @repo = current_user.repos.build(repo_params)
    @repo.url << ".git" 
    if @repo.save
      flash[:success] = "You've already successfully created #{@repo.name}"
      redirect_to repos_path
    else
      render :new
    end

  end 

  def subscribe
    @repo.subscribes.create(user_id: current_user.id)
    flash[:success] = "You've already successfully subscribed for #{@repo.name}"
    redirect_to repo_path(@repo)
  end

  def unsubscribe
    @repo.subscribes.where(user_id: current_user.id).destroy_all
    flash[:danger] = "You've already unsubscribed for #{@repo.name}"
    redirect_to repo_path(@repo)
  end

  def edit
  end
  
  def update
    @repo.update_attributes(repo_params)
    if @repo.save
      flash[:success] = "You've already successfully updated for #{@repo.name}"
      redirect_to repos_path
    else
      render :edit
    end
  end
  
  def show
    @repo.fetch_from_github
  end
  
  def destroy
    @repo.destroy
    @repo.delete_folder_github
    flash[:danger] = "You've already successfully deleted #{@repo.name}"
    redirect_to repos_path
  end

  private
  def set_repo
    @repo = Repo.find(params[:id])
  end
  
  def repo_params
    params.require(:repo).permit(:url, :name, :user_id, :compare)
  end
end
