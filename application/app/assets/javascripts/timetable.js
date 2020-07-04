$(document).ready(() => {
  $('[id=begin_at]').on('change', cb_textbox_time);
  $('[id=end_at]').on('change', cb_textbox_time);
  $('[id=select_status]').on('change', cb_select_status);
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

const cb_select_status = (event) => {
  const select = $(event.target);
  const div = select.parent();
  const td = div.parent();
  const id = div.data('id');
  const url = `/timetable/${id}`;
  const data = {
    timetable: {
      status: Number(select.val()),
    }
  };
  $.ajax({
    type: 'put',
    url: url,
    data: JSON.stringify(data),
    contentType: 'application/json',
  }).done(() => {
    div.data('status', select.val());
    td.attr('class', td_class(select.val()));
  }).fail(() => {
    alert('操作に失敗しました。');
  });
}

const td_class = (status) => {
  switch(status) {
    case '0':
      return '';
    case '1':
      return 'bg-inactive';
  }
}
