class Edition
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :description, type: String
  field :start_date_time, type: Time
  field :end_date_time, type: Time

  has_many :edition
  has_many :proof

  validates :title, presence: true
  validates :description, presence: true
  validates :start_date_time, presence: true
  validates :end_date_time, presence: true
end
