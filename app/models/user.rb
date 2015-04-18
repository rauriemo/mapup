class User < ActiveRecord::Base
  has_many :pictures
  has_one :profile

  has_many :friendships
  has_many :friends, through: :friendships

  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id"
  has_many :inverse_friends, through: :inverse_friendships, source: :user

  validates_uniqueness_of :email
  validates_uniqueness_of :username

end
