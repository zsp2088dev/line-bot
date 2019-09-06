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

  def response_processing(user_id, hash)
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

    cafe = choice_best(user_id, messages)
    if cafe
      "近くのWiFiが利用できるカフェ\n\n【%s】\n\n%s" % [cafe['name'], cafe['url_mobile']]
    else
      not_found_cafe
    end

  end

  # cafe_with_wifi_listに含まれるカフェかどうかをチェック
  def has_wifi(name_kana)
    !Cafes.new.cafe_with_wifi_list.map { |cafe| cafe if name_kana.include?(cafe) }.compact.empty?
  end

  # 一番よいカフェを選ぶ
  # DBからデータを取得して利用したくないカフェは外す
  def choice_best(user_id, cafes)
    # 利用したくないカフェ一覧を取得
    dislike_cafes = Dislike.where(user: user_id).map { |item| item.cafe }

    # 利用したいカフェ一覧
    love_cafes = Cafes.new.cafe_with_wifi_list - dislike_cafes

    # 利用したくないカフェの除外処理
    result = []
    cafes.each do |cafe|
      love_cafes.each do |love|
        if cafe['name_kana'].include?(love)
          result.push(cafe)
          break
        end
      end
    end

    # 除外した結果、空の場合あり
    if result.empty?
      nil
    end

    result.sample
  end

  def not_found_cafe
    '近くにWiFiが利用できるカフェが見つかりませんでした。'
  end


  def cafe_with_wifi(user_id, latitude, longitude)
    response = gnavi_rest_search(latitude, longitude)
    if response
      response_processing(user_id, response)
    else
      not_found_cafe
    end
  end
end