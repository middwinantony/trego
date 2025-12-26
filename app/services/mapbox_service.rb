require 'net/http'
require 'json'

class MapboxService
  BASE_URL = 'https://api.mapbox.com'

  def initialize
    @access_token = ENV['MAPBOX_ACCESS_TOKEN']
  end

  # Geocode a query string to get location suggestions
  # Returns array of location objects with name, address, coordinates
  def geocode(query, limit: 5)
    return [] if query.blank?

    url = "#{BASE_URL}/geocoding/v5/mapbox.places/#{URI.encode_www_form_component(query)}.json"
    params = {
      access_token: @access_token,
      limit: limit,
      types: 'address,poi'
    }

    response = make_request("#{url}?#{URI.encode_www_form(params)}")
    return [] unless response

    parse_geocoding_response(response)
  rescue StandardError => e
    Rails.logger.error "Mapbox geocoding error: #{e.message}"
    []
  end

  # Get directions between two points
  # Returns distance (km), duration (minutes), and route geometry
  def directions(origin_lng, origin_lat, dest_lng, dest_lat)
    url = "#{BASE_URL}/directions/v5/mapbox/driving/#{origin_lng},#{origin_lat};#{dest_lng},#{dest_lat}"
    params = {
      access_token: @access_token,
      geometries: 'geojson',
      overview: 'full'
    }

    response = make_request("#{url}?#{URI.encode_www_form(params)}")
    return nil unless response

    parse_directions_response(response)
  rescue StandardError => e
    Rails.logger.error "Mapbox directions error: #{e.message}"
    nil
  end

  # Reverse geocode: convert coordinates to address
  def reverse_geocode(longitude, latitude)
    url = "#{BASE_URL}/geocoding/v5/mapbox.places/#{longitude},#{latitude}.json"
    params = {
      access_token: @access_token,
      types: 'address'
    }

    response = make_request("#{url}?#{URI.encode_www_form(params)}")
    return nil unless response

    features = response['features']
    return nil if features.empty?

    features.first['place_name']
  rescue StandardError => e
    Rails.logger.error "Mapbox reverse geocoding error: #{e.message}"
    nil
  end

  private

  def make_request(url)
    uri = URI(url)
    response = Net::HTTP.get_response(uri)

    return nil unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  rescue StandardError => e
    Rails.logger.error "Mapbox API request error: #{e.message}"
    nil
  end

  def parse_geocoding_response(response)
    features = response['features'] || []

    features.map do |feature|
      {
        name: feature['text'],
        address: feature['place_name'],
        coordinates: {
          longitude: feature['geometry']['coordinates'][0],
          latitude: feature['geometry']['coordinates'][1]
        }
      }
    end
  end

  def parse_directions_response(response)
    routes = response['routes']
    return nil if routes.nil? || routes.empty?

    route = routes.first
    {
      distance: (route['distance'] / 1000).round(2), # Convert meters to km
      duration: (route['duration'] / 60).round(0),   # Convert seconds to minutes
      geometry: route['geometry']
    }
  end
end
