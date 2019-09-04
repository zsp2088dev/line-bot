# frozen_string_literal: true

require 'open-uri'
require 'json'

GNAVI_API_KEY = ENV['GNAVI_API_KEY']
GNAVI_REST_SEARCH_BASE_URL = 'https://api.gnavi.co.jp/RestSearchAPI/v3'

class GnaviRestSearchAPI
  def gnavi_rest_search(latitude, longitude)
    url = '%s/?keyid=%s&category_l=RSFST18000&range=2&latitude=%s&longitude=%s&hit_per_page=50' % [GNAVI_REST_SEARCH_BASE_URL, GNAVI_API_KEY, latitude, longitude]
    response = OpenURI.open_uri(url).read
    JSON.parse(response)
  end

  def response_processing(hash)
    hash['rest'][0]['name']
  end

  def cafe_with_wifi(latitude, longitude)
    response_processing(gnavi_rest_search(latitude, longitude))
  end
end