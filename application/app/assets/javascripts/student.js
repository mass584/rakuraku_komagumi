$(document).ready(() => {
  $('[id=button_maru]').on('click', cb_maru_click);
  $('[id=button_batsu]').on('click', cb_batsu_click);
});

cb_maru_click = (event) => {
  const div = $(event.target).parent();
  const button_maru = div.children('#button_maru');
  const button_batsu = div.children('#button_batsu');
  const data = {
    student_id: div.data('student_id'),
    subject_id: div.data('subject_id'),
  };
  $.ajax({
    url: '/student_subject_mapping/delete',
    type: 'delete',
    data: data,
  }).done(() => {
    button_maru.css('display', 'none');
    button_batsu.css('display', 'inline');
  });
}

cb_batsu_click = (event) => {
  const div = $(event.target).parent();
  const button_maru = div.children('#button_maru');
  const button_batsu = div.children('#button_batsu');
  const data = {
    student_id: div.data('student_id'),
    subject_id: div.data('subject_id'),
  };
  $.ajax({
    url: '/student_subject_mapping',
    type: 'post',
    data: data,
  }).done(() => {
    button_maru.css('display', 'inline');
    button_batsu.css('display', 'none');
  });
}
