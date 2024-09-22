# frozen_string_literal: true

require_relative "api_header_optimizer/version"
require_relative "api_header_optimizer/helpers"
require_relative "api_header_optimizer/optimizer"
require_relative "api_header_optimizer/tester"

module ApiHeaderOptimizer
  def self.optimize(address_url, headers)
    optimizer = Optimizer.new(address_url, headers)
    optimizer.optimize
  end
end
