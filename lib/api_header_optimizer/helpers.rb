module ApiHeaderOptimizer
  module Helpers
    # Dizinin tüm alt kümelerini döndüren metot
    def self.subsets(array)
      (0..array.size).flat_map { |n| array.combination(n).to_a }
    end
  end
end