class ArrivalsController < ApplicationController
  def show
    stop_name = params[:stop].presence || "Great Portland Street"
    client = Tfl::Client.new
    stop = client.search_stop_point(stop_name)
    @stop_name = stop[:name]
    @arrivals = client.arrivals(stop[:id])
                      .sort_by { |a| a[:time_to_station] }
                      .first(10)
  rescue StandardError => e
    @error = e.message || "Something went wrong fetching arrivals."
    @arrivals = []
  end
end