module RoomHelper
  def rooms_table_content(rooms)
    {
      attributes: %w[教室名 編集],
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
        content_tag(:div) do
          render partial: 'rooms/edit', locals: { room: room }
        end
      ],
    }
  end
end
