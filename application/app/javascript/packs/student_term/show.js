import $ from 'jquery';

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

export const cb_button = (event) => {
  const button = $(event.target);
  const div = button.parent();
  const value = button.text();
  if (value === 'OK') {
    $.ajax({
      type: 'delete',
      url: `/student_request/${div.data('id')}`,
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
      url: '/student_request',
      data: JSON.stringify({
        timetable_id: div.data('timetable_id'),
        student_term_id: div.data('student_term_id'),
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
