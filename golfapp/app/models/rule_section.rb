class RuleSection < ApplicationRecord
  belongs_to :parent, class_name: 'RuleSection', optional: true
  has_many :children, class_name: 'RuleSection', foreign_key: 'parent_id', dependent: :destroy
end
