$(document).ready(() => {
  $('[id=select_status]').on('change', cb_select_status);
  $('[id=begin_at]').on('change', cb_textbox_time);
  $('[id=end_at]').on('change', cb_textbox_time);
});

const cb_textbox_time = (event) => {
  const textbox = $(event.target);
  const div = textbox.parent();
  const id = div.data('id');
  const url = `/timetablemaster/${id}`;
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

const cb_select_status = (event) => {
  const select = $(event.target);
  const div = select.parent();
  const td = div.parent();
  const id = div.data('id');
  const url = `/timetable/${id}`;
  const data = {
    timetable: {
      status: select.val(),
    }
  };
  $.ajax({
    type: 'put',
    url: url,
    data: JSON.stringify(data),
    contentType: 'application/json',
  }).done(() => {
    div.data('status', select.val());
    td.attr('class', _get_class(select.val()));
  }).fail((xhr) => {
    alert('操作に失敗しました。');
  });
}

const _get_class = (status) => {
  switch(status) {
    case '0':
      return 'selectbox-normal';
    case '-1':
      return 'selectbox-blank';
  }
}
