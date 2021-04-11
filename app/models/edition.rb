class Edition
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :description, type: String
  field :start_date_time, type: Time
  field :end_date_time, type: Time
  field :created_by, type: String

  has_and_belongs_to_many :registries
  has_many :proofs

  validates :title, presence: true
  validates :description, presence: true
  validates :start_date_time, presence: true
  validates :end_date_time, presence: true
end
