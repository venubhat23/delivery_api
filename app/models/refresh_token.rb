require 'securerandom'
require 'digest'

class RefreshToken < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :customer, optional: true

  scope :active, -> { where(revoked_at: nil).where('expires_at > ?', Time.current) }

  # Issues a new refresh token for a given entity (User or Customer)
  # Returns [raw_token, record]
  def self.issue_for(entity, user_agent: nil, ip_address: nil, expires_in: 30.days)
    raw_token = SecureRandom.hex(64)
    token_hash = Digest::SHA256.hexdigest(raw_token)

    record_attrs = {
      token_hash: token_hash,
      expires_at: Time.current + expires_in,
      user_agent: user_agent,
      created_by_ip: ip_address
    }

    if entity.is_a?(Customer)
      record_attrs[:customer] = entity
    elsif entity.is_a?(User)
      record_attrs[:user] = entity
    else
      raise ArgumentError, 'Unsupported entity for refresh token issuance'
    end

    record = RefreshToken.create!(record_attrs)
    [raw_token, record]
  end

  # Finds a valid (non-revoked, non-expired) refresh token by raw token string
  def self.find_valid_by_raw(raw_token)
    token_hash = Digest::SHA256.hexdigest(raw_token.to_s)
    token = RefreshToken.find_by(token_hash: token_hash)
    return nil if token.nil?
    return nil if token.revoked_at.present?
    return nil if token.expires_at <= Time.current
    token
  end

  # Revokes this token, optionally linking to a replacement token hash
  def revoke!(replaced_by_token_hash: nil)
    update!(revoked_at: Time.current, replaced_by_token_hash: replaced_by_token_hash)
  end

  def entity
    customer || user
  end
end