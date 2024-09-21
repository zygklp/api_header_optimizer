require_relative 'tester'

module ApiHeaderOptimizer
  class Optimizer
    def initialize(uri, headers)
      @uri = uri
      @headers = headers
      @tester = Tester.new(uri, headers)
    end

    def optimize
      puts "Starting optimization..."
      @tester.test_combinations

      optimal_headers = find_optimal_headers
      if optimal_headers.empty?
        puts "No optimal headers found."
      else
        puts "Optimal headers found: #{optimal_headers}"
      end
      optimal_headers
    end

    private

    def find_optimal_headers
      # Burada en başarılı olan sonucu buluruz.
      # Örneğin, 200 dönen ve en küçük header setini seçebiliriz.
      best_result = @tester.results.min_by { |result| [result[:headers].size, result[:code].to_i] }
      best_result ? best_result[:headers] : {}
    end
  end
end