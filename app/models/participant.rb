class Participant < ActiveRecord::Base
  belongs_to :round
  belongs_to :outing
  belongs_to :user
end