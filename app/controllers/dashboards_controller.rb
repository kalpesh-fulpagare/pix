class DashboardsController < ApplicationController
  def show
    @posts = Post.fetch_posts params, current_user, params[:search]
  end
end
