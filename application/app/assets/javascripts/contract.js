const cb_select = (event) => {
  const td = $(event.target).parent().parent().parent();
  const div1 = $(event.target).parent().parent();
  const div2 = $(event.target).parent();
  const select_count = div2.children('[id^=select_count]');
  const select_teacher_id = div2.children('[id^=select_teacher_id]');
  const teacher_id = select_teacher_id.val() ? Number(select_teacher_id.val()) : null;
  const count = Number(select_count.val())
  $.ajax({
    type: 'put',
    url: `/contract/${div1.data('id')}`,
    data: JSON.stringify({
      contract: {
        count,
        teacher_id,
      },
    }),
    contentType: 'application/json',
  }).done(() => {
    div1.data('count', count);
    div1.data('teacher_id', teacher_id);
    if ( count === 0 && teacher_id === null ) {
      td.removeClass('bg-active');
    } else {
      td.addClass('bg-active');
    }
  }).fail((xhr) => {
    select_count.val(div1.data('count'));
    select_teacher_id.val(div1.data('teacher_id'));
    alert(xhr.responseJSON.message);
  });
}

const cb_button = (event) => {
  if (!window.confirm('削除してよろしいですか。')) return;
  const td = $(event.target).parent().parent().parent();
  const div = $(event.target).parent().parent();
  const select_count = div.children(':first').children('[id^=select_count]');
  const select_teacher_id = div.children(':first').children('[id^=select_teacher_id]');
  $.ajax({
    url: `/contract/${div.data('id')}`,
    type: 'put',
    data: JSON.stringify({
      contract: {
        count: 0,
        teacher_id: null,
      },
    }),
    contentType: 'application/json',
  }).done(() => {
    div.data('count', 0);
    div.data('teacher_id', null);
    select_count.val(0);
    select_teacher_id.val(null);
    td.removeClass('bg-active');
  }).fail((xhr) => {
    alert(xhr.responseJSON.message);
  });
}
