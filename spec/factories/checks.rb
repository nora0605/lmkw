# frozen_string_literal: true

FactoryBot.define do
  factory(:check, class: "Test::Check") do
    transient do
      count_values { [] }
    end

    integration { default_integration }
    sequence(:name, 100) { |n| "Test Check #{n}" }
    target_attributes { {} }
    user { integration.user }

    after(:create) do |check, evaluator|
      # https://github.com/rails/rails/issues/41827
      check.instance_variable_set(:@strict_loading, false)

      counts =
        evaluator.count_values.map do |value|
          create(:count, check: check, value: value)
        end

      check.update!(latest_count: counts.last)
    end
  end
end
