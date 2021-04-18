class Proof
  include Mongoid::Document
  include Mongoid::Timestamps
  field :description, type: String
  field :start_date_time, type: Time
  field :end_date_time, type: Time
  belongs_to :edition
  belongs_to :user

  belongs_to :edition
  belongs_to :user
  has_and_belongs_to_many :questions

  validates :description, presence: true
  validates :edition_id, presence: true
  validates :user_id, presence: true
end
