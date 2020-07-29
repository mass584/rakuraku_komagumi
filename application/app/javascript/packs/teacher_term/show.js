const cb_button = (event) => {
  const button = $(event.target);
  const div = button.parent();
  const value = button.text();
  if (value === 'OK') {
    $.ajax({
      type: 'delete',
      url: `/teacher_request/${div.data('id')}`,
    }).done(() => {
      div.data('id', null);
      button.addClass('btn-danger');
      button.removeClass('btn-primary');
      button.text('NG');
    }).fail((xhr) => {
      alert(xhr.responseJSON.message);
    });
  } else if (value === 'NG') {
    $.ajax({
      type: 'post',
      url: '/teacher_request',
      data: JSON.stringify({
        timetable_id: div.data('timetable_id'),
        teacher_term_id: div.data('teacher_term_id'),
      }),
      contentType: 'application/json',
    }).done((data) => {
      div.data('id', data.id);
      button.addClass('btn-primary');
      button.removeClass('btn-danger');
      button.text('OK');
    });
  }
}
