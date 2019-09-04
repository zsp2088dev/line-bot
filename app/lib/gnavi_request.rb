# frozen_string_literal: true

require 'open-uri'
require 'json'

GNAVI_API_KEY = ENV['GNAVI_API_KEY']
GNAVI_REST_SEARCH_BASE_URL = 'https://api.gnavi.co.jp/RestSearchAPI/v3'

class GnaviRequest
  def gnavi_rest_search(latitude, longitude)
    url = '%s/?keyid=%s&category_l=RSFST18000&range=2&latitude=%s&longitude=%s&hit_per_page=50' % [GNAVI_REST_SEARCH_BASE_URL, GNAVI_API_KEY, latitude, longitude]
    response = OpenURI.open_uri(url).read
    JSON.parse(response)
  end

  def response_processing(hash)
    messages = []
    hash['rest'].each { |cafe|
      if compare_cafe(cafe['name_kana'], cafe_with_wifi_list)
        messages.push(cafe)
      end
    }

    if messages.empty?
      return '近くにWiFiが利用できるカフェが見つかりませんでした。'
    end

    cafe = messages.sample
    "近くのWiFiが利用できるカフェ\n\n【%s】\n\n%s" % [cafe['name'], cafe['url_mobile']]

  end

  # cafe_with_wifi_listに含まれるカフェかどうかをチェック
  def compare_cafe(name_kana, list)
    result = false
    list.each { |cafe|
      if name_kana.include?(cafe)
        result = true
        break
      end
    }
    result
  end

  # Level2ではWiFiの使えるカフェをここに追加
  def cafe_with_wifi_list
    %w(スターバックスコーヒー ドトール プロント タリーズ マクドナルド ウエシマコーヒー ロッテリア フレッシュネス コメダコーヒー)
  end


  def cafe_with_wifi(latitude, longitude)
    response_processing(gnavi_rest_search(latitude, longitude))
  end
end