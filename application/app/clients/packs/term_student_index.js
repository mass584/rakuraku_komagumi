$.ajaxSetup({
  headers: { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

$(() => $('[id=bulk_schedule]').on('click', onClickBulkSchedule));
$(() => $('[id=bulk_schedule_notification]').on('click', onClickBulkScheduleNotification));
$(() => $('[id=check_all]').on('click', onClickCheckAll));
$(() => $('[id=uncheck_all]').on('click', onClickUnCheckAll));

const onClickCheckAll = () => {
  const checkboxElements = $('[id^=term_student_id]').toArray();
  checkboxElements.forEach((item) => {
    if (!item.disabled) item.checked = true
  });
}

const onClickUnCheckAll = () => {
  const checkboxElements = $('[id^=term_student_id]').toArray();
  checkboxElements.forEach((item) => {
    if (!item.disabled) item.checked = false
  });
}

const onClickBulkSchedule = () => {
  const form = document.createElement('form');
  form.method = 'get';
  form.action = 'term_students/bulk_schedule.pdf';
  form.id = 'bulk_checkbox'
  document.body.appendChild(form);
  form.submit();
}

const onClickBulkScheduleNotification = async () => {
  $('#modal-loader').removeClass('d-none');
  const checkboxElements = $('[id^=term_student_id]').toArray();
  const checkedCheckboxElements = checkboxElements.filter((item) => item.checked);
  if (checkedCheckboxElements.length === 0) {
    $('#modal-loader').addClass('d-none');
    alert('チェックされていません。');
    return;
  }
  const termStudentId = checkedCheckboxElements.map((item) => Number(item.value));
  const reqBody = JSON.stringify({ term_student_id: termStudentId });
  const url = 'term_students/bulk_schedule_notification';
  const { error_messages } = await $.ajax({ type: 'post', url, data: reqBody, contentType: 'application/json' });
  $('#modal-loader').addClass('d-none');
  if (error_messages.length > 0) {
    alert('以下の生徒にはメールを送信することができませんでした。\n' + error_messages.join('\n'));
  } else {
    alert('メールを送信しました。');
  }
  location.reload();
}
