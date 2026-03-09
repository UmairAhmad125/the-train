require "rails_helper"

RSpec.describe Tfl::Client do
  subject(:client) { described_class.new }

  describe "#search_stop_point" do
    it "returns the first matching stop point" do
      stub_request(:get, "https://api.tfl.gov.uk/StopPoint/Search/Great%20Portland%20Street")
        .with(query: hash_including("modes" => "tube"))
        .to_return(
          status: 200,
          body: {
            matches: [
              { id: "940GZZLUGPS", name: "Great Portland Street Underground Station" }
            ]
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      result = client.search_stop_point("Great Portland Street")

      expect(result).to eq(
        id: "940GZZLUGPS",
        name: "Great Portland Street Underground Station"
      )
    end

    it "raises a not found error when no matches are returned" do
      stub_request(:get, "https://api.tfl.gov.uk/StopPoint/Search/Unknown%20Station")
        .with(query: hash_including("modes" => "tube"))
        .to_return(
          status: 200,
          body: { matches: [] }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      expect do
        client.search_stop_point("Unknown Station")
      end.to raise_error("No station found for 'Unknown Station'.")
    end
  end

  describe "#arrivals" do
    it "maps arrival data into a simplified structure" do
      stub_request(:get, "https://api.tfl.gov.uk/StopPoint/940GZZLUGPS/Arrivals")
        .with(query: hash_including("mode" => "tube"))
        .to_return(
          status: 200,
          body: [
            {
              lineName: "Circle",
              destinationName: "Edgware Road",
              platformName: "Westbound - Platform 2",
              expectedArrival: "2026-03-04T12:00:00Z",
              timeToStation: 90
            },
            {
              lineName: "Metropolitan",
              destinationName: "Aldgate",
              platformName: "Eastbound - Platform 1",
              expectedArrival: "2026-03-04T12:01:00Z",
              timeToStation: 150
            }
          ].to_json,
          headers: { "Content-Type" => "application/json" }
        )

      result = client.arrivals("940GZZLUGPS")

      expect(result).to eq(
        [
          {
            line: "Circle",
            destination: "Edgware Road",
            platform: "Westbound - Platform 2",
            expected_at: "2026-03-04T12:00:00Z",
            time_to_station: 90
          },
          {
            line: "Metropolitan",
            destination: "Aldgate",
            platform: "Eastbound - Platform 1",
            expected_at: "2026-03-04T12:01:00Z",
            time_to_station: 150
          }
        ]
      )
    end
  end
end
