class Question
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :answer1, type: String
  field :answer2, type: String
  field :answer3, type: String
  field :answer4, type: String
  field :answer5, type: String
  field :right_answer, type: String

  belongs_to :proof

  validates :title, presence: true
  validates :answer1, presence: true
  validates :answer2, presence: true
  validates :right_answer, presence: true
  validates :proof_id, presence: true
end
