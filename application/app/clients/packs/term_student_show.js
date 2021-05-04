$.ajaxSetup({
  headers: { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

$(() => $('[id^=button]').on('click', onClickButton));

const onClickButton = (event) => {
  const buttonElement = $(event.target);
  const buttonWrapperElement = buttonElement.parent();
  const value = buttonElement.text();
  const studentVacancyId = buttonWrapperElement.data('id');
  const url = `/student_vacancies/${studentVacancyId}`;
  if (value === 'OK') {
    $.ajax({
      type: 'put',
      url,
      data: JSON.stringify({ student_vacancy: { is_vacant: false } }),
      contentType: 'application/json',
    }).done(() => {
      buttonElement.addClass('btn-danger');
      buttonElement.removeClass('btn-primary');
      buttonElement.text('NG');
    }).fail(({ responseJSON }) => {
      alert(responseJSON.message);
    });
  } else {
    $.ajax({
      type: 'put',
      url,
      data: JSON.stringify({ student_vacancy: { is_vacant: true } }),
      contentType: 'application/json',
    }).done(() => {
      buttonElement.addClass('btn-primary');
      buttonElement.removeClass('btn-danger');
      buttonElement.text('OK');
    }).fail(({ responseJSON }) => {
      alert(responseJSON.message);
    });
  }
}
