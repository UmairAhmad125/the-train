# TfL Train Arrivals

Small Rails application that displays upcoming tube arrivals using the TfL API.

## Features

- Search for a station
- Displays next train arrivals
- Sorted by time to arrival
- Simple readable interface

## Tech Stack

- Ruby **3.2.2**
- Rails **8.1.2**
- Faraday
- RSpec and WebMock for testing


## Setup

Clone the repository:

git clone https://github.com/UmairAhmad125/the-train.git
cd the-train

Install dependencies:

bundle install

Run the server:

rails s

Visit:

http://localhost:3000

## Running tests

bundle exec rspec

## Notes

The application uses the TfL StopPoint and Arrivals APIs.

API credentials are optional.