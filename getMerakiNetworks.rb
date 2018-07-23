require 'net/http'
require './apiConstants'

def fetch(uri_str, limit = 10)
  # You should choose a better exception.
  raise ArgumentError, 'too many HTTP redirects' if limit == 0

  url = URI(uri_str)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(url)
  request["X-Cisco-Meraki-API-Key"] = ApiConstants::API_KEY

  response = http.request(request)
  # response = Net::HTTP.get_response(URI(uri_str))

  case response
  when Net::HTTPSuccess then
    puts "Response Code:"
    puts response.code
    puts "Returning:"
    print response.body
    response.body
  when Net::HTTPRedirection then
    location = response['location']
    warn "redirected to #{location}"
    fetch(location, limit - 1)
  else
    response.body
  end
end

fetch("https://api.meraki.com/api/v0/organizations/" + ApiConstants::ORG_ID + "/networks")
