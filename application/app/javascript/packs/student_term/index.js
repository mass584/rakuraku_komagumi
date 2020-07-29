import $ from 'jquery';

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

export const cb_checkbox = (event) => {
  const label = $(event.target);
  const div = label.parent();
  const checkbox = div.children();
  if (checkbox.prop('checked')) {
    checkbox.prop('checked', false);
  } else {
    checkbox.prop('checked', true);
  }
  $.ajax({
    type: 'put',
    url: `/student_term/${div.data('id')}`,
    data: JSON.stringify({
      is_decided: checkbox.prop('checked'),
    }),
    contentType: 'application/json',
  });
}
