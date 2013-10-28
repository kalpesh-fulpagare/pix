class PostsController < ApplicationController
  before_action :find_post, only: [:show, :edit, :update, :destroy]
  def index
    @posts = Post.page(params[:page])
  end

  def show
    @users_json =  User.select("id AS value, CONCAT(first_name, ' ', last_name) AS label").where("is_admin = ?", false).to_json
    @comments = @post.comments.select("id, user_id, content, created_at").includes(:user).order("created_at DESC").limit(10)
  end

  def new
    @post = current_user.posts.new
    @post.photos.build
  end

  def create
    @post = current_user.posts.new(params[:post].permit!)
    if @post.save
      flash[:success] = "Post created successfully"
      redirect_to "/dashboard"
    else
      @post.photos.build
      render 'new'
    end
  end

  def edit
    @post.photos.build
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: 'Post was successfully updated.'
    else
      @post.photos.build
      render 'edit'
    end
  end

  def mark_favourite
    @dom = current_user.mark_unmark_favourite(params)
    respond_to do |format|
      format.js
    end
  end


  def destroy
    if (current_user.is_admin || @post.user_id == current_user.id) && @post.destroy
      flash[:success] = "Post deleted successfully"
      redirect_to "/"
    else
      flash[:error] = "Unable to delete comment, please try after some time"
    end
  end

  def delete_image
    photo = Photo.find_by_id(params[:photo_id])
    if photo.present?
      photo.delete
      redirect_to edit_post_path(params[:id])
    end
  end

  private
  def post_params
    params.require(:post).permit! #(:category_id, :sub_category_id, :share, :title, :description, :location, :price, :name, :contact_number,:photo)
  end

  def find_post
    @post = Post.find_by_id(params[:id])
    unless @post
      respond_to do |format|
        format.html{
          redirect_to "/dashboard", alert: "Post not found"
        }
        format.js{
          render js: "displayFlash('Post not found', 'alert-error');"
        }
      end
    end
  end

end
