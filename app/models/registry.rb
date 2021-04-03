class Registry
  include Mongoid::Document
  include Mongoid::Timestamps
  field :state, type: String
  field :city, type: String
  field :school, type: String

  belongs_to :edition
  belongs_to :user

  validates :state, presence: true
  validates :city, presence: true
  validates :school, presence: true
  validates :edition_id, presence: true
  validates :user_id, presence: true
end
