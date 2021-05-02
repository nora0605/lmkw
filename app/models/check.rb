# frozen_string_literal: true

class Check < ApplicationRecord
  belongs_to :user
  belongs_to :integration
  belongs_to :latest_count, class_name: "CheckCount"
  has_one :target, dependent: :delete
  has_many :counts, class_name: "CheckCount", dependent: :delete_all

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :integration_id, :user_id, :target, presence: true

  accepts_nested_attributes_for :target, update_only: true

  scope(
    :last_counted_before,
    lambda { |timestamp|
      left_joins(:counts)
          .having(
            "MAX(check_counts.created_at) < ? OR COUNT(check_counts) = 0",
            timestamp,
          )
          .group("checks.id")
    },
  )

  delegate :value, to: :target, prefix: true

  class << self
    def model_name
      ActiveModel::Name.new(base_class)
    end
  end # class << self

  def manual?
    false
  end

  def active?
    last_value.present? && last_value > target.value
  end

  def refresh=(refresh)
    Check::Refresh.call(self) if ["true", true].include?(refresh)
  end

  def next_count
    raise NotImplementedError, "next_count should be implemented on sub-classes"
  end

  def last_value
    latest_count && latest_count.value
  end
end
