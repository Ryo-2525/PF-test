class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: %i(show destroy)

  def index
    @posts = Post.all.limit(10).includes(:photos, :user, :likes).order('created_at DESC')
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    if params[:images]
      params[:images].each do |img|
        if Photo.picture_size?(img)
          @post.save
          @post.photos.create(image: img)
          redirect_to root_path
          flash[:notice] = "投稿が保存されました"
        else
          redirect_to root_path
          flash[:alert] = "投稿に失敗しました。画像サイズが1MB超えてます。"
        end
      end
    else
      redirect_to root_path
      flash[:alert] = "投稿に失敗しました"
    end
  end

  def show
    @photos = @post.photos
    @likes = @post.likes.includes(:user)
  end

  def destroy
    if @post.user == current_user
      flash[:notice] = "投稿が削除されました" if @post.destroy
    else
      flash[:alert] = "削除に失敗しました"
    end
    redirect_to root_path
  end

  private
    def post_params
      params.require(:post).permit(:caption).merge(user_id: current_user.id)
    end

    def set_post
      @post = Post.find_by(id: params[:id])
    end
end
