module RoomHelper
  def rooms_table_content(rooms)
    {
      attributes: %w[教室名 編集 選択],
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
        end,
        content_tag(:div) do
          link_to '選択', terms_path(room_id: room.id), { class: 'btn btn-dark' }
        end,
      ],
    }
  end
end