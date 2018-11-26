class ReposController < ApplicationController
  before_action :find_repo, only: %i[edit update show destroy subscribe unsubscribe ]
  skip_before_action :authenticate_user!, only: %i[show index]
  def index
    params[:search].present? ? @repos = Repo.search(params[:search]) : @repos = Repo.order(created_at: :DESC)
  end
  
  def new
    @repo = current_user.repos.build
  end
  
  def create
    @repo = current_user.repos.build(repo_params)
    if @repo.save
      Resque.enqueue(RunCloneCompare, @repo.id)
      Resque.enqueue(RunFetchDescriptionFromGithub, @repo.id)
      flash[:success] = "#{@repo.name.capitalize} created successfully"
      redirect_to repos_path
    else
      render :new
    end
  end 

  def edit
  end
  
  def update
    @repo.update_attributes(repo_params)
    if @repo.save
      flash[:success] = "#{@repo.name.capitalize} updated successfully"
      redirect_to repos_path
    else
      render :edit
    end
  end
  
  def show
  end
  
  def destroy
    path = @repo.cloned_source_path
    @repo.destroy
    Resque.enqueue(RunDeleteFolderGithub, path)
    flash[:danger] = "#{@repo.name.capitalize} deleted successfully"
    redirect_to repos_path
  end

  def subscribe
    @repo.subscribes.create(user_id: current_user.id)
    flash[:success] = "Subscribed #{@repo.name.capitalize} successfully"
    redirect_to repo_path(@repo)
  end

  def unsubscribe
    @repo.subscribes.where(user_id: current_user.id).destroy_all
    flash[:danger] = "Unsubscribed #{@repo.name.capitalize} successfully"
    redirect_to repo_path(@repo)
  end

  # def search
  #   @repos = Repo.search(params[:search])
  # end

  private
  def find_repo
      @repo = Repo.find(params[:id])
  end
  
  def repo_params
    params.require(:repo).permit(:url, :name, :user_id, :compare)
  end
end
