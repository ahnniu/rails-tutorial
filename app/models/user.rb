class User < ActiveRecord::Base
  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[A-Za-z]+[A-Za-z0-9_.-]*@[A-Za-z0-9_.-]+\z/
  validates :email, presence: true, 
            format: { with: VALID_EMAIL_REGEX }, 
            uniqueness: { case_sensitive: false }
end
