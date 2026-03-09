# frozen_string_literal: true

require "json"
require "cgi"

module Tfl
  class Client
    BASE_URL = "https://api.tfl.gov.uk"

    def initialize(app_key: ENV["TFL_APP_KEY"])
      @app_key = app_key
    end

    def search_stop_point(query)
      data = get_json("/StopPoint/Search/#{encode_path(query)}", modes: "tube")

      match = pick_best_match(Array(data["matches"]), query)
      raise "No station found for '#{query}'." unless match

      { id: match["id"], name: match["name"] }
    end

    def arrivals(stop_point_id)
      get_json("/StopPoint/#{stop_point_id}/Arrivals", mode: "tube").map do |arrival|
        {
          line: arrival["lineName"],
          destination: arrival["destinationName"],
          platform: arrival["platformName"],
          expected_at: arrival["expectedArrival"],
          time_to_station: arrival["timeToStation"].to_i
        }
      end
    end

    private

    def get_json(path, params = {})
      params = params.dup
      params[:app_key] = @app_key if @app_key.present?

      response = connection.get(path, params)

      raise "Resource not found" if response.status == 404
      raise "TfL API error #{response.status}" unless response.success?

      JSON.parse(response.body)
    end

    def encode_path(value)
      CGI.escape(value).gsub("+", "%20")
    end

    def pick_best_match(matches, query)
      q = query.to_s.downcase
      matches.find { |match| match["name"].to_s.downcase.include?(q) } || matches.first
    end

    def connection
      @connection ||= Faraday.new(url: BASE_URL) do |f|
        f.request :retry, max: 2, interval: 0.2, backoff_factor: 2
        f.adapter Faraday.default_adapter
      end
    end
  end
end
