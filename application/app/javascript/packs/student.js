import $ from 'jquery';

const cb_button = (event) => {
  const button = $(event.target);
  const div = $(event.target).parent();
  if (div.data('id')) {
    delete_student_subject(div, button);
  } else {
    create_student_subject(div, button);
  }
}

const create_student_subject = (div, button) => {
  $.ajax({
    url: '/student_subject',
    type: 'post',
    data: {
      student_subject: {
        student_id: div.data('student_id'),
        subject_id: div.data('subject_id'),
      },
    },
  }).done((response) => {
    div.data('id', response.id);
    button.text('受');
    button.addClass('btn-primary');
    button.removeClass('btn-danger');
  }).fail(() => {
    alert('操作に失敗しました。');
  });
}

const delete_student_subject = (div, button) => {
  $.ajax({
    url: `/student_subject/${div.data('id')}`,
    type: 'delete',
  }).done(() => {
    div.data('id', null);
    button.text('未');
    button.addClass('btn-danger');
    button.removeClass('btn-primary');
  }).fail(() => {
    alert('操作に失敗しました。');
  });
}
