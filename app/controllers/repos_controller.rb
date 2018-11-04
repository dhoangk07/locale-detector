class ReposController < ApplicationController
  # before_action :set_repos, only: %i[edit update show destroy]
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
  
  # def edit
  # end
  
  # def update
  # end
  
  # def show
  # end
  
  # def destroy
  # end
  
  private
    def set_repo
      @repo = Repo.find(params[:id])
    end
    
    def repo_params
      params.require(:repo).permit(:url, :name)
    end
end
