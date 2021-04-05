module RoomHelper
  def rooms_table_content(rooms)
    {
      attributes: %w[教室名 詳細 予定],
      records: rooms.map do |room|
        room_table_record(room)
      end,
    }
  end

  def room_table_record(room)
    {
      id: room.id,
      tds: [
        room.name,
        content_tag(:div) { link_to '開く', room_path(room) },
        content_tag(:div) { link_to '開く', terms_path(room_id: room.id) }
      ],
    }
  end
end