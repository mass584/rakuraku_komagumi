$(document).ready(() => {
  $('[id=select_status]').on('change', cb_select_status);
  $('[id=begintime]').on('change', cb_textbox_time);
  $('[id=endtime]').on('change', cb_textbox_time);
});

cb_select_status = (event) => {
  const select = $(event.target);
  const div = select.parent();
  const td = div.parent();
  const id = div.data('id');
  const url = `/timetable/${id}`;
  const data = {
    status: select.val(),
  };
  $.ajax({
    url: url,
    type: 'put',
    data: data,
  }).done(() => {
    div.data('status', select.val());
    td.attr('class', _get_class(select.val()));
  }).fail((xhr) => {
    select.val(div.data('status'));
    alert(xhr.responseJSON.message);
  });
}

cb_textbox_time = (event) => {
  const textbox = $(event.target);
  const div = textbox.parent();
  const id = div.data('id');
  const textbox_begintime = div.children('#begintime');
  const textbox_endtime = div.children('#endtime');
  const url = '/timetable/update_master';
  const data = {
    id: id,
    begintime: textbox_begintime.val(),
    endtime: textbox_endtime.val(),
  };
  $.ajax({
    url: url,
    type: 'post',
    data: data,
  });
}

_get_class = (status) => {
  switch(status) {
    case '0':
      return 'selectbox-normal';
      break;
    case '-1':
      return 'selectbox-blank';
      break;
    default:
      return 'selectbox-group';
      break;
  }
}
