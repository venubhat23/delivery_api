class Analytics < ApplicationRecord
  belongs_to :user

  validates :total_likes, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_comments, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_shares, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_saves, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_clicks, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_reach, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :profile_visits, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :followers_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :following_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :media_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :reach_potential, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :earned_media, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def total_engagement_percentage
    return 0.0 if followers_count.zero?
    ((total_likes + total_comments + total_shares + total_saves).to_f / followers_count * 100).round(2)
  end

  def engagement_rate
    return 0.0 if media_count.zero? || followers_count.zero?
    total_interactions = total_likes + total_comments + total_shares + total_saves
    ((total_interactions.to_f / (media_count * followers_count)) * 100).round(2)
  end

  def average_interactions
    return 0 if media_count.zero?
    ((total_likes + total_comments + total_shares + total_saves).to_f / media_count).round(1)
  end

  def self.create_sample_data(user)
    create!(
      user: user,
      total_likes: rand(0..1000),
      total_comments: rand(0..500),
      total_shares: rand(0..100),
      total_saves: rand(0..200),
      total_clicks: rand(0..300),
      total_reach: rand(1..5000),
      profile_visits: rand(0..100),
      followers_count: rand(1..10000),
      following_count: rand(1..1000),
      media_count: rand(1..50),
      reach_potential: rand(0..1000),
      earned_media: rand(0..100)
    )
  end
end