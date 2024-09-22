require 'net/http'
require_relative 'helpers'

module ApiHeaderOptimizer
  class Tester
    attr_reader :uri, :all_headers, :results

    def initialize(uri, all_headers)
      @uri = URI(uri)
      @all_headers = all_headers
      @results = []
      @mutex = Mutex.new # Erişim problemlerini önlemek için mutex kullanıyoruz
    end

    # Tek bir header seti ile istek yapar ve sonucu kontrol eder
    def test_header_set(header_set)
      response = make_request(header_set)
      return unless response # İstek başarısızsa geç
      
      # Sonuçları güvenli bir şekilde eklemek için mutex kullanıyoruz
      @mutex.synchronize do
        @results << { headers: header_set, code: response.code, body: response.body }
      end
    end

    # Header kombinasyonlarını test eder
    def test_combinations
      header_keys = @all_headers.keys
      subsets = ApiHeaderOptimizer::Helpers.subsets(header_keys)

      # Eşzamanlılık için thread'ler oluşturuyoruz
      threads = subsets.map do |subset|
        Thread.new do
          header_set = subset.to_h { |key| [key, @all_headers[key]] }
          test_header_set(header_set)
        end
      end

      # Tüm thread'lerin bitmesini bekliyoruz
      threads.each(&:join)
    end

    private

    def make_request(headers)
      http = Net::HTTP.new(@uri.host, @uri.port)
      http.use_ssl = @uri.scheme == 'https'
      http.start do |http|
        headers.each do |header_set|
          request = Net::HTTP::Get.new(@uri.path)
          header_set.each { |key, value| request[key] = value }
          begin
            response = http.request(request)
            return response if response.code.to_i.between?(200, 299) # Başarılı yanıtlar
          rescue => e
            puts "Request failed: #{e.message}"
            return nil
          end
        end
      end
    end
  end
end