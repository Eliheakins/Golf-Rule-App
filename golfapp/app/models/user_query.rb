class UserQuery < ApplicationRecord
  belongs_to :user
  belongs_to :rule_section
end
