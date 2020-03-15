$(document).ready(() => {
  $('[id=select_number],[id=select_teacher]').on('change', cb_select_number_or_teacher);
  $('[id=button_delete]').on('click', cb_button_delete);
});

const cb_select_number_or_teacher = (event) => {
  const div = $(event.target).parent().parent();
  const id = div.data('id');
  const select_number = div.children(':first').children('#select_number');
  const select_teacher = div.children(':first').children('#select_teacher');
  const teacher_id = select_teacher.val() ? Number(select_number.val()) : null;
  const number = Number(select_number.val())
  const td = div.parent();
  const url = `/classnumber/${id}`;
  const data = {
    classnumber: {
      number,
      teacher_id,
    },
  };
  $.ajax({
    type: 'put',
    url: url,
    data: JSON.stringify(data),
    contentType: 'application/json',
  }).done(() => {
    div.data('number', number);
    div.data('teacher_id', teacher_id);
    if ( number === 0 && teacher_id === null ) {
      td.attr('class', '');
    } else {
      td.attr('class', 'bg-active');
    }
  }).fail((xhr) => {
    select_number.val(div.data('number'));
    select_teacher.val(div.data('teacher_id'));
    alert(xhr.responseJSON.message);
  });
}

const cb_button_delete = (event) => {
  if (!window.confirm('削除してよろしいですか。')) return;
  const div = $(event.target).parent().parent();
  const id = div.data('id');
  const select_number = div.children(':first').children('#select_number');
  const select_teacher = div.children(':first').children('#select_teacher');
  const td = div.parent();
  const url = `/classnumber/${id}`;
  $.ajax({
    url: url,
    type: 'delete',
  }).done(() => {
    div.data('number', 0);
    div.data('teacher_id', null);
    select_number.val(0);
    select_teacher.val(null);
    td.attr('class', '');
  }).fail((xhr) => {
    alert(xhr.responseJSON.message);
  });
}
