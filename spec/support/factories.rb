# frozen_string_literal: true

require_relative "factories/api_keys"
require_relative "factories/requests"

module Factories
  def create_check(counts: [], target: {})
    integration = create_integration
    check = Test::Check.create!(
      name: "some check",
      integration: integration,
      user: integration.user,
      target_attributes: target,
    )
    # https://github.com/rails/rails/issues/41827
    check.instance_variable_set(:@strict_loading, false)
    create_counts(check, counts)
    check
  end

  def create_manual_check(counts: [], target: {})
    integration = create_manual_integration
    check = Check::Manual::AnyCount.create!(
      name: "some check",
      integration: integration,
      user: integration.user,
      target_attributes: target,
    )
    # https://github.com/rails/rails/issues/41827
    check.instance_variable_set(:@strict_loading, false)
    create_counts(check, counts)
    check
  end

  def create_counts(check, counts)
    created_counts =
      counts.map do |count_params|
        create_count(**count_params.merge(check: check))
      end
    check.update!(latest_count: created_counts.last)
    created_counts
  end

  def create_count(check: create_check, **params)
    check.counts.create!({ value: 0 }.merge(params))
  end

  TARGET_TRAITS = {
    refreshable: -> { { next_refresh_at: 1.day.ago } },
  }.freeze

  def create_target(*traits, **attributes)
    traits.each { |trait| attributes.merge!(TARGET_TRAITS.fetch(trait).call) }
    create_check(target: attributes).target
  end

  def create_integration(type = :test, user: create(:user))
    method("create_#{type}_integration").call(user: user)
  end

  def create_github_integration(user: create(:user))
    Integration::Github.create!(user: user, access_token: "foo")
  end

  def create_trello_integration(user: create(:user))
    Integration::Trello.create!(user: user, member_token: "foo")
  end

  def create_manual_integration(user: create(:user))
    Integration::Manual.create!(user: user)
  end

  def create_test_integration(user: create(:user))
    Test::Integration.create!(user: user)
  end

  def next_id
    @next_id ||= 0
    @next_id += 1
  end
end

RSpec.configure do |config|
  config.include(Factories)
end
