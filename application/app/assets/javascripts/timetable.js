$(document).ready(() => {
  $('[id=begin_at]').on('change', cb_textbox_time);
  $('[id=end_at]').on('change', cb_textbox_time);
  $('[id=select_is_closed]').on('change', cb_select_is_closed);
});

const cb_textbox_time = (event) => {
  const textbox = $(event.target);
  const div = textbox.parent();
  const id = div.data('id');
  const url = `/begin_end_time/${id}`;
  const data = {
    timetable: {
      [textbox.attr('id')]: textbox.val(),
    },
  };
  $.ajax({
    type: 'put',
    url: url,
    data: JSON.stringify(data),
    contentType: 'application/json',
  }).fail(() => {
    alert('操作に失敗しました。');
  });
}

const cb_select_is_closed = (event) => {
  const select = $(event.target);
  const div = select.parent();
  const td = div.parent();
  const id = div.data('id');
  const url = `/timetable/${id}`;
  const data = {
    timetable: {
      is_closed: select.val() === "true",
    }
  };
  $.ajax({
    type: 'put',
    url: url,
    data: JSON.stringify(data),
    contentType: 'application/json',
  }).done(() => {
    div.data('is_closed', select.val());
    td.attr('class', select.val() === "true" ? 'bg-inactive' : '');
  }).fail(() => {
    alert('操作に失敗しました。');
  });
}
