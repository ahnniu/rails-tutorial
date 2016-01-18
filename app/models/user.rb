class User < ActiveRecord::Base
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[A-Za-z]+[A-Za-z0-9_.-]*@[A-Za-z0-9_-]+\.?[A-Za-z0-9_-]+\z/
  validates :email, presence: true, 
            format: { with: VALID_EMAIL_REGEX }, 
            uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, length: { minimum: 6 }

  def self.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def self.hash(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

private

  def create_remember_token
    self.remember_token = self.hash(self.new_remember_token)
  end
end
