#encoding: utf-8

# == Schema Information
#
# Table name: subjects
#
#  id                  :integer          not null, primary key
#  title               :string
#  content             :text
#  user_id             :integer
#  chapter_id          :integer
#  created_at          :datetime
#  updated_at          :datetime
#  lastcomment         :datetime
#  admin               :boolean          default(FALSE)
#  important           :boolean          default(FALSE)
#  section_id          :integer
#  wepion              :boolean          default(FALSE)
#  category_id         :integer
#  question_id         :integer
#  contest_id          :integer
#  problem_id          :integer
#  lastcomment_user_id :integer
#
class Subject < ActiveRecord::Base

  # BELONGS_TO, HAS_MANY

  has_many :messages, dependent: :destroy
  belongs_to :user
  belongs_to :chapter, optional: true
  belongs_to :section, optional: true
  belongs_to :category, optional: true
  belongs_to :question, optional: true
  belongs_to :contest, optional: true
  belongs_to :problem, optional: true
  belongs_to :lastcomment_user, class_name: "User"
  has_many :followingsubjects, dependent: :destroy
  has_many :following_users, through: :followingsubjects, source: :user
  has_many :myfiles, as: :myfiletable, dependent: :destroy
  has_many :fakefiles, as: :fakefiletable, dependent: :destroy

  # VALIDATIONS

  validates :title, presence: true, length: { maximum: 255 }
  validates :content, presence: true, length: { maximum: 16000 } # Limited to 8000 in the form but end-of-lines count twice
  validates :user_id, presence: true
  validates :lastcomment, presence: true
  validates :lastcomment_user_id, presence: true

end
