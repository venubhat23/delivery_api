import React from 'react';
import './InstagramAnalytics.css';

const InstagramAnalytics = ({ profileData, recentPosts, analyticsData }) => {
  return (
    <div className="instagram-analytics-container">
      {/* Profile Section */}
      <div className="profile-section">
        <div className="profile-header">
          <div className="profile-avatar">
            <img src={profileData?.avatar || '/default-avatar.png'} alt="Profile" />
          </div>
          <div className="profile-info">
            <h2 className="profile-name">{profileData?.name || 'aksharshetty01012025'}</h2>
            <p className="profile-category">{profileData?.category || 'Beauty & Lifestyle'}</p>
            <div className="profile-stats">
              <span>{profileData?.followers || '1'} Followers</span>
              <span>{profileData?.following || '21'} Following</span>
            </div>
            <div className="profile-details">
              <p className="profile-bio">{profileData?.bio || 'Inteligent Smart power'}</p>
              <p className="profile-location">{profileData?.location || 'USA'}</p>
            </div>
            <div className="profile-metrics">
              <div className="metric">
                <span className="metric-label">Engagement Rate:</span>
                <span className="metric-value">{profileData?.engagementRate || '0.0%'}</span>
              </div>
              <div className="metric">
                <span className="metric-label">Earned Media:</span>
                <span className="metric-value">{profileData?.earnedMedia || '1'}</span>
              </div>
              <div className="metric">
                <span className="metric-label">Average Interactions:</span>
                <span className="metric-value">{profileData?.avgInteractions || '0.0%'}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Recent Posts Section */}
      <div className="recent-posts-section">
        <h3 className="section-title">Recent Posts</h3>
        <div className="recent-posts-grid">
          {recentPosts && recentPosts.map((post, index) => (
            <div key={index} className="post-card">
              <div className="post-header">
                <div className="post-avatar">
                  <img src={post.avatar || profileData?.avatar || '/default-avatar.png'} alt="Influencer" />
                </div>
                <div className="post-info">
                  <h4 className="post-title">Influencer</h4>
                  <span className="post-handle">@{post.handle || 'anybrand'}</span>
                  <span className="post-date">{post.date || '13March'}</span>
                </div>
                <button className="view-analytics-btn">View full Analytics</button>
              </div>
              <div className="post-content">
                <p className="post-description">{post.description || 'Lorem ipsum dolor sit....'}</p>
                <div className="post-stats">
                  <div className="stat">
                    <span className="stat-icon">♥</span>
                    <span className="stat-value">{post.likes || '37.8K'}</span>
                  </div>
                  <div className="stat">
                    <span className="stat-icon">💬</span>
                    <span className="stat-value">{post.comments || '248'}</span>
                  </div>
                  <div className="stat">
                    <span className="stat-icon">📤</span>
                    <span className="stat-value">{post.shares || '234'}</span>
                  </div>
                  <div className="stat">
                    <span className="stat-icon">🔗</span>
                    <span className="stat-value">{post.links || '122'}</span>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Campaign Analytics Section */}
      <div className="campaign-analytics-section">
        <h3 className="section-title">Campaign Analytics</h3>
        <div className="analytics-grid">
          <div className="analytics-card">
            <h4 className="analytics-value">{analyticsData?.totalLikes || '0'}</h4>
            <p className="analytics-label">Total Likes</p>
          </div>
          <div className="analytics-card">
            <h4 className="analytics-value">{analyticsData?.totalComments || '0'}</h4>
            <p className="analytics-label">Total Comments</p>
          </div>
          <div className="analytics-card">
            <h4 className="analytics-value">{analyticsData?.totalEngagement || '0.0%'}</h4>
            <p className="analytics-label">Total Engagement</p>
          </div>
          <div className="analytics-card">
            <h4 className="analytics-value">{analyticsData?.totalReach || '1'}</h4>
            <p className="analytics-label">Total Reach</p>
          </div>
          <div className="analytics-card">
            <h4 className="analytics-value">{analyticsData?.totalShares || '0'}</h4>
            <p className="analytics-label">Total Shares</p>
          </div>
          <div className="analytics-card">
            <h4 className="analytics-value">{analyticsData?.totalSaves || '15'}</h4>
            <p className="analytics-label">Total Saves</p>
          </div>
          <div className="analytics-card">
            <h4 className="analytics-value">{analyticsData?.totalClicks || '25'}</h4>
            <p className="analytics-label">Total Clicks</p>
          </div>
          <div className="analytics-card">
            <h4 className="analytics-value">{analyticsData?.profileVisits || '0'}</h4>
            <p className="analytics-label">Profile Visits</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default InstagramAnalytics;