import $ from 'jquery';

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

export const cb_button = (event) => {
  const button = $(event.target);
  const div = $(event.target).parent();
  if (div.data('id')) {
    delete_teacher_subject(div, button);
  } else {
    create_teacher_subject(div, button);
  }
}

const create_teacher_subject = (div, button) => {
  $.ajax({
    url: '/teacher_subject',
    type: 'post',
    data: {
      teacher_subject: {
        teacher_id: div.data('teacher_id'),
        subject_id: div.data('subject_id'),
      },
    },
  }).done((response) => {
    div.data('id', response.id);
    button.text('可');
    button.addClass('btn-primary');
    button.removeClass('btn-danger');
  }).fail(() => {
    alert('操作に失敗しました。');
  });
}

const delete_teacher_subject = (div, button) => {
  $.ajax({
    url: `/teacher_subject/${div.data('id')}`,
    type: 'delete',
  }).done(() => {
    div.data('id', null);
    button.text('不');
    button.addClass('btn-danger');
    button.removeClass('btn-primary');
    alert("指導可能科目を削除しても、すでに担任に設定されている授業については、担任は変更されません。");
  }).fail(() => {
    alert('操作に失敗しました。');
  });
}
