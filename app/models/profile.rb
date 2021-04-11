class Profile
  include Mongoid::Document
  include Mongoid::Timestamps
  field :permission, type: String

  has_many :users

  validates :permission, presence: true
end
