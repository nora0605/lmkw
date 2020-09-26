# frozen_string_literal: true

class Check < ApplicationRecord
  belongs_to :user
  belongs_to :integration
  has_many :counts,
           class_name: "CheckCount",
           dependent: :restrict_with_exception
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :integration_id, :user_id, presence: true

  class << self
    def model_name
      ActiveModel::Name.new(base_class)
    end
  end # class << self

  def refresh
    raise NotImplementedError
  end

  def last_value
    counts.last && counts.last.value
  end
end
