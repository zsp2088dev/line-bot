# frozen_string_literal: true

require 'open-uri'
require 'json'

GNAVI_API_KEY = ENV['GNAVI_API_KEY']
GNAVI_REST_SEARCH_BASE_URL = 'https://api.gnavi.co.jp/RestSearchAPI/v3'

class GnaviRequest
  def gnavi_rest_search(latitude, longitude)
    url = '%s/?keyid=%s&category_l=RSFST18000&range=2&latitude=%s&longitude=%s&hit_per_page=50' % [GNAVI_REST_SEARCH_BASE_URL, GNAVI_API_KEY, latitude, longitude]

    begin
      response = OpenURI.open_uri(url).read
      return JSON.parse(response)

    rescue OpenURI::HTTPError => e
      Rails.logger.info(e)
      return false
    end

  end

  def response_processing(hash)
    messages = []
    hash['rest'].each { |cafe|
      if has_wifi(cafe['name_kana'])
        messages.push(cafe)
      end
    }

    # 近くにwifiの利用可能なcafeがにない場合の処理
    if messages.empty?
      return not_found_cafe
    end

    cafe = choice_best(messages)
    "近くのWiFiが利用できるカフェ\n\n【%s】\n\n%s" % [cafe['name'], cafe['url_mobile']]

  end

  # cafe_with_wifi_listに含まれるカフェかどうかをチェック
  def has_wifi(name_kana)
    !cafe_with_wifi_list.map { |cafe| cafe if name_kana.include?(cafe) }.compact.empty?
  end

  # 一番よいカフェを選ぶ
  # スタバ以外は...
  def choice_best(cafes)
    cafes.each { |cafe|
      if cafe['name_kana'].include?('スターバックスコーヒー')
        return cafe
      end
    }

    cafes.sample

  end

  # Level2ではWiFiの使えるカフェをここに追加
  def cafe_with_wifi_list
    [
        'スターバックスコーヒー',
        'ドトール',
        'プロント',
        'タリーズ',
        'マクドナルド',
        'ウエシマコーヒー',
        'ロッテリア',
        'フレッシュネス',
        'コメダコーヒー',
        'ベローチェ',
        'エクセルシオール',
    ]
  end

  def not_found_cafe
    '近くにWiFiが利用できるカフェが見つかりませんでした。'
  end


  def cafe_with_wifi(latitude, longitude)
    response = gnavi_rest_search(latitude, longitude)
    if response
      response_processing(response)
    else
      not_found_cafe
    end
  end
end