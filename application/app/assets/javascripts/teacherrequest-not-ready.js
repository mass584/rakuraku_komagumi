$(document).ready(() => {
  $('[id=btn_maru_batsu]').on('click', cb_button_maru_batsu);
});

const cb_button_maru_batsu = (event) => {
  const button = $(event.target);
  const div = button.parent();
  const id = div.data('id');
  const timetable_id = div.data('timetable_id');
  const teacher_id = div.data('teacher_id');
  const value = button.text();
  if (value === 'OK') {
    $.ajax({
      type: 'delete',
      url: `/teacherrequest/${id}`,
    }).done(() => {
      div.data('id', null);
      button.attr('class', 'btn btn-danger');
      button.text('NG');
    }).fail((xhr) => {
      alert(xhr.responseJSON.message);
    });
  } else if (value === 'NG') {
    const data = {
      timetable_id,
      teacher_id,
    };
    $.ajax({
      type: 'post',
      url: '/teacherrequest',
      data: JSON.stringify(data),
      contentType: 'application/json',
    }).done((data) => {
      div.data('id', data.id);
      button.attr('class', 'btn btn-primary');
      button.text('OK');
    });
  }
}
