import 'select2';

$.ajaxSetup({
  headers: { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') },
});

$(() => {
  $('[id^=begin_at]').on('blur', onBlurBeginAt);
  $('[id^=end_at]').on('blur', onBlurEndAt);
  $('[id^=select_status]').on('change', onChangeStatus);
  $('[id^=multiselect]').select2();
});

const onBlurBeginAt = (event) => {
  const timeElement = $(event.target);
  const tdInnerElement = timeElement.parent();
  const beginEndTimeId = tdInnerElement.data('id');
  const beginAt = tdInnerElement.data('begin_at');
  const newBeginAt = timeElement.val();
  const url = `/begin_end_times/${beginEndTimeId}`;
  const data = { timetable: { begin_at: newBeginAt } };
  $.ajax({
    type: 'put',
    url,
    data: JSON.stringify(data),
    contentType: 'application/json',
  }).done(() => {
    tdInnerElement.data('begin_at', newBeginAt);
  }).fail(({ responseJSON }) => {
    timeElement.val(beginAt);
    alert(responseJSON.message);
  });
}

const onBlurEndAt = (event) => {
  const timeElement = $(event.target);
  const tdInnerElement = timeElement.parent();
  const beginEndTimeId = tdInnerElement.data('id');
  const endAt = tdInnerElement.data('end_at');
  const newEndAt = timeElement.val();
  const url = `/begin_end_times/${beginEndTimeId}`;
  const data = { timetable: { end_at: newEndAt } };
  $.ajax({
    type: 'put',
    url,
    data: JSON.stringify(data),
    contentType: 'application/json',
  }).done(() => {
    tdInnerElement.data('end_at', newEndAt);
  }).fail(({ responseJSON }) => {
    timeElement.val(endAt);
    alert(responseJSON.message);
  });
}

const onChangeStatus = (event) => {
  const selectElement = $(event.target);
  const tdInnerElement = selectElement.parent();
  const tdElement = tdInnerElement.parent();
  const timetableId = tdInnerElement.data('id');
  const isClosed = tdInnerElement.data('is_closed');
  const termGroupId = Number(tdInnerElement.data('term_group_id'));
  const status = isClosed ? -1 : termGroupId;
  const newStatus = Number(selectElement.val());
  const newIsClosed = newStatus === -1;
  const newTermGroupId = newStatus > 0 ? newStatus : 0;
  const url = `/timetables/${timetableId}`;
  const data = {
    timetable: {
      is_closed: newIsClosed,
      term_group_id: newTermGroupId === 0 ? null : newTermGroupId,
    },
  };
  $.ajax({
    type: 'put',
    url,
    data: JSON.stringify(data),
    contentType: 'application/json',
  }).done(() => {
    tdInnerElement.data('is_closed', newIsClosed);
    tdInnerElement.data('term_group_id', newTermGroupId);
    if (newIsClosed) {
      tdElement.addClass('bg-secondary');
      tdElement.removeClass('bg-warning-light');
    } else if (newTermGroupId) {
      tdElement.addClass('bg-warning-light');
      tdElement.removeClass('bg-secondary');
    } else {
      tdElement.removeClass('bg-warning-light');
      tdElement.removeClass('bg-secondary');
    }
  }).fail(({ responseJSON }) => {
    selectElement.val(status);
    alert(responseJSON.message);
  });
}
