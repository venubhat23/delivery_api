class Api::V1::AnalyticsController < ApplicationController
  before_action :set_user, only: [:show, :create, :update, :destroy, :dashboard]
  before_action :set_analytics, only: [:show, :update, :destroy]

  # GET /api/v1/analytics
  def index
    @analytics = Analytics.all
    render json: @analytics.map { |analytic| format_analytics_response(analytic) }
  end

  # GET /api/v1/analytics/:id
  def show
    render json: format_analytics_response(@analytics)
  end

  # GET /api/v1/users/:user_id/analytics
  # GET /api/v1/analytics/dashboard
  def dashboard
    @analytics = @user.analytics
    
    if @analytics.nil?
      # Create sample analytics data if none exists
      @analytics = Analytics.create_sample_data(@user)
    end

    render json: {
      user: {
        id: @user.id,
        name: @user.name,
        email: @user.email,
        username: "@#{@user.name.downcase.gsub(' ', '')}#{@user.id}",
        avatar_url: "/assets/default-avatar.png"
      },
      analytics: format_analytics_response(@analytics),
      recent_posts: []
    }
  end

  # POST /api/v1/analytics
  def create
    @analytics = @user.build_analytics(analytics_params)

    if @analytics.save
      render json: format_analytics_response(@analytics), status: :created
    else
      render json: { errors: @analytics.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/analytics/:id
  def update
    if @analytics.update(analytics_params)
      render json: format_analytics_response(@analytics)
    else
      render json: { errors: @analytics.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/analytics/:id
  def destroy
    @analytics.destroy
    head :no_content
  end

  # POST /api/v1/analytics/generate_sample
  def generate_sample
    user = User.find(params[:user_id])
    
    # Delete existing analytics if any
    user.analytics&.destroy
    
    # Create new sample data
    @analytics = Analytics.create_sample_data(user)
    
    render json: format_analytics_response(@analytics), status: :created
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end

  private

  def set_user
    @user = User.find(params[:user_id]) if params[:user_id]
    @user ||= User.find(params[:id]) if params[:id] && action_name == 'dashboard'
  end

  def set_analytics
    @analytics = Analytics.find(params[:id])
  end

  def analytics_params
    params.require(:analytics).permit(
      :total_likes, :total_comments, :total_shares, :total_saves,
      :total_clicks, :total_reach, :profile_visits, :followers_count,
      :following_count, :media_count, :reach_potential, :earned_media
    )
  end

  def format_analytics_response(analytics)
    {
      id: analytics.id,
      user_id: analytics.user_id,
      total_likes: analytics.total_likes,
      total_comments: analytics.total_comments,
      total_shares: analytics.total_shares,
      total_saves: analytics.total_saves,
      total_clicks: analytics.total_clicks,
      total_reach: analytics.total_reach,
      profile_visits: analytics.profile_visits,
      followers_count: analytics.followers_count,
      following_count: analytics.following_count,
      media_count: analytics.media_count,
      reach_potential: analytics.reach_potential,
      earned_media: analytics.earned_media,
      total_engagement: analytics.total_engagement_percentage,
      engagement_rate: analytics.engagement_rate,
      average_interactions: analytics.average_interactions,
      created_at: analytics.created_at,
      updated_at: analytics.updated_at
    }
  end
end