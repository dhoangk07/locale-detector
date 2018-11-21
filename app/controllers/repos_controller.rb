class ReposController < ApplicationController
  before_action :find_repo, only: %i[edit update show destroy subscribe unsubscribe ]
  def index
    @repos = Repo.order(created_at: :DESC)
  end
  
  def new
    @repo = current_user.repos.build
  end
  
  def create
    @repo = current_user.repos.build(repo_params)
    if @repo.save
      Resque.enqueue(RunCloneCompare, @repo.id)
      Resque.enqueue(RunFetchDescriptionFromGithub, @repo.id)
      flash[:success] = "#{@repo.name} created successfully"
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
      flash[:success] = "#{@repo.name} updated successfully"
      redirect_to repos_path
    else
      render :edit
    end
  end
  
  def show
  end
  
  def destroy
    @repo.destroy
    Resque.enqueue(RunDeleteFolderGithub, @repo.id)
    flash[:danger] = "#{@repo.name} deleted successfully"
    redirect_to repos_path
  end

  def subscribe
    @repo.subscribes.create(user_id: current_user.id)
    flash[:success] = "subscribed #{@repo.name} repo successfully"
    redirect_to repo_path(@repo)
  end

  def unsubscribe
    @repo.subscribes.where(user_id: current_user.id).destroy_all
    flash[:danger] = "unsubscribed #{@repo.name} repo successfully"
    redirect_to repo_path(@repo)
  end

  def search
    @repos = Repo.search(params[:search])
  end

  private
  def find_repo
    if params[:id] != 'search'
      @repo = Repo.find(params[:id])
    end
  end
  
  def repo_params
    params.require(:repo).permit(:url, :name, :user_id, :compare)
  end
end
