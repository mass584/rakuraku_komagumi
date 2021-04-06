import $ from 'jquery';

$.ajaxSetup({
  headers: { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') },
});

const onBlurBeginEndTime = (event) => {
  const timeElement = $(event.target);
  const wrapperElement = timeElement.parent();
  const id = wrapperElement.data('id');
  const key = wrapperElement.data('key');
  const value = timeElement.val();
  const url = `/begin_end_times/${id}`;
  const data = { timetable: { [key]: value } };
  $.ajax({
    type: 'put',
    url: url,
    data: JSON.stringify(data),
    contentType: 'application/json',
  }).fail(({ responseText }) => {
    const response = JSON.parse(responseText);
    alert(response.message);
  });
}

const onBlurIsClosed = (event) => {
  const selectElement = $(event.target);
  const wrapperElement = selectElement.parent();
  const tdElement = wrapperElement.parent();
  const id = wrapperElement.data('id');
  const key = wrapperElement.data('key');
  const value = selectElement.val() === 'true';
  const url = `/timetables/${id}`;
  const data = { timetable: { [key]: value } };
  $.ajax({
    type: 'put',
    url: url,
    data: JSON.stringify(data),
    contentType: 'application/json',
  }).done(() => {
    const className = value ? 'bg-inactive' : '';
    tdElement.attr('class', className);
  }).fail(({ responseText }) => {
    selectElement.val(String(!value));
    const response = JSON.parse(responseText);
    alert(response.message);
  });
}

$(document).ready(() => {
  $('[id^=begin_at]').on('blur', onBlurBeginEndTime);
  $('[id^=end_at]').on('blur', onBlurBeginEndTime);
  $('[id^=is_closed]').on('change', onBlurIsClosed);
});
