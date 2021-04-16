import $ from 'jquery';

$.ajaxSetup({
  headers: { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') },
});

$(() => {
  $('[id^=begin_at]').on('blur', onBlurBeginAt);
  $('[id^=end_at]').on('blur', onBlurEndAt);
  $('[id^=select_status]').on('change', onChangeStatus);
});

const onBlurBeginAt = (event) => {
  const timeElement = $(event.target);
  const wrapperElement = timeElement.parent();
  const tdInnerElement = wrapperElement.parent();
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
  const wrapperElement = timeElement.parent();
  const tdInnerElement = wrapperElement.parent();
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
  const isClosed = tdInnerElement.data('is_closed') === 'true';
  const termGroupId = Number(tdInnerElement.data('term_group_id')) || null;
  const status = isClosed ? -1 : (termGroupId || 0);
  const newStatus = Number(selectElement.val());
  const newIsClosed = newStatus === -1;
  const newTermGroupId = newStatus > 0 ? newStatus : null;
  const url = `/timetables/${timetableId}`;
  const data = {
    timetable: {
      is_closed: newIsClosed,
      term_group_id: newTermGroupId,
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
      tdElement.removeClass('bg-warning');
    } else if (newTermGroupId) {
      tdElement.addClass('bg-warning');
      tdElement.removeClass('bg-secondary');
    } else {
      tdElement.removeClass('bg-warning');
      tdElement.removeClass('bg-secondary');
    }
  }).fail(({ responseJSON }) => {
    selectElement.val(status);
    alert(responseJSON.message);
  });
}
