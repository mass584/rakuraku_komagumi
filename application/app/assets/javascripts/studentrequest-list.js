$(document).ready(() => {
  $('[id=checkbox_status]').on('click', cb_checkbox_status);
  load_all();
});

cb_checkbox_status = (event) => {
  const checkbox = $(event.target);
  const div = checkbox.parent();
  const id = div.data('id');
  const data = {
    id: id,
    status: checkbox.prop('checked') ? 1 : 0,
  };
  if (checkbox.prop('checked')) {
    checkbox.prop('checked', true);
  } else {
    checkbox.prop('checked', false);
  }
  $.ajax({
    url: `/studentrequest/update_master`,
    type: 'put',
    data: data,
  });
}
