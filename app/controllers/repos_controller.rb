class ReposController < ApplicationController
  before_action :set_repo, only: %i[edit update show destroy subscribe unsubscribe]
  def index
    @repos = Repo.all
  end
  
  def new
    @repo = Repo.new
  end
  
  def create
    @repo = Repo.new(repo_params)
    if @repo.save
      redirect_to repos_path
    else
      flash.now[:error] = @repo.errors.full_messages.join(", ")
    end
  end 

  def subscribe
    @repo.subscribes.create(user_id: current_user.id)
    redirect_to repo_path(@repo)
  end

  def unsubscribe
    @repo.subscribes.where(user_id: current_user.id).destroy_all
    redirect_to repo_path(@repo)
  end

  # def edit
  # end
  
  # def update
  # end
  
  def show
  end
  
  # def destroy
  # end
  
  private
    def set_repo
      @repo = Repo.find(params[:id])
    end
    
    def repo_params
      params.require(:repo).permit(:url, :name, :user_id, :compare)
    end
end
