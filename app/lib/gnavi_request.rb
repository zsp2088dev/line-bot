# frozen_string_literal: true

require 'open-uri'
require 'json'

GNAVI_API_KEY = ENV['GNAVI_API_KEY']

class GnaviAPI
  def gnavi_request(latitude, longitude)
    url = 'https://api.gnavi.co.jp/RestSearchAPI/v3/?keyid=%s&category_l=RSFST18000&range=4&latitude=%s&longitude=%s&wifi=1' % [GNAVI_API_KEY, latitude, longitude]
    response = OpenURI.open_uri(url).read
    JSON.parse(response)
  end

  def processing(hash)
    hash['rest'][0]['name']
  end

  def cafe_with_wifi(latitude, longitude)
    processing(gnavi_request(latitude, longitude))
  end
end