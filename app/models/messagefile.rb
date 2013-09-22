class Messagefile < ActiveRecord::Base
  attr_accessible :file, :message_id
  has_attached_file :file,
    :path => ':rails_root/non-public/system/:attachment/:class/:id/:basename.:extension',
    :url => '/:class/:id/:attachment' 
  belongs_to :message
  validates_attachment_presence :file
  validates_attachment_size :file, :less_than => 10.megabytes
  validates_attachment_content_type :file, :content_type => ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/bmp', 'application/pdf', 'application/zip', 'application/doc']
end