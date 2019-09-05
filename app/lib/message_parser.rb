class MessageParser
  def build_message(user_id, message)

    if message[0] == '+'

    elsif message[0] == '-'

    elsif message == 'リスト'
      build_list_message(user_id)
    else
      unknown_message
    end
  end

  def unknown_message
    '送られてきたメッセージを解析できませんでした。'
  end


  def build_list_message(user_id)
    msg = "リスト一覧です！\n\n"
    dislike_cafes = Dislike.where(user: user_id).map { |item| item.cafe }
    love_cafes = Cafes.new.cafe_with_wifi_list - dislike_cafes

    love_cafes.each do |love|
      msg += build_line_message(love, true)
    end

    dislike_cafes.each do |dislike|
      msg += build_line_message(dislike, false)
    end

    msg
  end

  def build_line_message(cafe, ok)
    if ok
      prefix = '+'
    else
      prefix = '-'
    end

    # + スターバックスコーヒー　のようにして返す
    "#{prefix} #{Cafes.new.cafe_full_name(cafe)}\n"
  end
end