class ArticlesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    articles = Article.all.includes(:user).order(created_at: :desc)
    render json: articles, each_serializer: ArticleListSerializer
  end

  def show
    # 1. Initialization
    session[:page_views] ||= 0

    # 2. Page View Count
    session[:page_views] += 1

    # 3. Access Control
    if session[:page_views] <= 3
      article = Article.find(params[:id])
      render json: article
    else
      # 4. Paywall
      render json: { error: "Maximum pageview limit reached" }, status: :unauthorized
    end
  end

  private

  def record_not_found
    render json: { error: "Article not found" }, status: :not_found
  end
end