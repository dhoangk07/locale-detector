class ReposController < ApplicationController
  before_action :find_repo, only: %i[edit update show destroy subscribe unsubscribe stop_send_email_for_user_subscribed ]
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
      Resque.enqueue(RunClone, @repo.id)
      Resque.enqueue(RunUpdateReposTable)
      Resque.enqueue(RunChangeDataOnLocaleKeysTable, @repo.id)
      Resque.enqueue(RunCompare, @repo.id)
      Resque.enqueue(RunSendEmail, @repo.id)
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
    repo_id = @repo.id
    @repo.destroy
    Resque.enqueue(RunDeleteFolderGithub, path)
    Resque.enqueue(RunDeleteLocaleKeysOfRepo, repo_id)
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

  def stop_send_email_for_user_subscribed
    @repo.stop_send_email(current_user)
    flash[:danger] = "Unsubscribed #{@repo.name.capitalize} successfully"
    redirect_to repo_path(@repo)
  end

  private
    def find_repo
        @repo = Repo.find(params[:id])
    end
    
    def repo_params
      params.require(:repo).permit(:url, :name, :user_id, :compare)
    end
end
