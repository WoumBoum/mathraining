class Notif < ActiveRecord::Base
  attr_accessible :submission_id

  belongs_to :user
  belongs_to :submission

  validates :submission_id, presence: true
  validates :user_id, presence: true, uniqueness: { scope: :submission_id }
end
