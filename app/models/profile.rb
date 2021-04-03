class Profile
  include Mongoid::Document
  include Mongoid::Timestamps
  field :permission, type: String

  has_many :user

  validates :permission, presence: true
end
