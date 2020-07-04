const cb_checkbox = (event) => {
  const checkbox = $(event.target);
  const div = checkbox.parent();
  if (checkbox.prop('checked')) {
    checkbox.prop('checked', true);
  } else {
    checkbox.prop('checked', false);
  }
  $.ajax({
    type: 'put',
    url: `/student_term/${div.data('id')}`,
    data: JSON.stringify({
      status: checkbox.prop('checked') ? 1 : 0,
    }),
    contentType: 'application/json',
  });
}
