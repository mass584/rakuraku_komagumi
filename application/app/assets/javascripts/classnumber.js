$(document).ready(() => {
  $('[id=button_delete]').on('click', cb_button_delete);
  $('[id=select_number],[id=select_teacher]').on('change', cb_select_number_or_teacher);
  $('[id=check_group]').on('change', cb_check_group);
  $('[id=select_group_teacher]').on('change', cb_select_group_teacher);
});

cb_button_delete = (event) => {
  if (!window.confirm('本当に削除してよろしいですか。')) return;
  const div = $(event.target).parent();
  const id = div.data('id');
  const select_number = div.children('#select_number');
  const select_teacher = div.children('#select_teacher');
  const td = div.parent();
  const url = `/classnumber/${id}`;
  $.ajax({
    url: url,
    type: 'delete',
  }).done(() => {
    div.data('number', 0);
    div.data('teacher_id', 0);
    select_number.val(0);
    select_teacher.val(0);
    td.attr('class', 'disable');
  }).fail((xhr) => {
    alert(xhr.responseJSON.message);
  });
}

cb_select_number_or_teacher = (event) => {
  const div = $(event.target).parent();
  const id = div.data('id');
  const select_number = div.children('#select_number');
  const select_teacher = div.children('#select_teacher');
  const td = div.parent();
  const url = `/classnumber/${id}`;
  const data = {
    number: select_number.val(),
    teacher_id: select_teacher.val(),
  };
  $.ajax({
    url: url,
    type: 'put',
    data: data,
  }).done(() => {
    div.data('number', select_number.val());
    div.data('teacher_id', select_teacher.val());
    if ( select_number.val() == '0' && select_teacher.val() === '0') {
      td.attr('class', 'disable');
    } else {
      td.attr('class', 'enable');
    }
  }).fail((xhr) => {
    select_number.val(div.data('number'));
    select_teacher.val(div.data('teacher_id'));
    alert(xhr.responseJSON.message);
  });
}

cb_check_group = (event) => {
  const div = $(event.target).parent();
  const id = div.data('id');
  const checkbox = $(event.target);
  const url = `/classnumber/${id}`;
  const type = checkbox.prop('checked') ? 'put' : 'delete';
  $.ajax({
    url: url,
    type: type,
  }).done(() => {
    div.data('number', checkbox.val());
  }).fail((xhr) => {
    if (checkbox.prop('checked')) {
      checkbox.removeProp('checked');
    } else {
      checkbox.prop('checked', 'checked');
    }
    alert(xhr.responseJSON.message);
  });
}

cb_select_group_teacher = (event) => {
  const div = $(event.target).parent();
  const select_group_teacher = $(event.target);
  const url = '/subject_schedulemaster_mapping';
  const data = {
    teacher_id: select_group_teacher.val(),
    subject_id: div.data('subject_id'),
  };
  $.ajax({
    url: url,
    type: 'put',
    data: data,
  }).done(() => {
    div.data('teacher_id', select_group_teacher.val());
  }).fail((xhr) => {
    select_group_teacher.val(div.data('teacher_id'));
    alert(xhr.responseJSON.message);
  });
}
