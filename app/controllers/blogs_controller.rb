class BlogsController < ApplicationController
  require 'redis'
  REDIS.del("ranking")
  def index
    @lists = List.all
    
    @rankings = REDIS.zrevrange("ranking", 0, 2, :with_scores => true)
  end

  def new
    @list = List.new
  end

  def create
    @list = List.new(list_params)
    @list.user_id = current_user.id
    if @list.save
      redirect_to blog_path(@list.id)
    end
  end

  def show
    @list = List.find(params[:id])
    REDIS.zincrby "ranking", 1, "#{@list.id}"
    @rankings = REDIS.zrevrange("ranking", 0, 2, :with_scores => true)
  end

  def edit
    @list = List.find(params[:id])
    if @list.user != current_user
      redirect_to root_path
    end
  end

  def update
    @list = List.find(params[:id])
    if @list.update(list_params)
      redirect_to blog_path(@list.id)
    end
  end

  def destroy
    @list = List.find(params[:id])
    @list.destroy
    redirect_to root_path
  end

  private
  def list_params
    params.require(:list).permit(:title, :body)
  end
end
