# frozen_string_literal: true

module Matchers
  class DeactivateCheck
    attr_reader :active_before, :active_after, :element, :expected_name

    def initialize(expected_name)
      @expected_name = expected_name
    end

    def in(element)
      @element = element
      self
    end

    def matches?(event_proc)
      @active_before = check_active?

      event_proc.call

      @active_after = check_active?

      active_before && !active_after
    end

    def supports_block_expectations?
      true
    end

    def failure_message
      if active_before
        "expected check to be inactive after, but was active"
      else
        "expected check to originally be active, but was inactive"
      end
    end

    private

    def check_active?
      Matchers::HaveActiveCheck.new(expected_name).matches?(element)
    end
  end

  def deactivate_check(expected_name)
    DeactivateCheck.new(expected_name)
  end
end
