import $ from 'jquery';

$(document).ready(() => {
  $('#button_output_pdf').on('click', cb_button_output_pdf);
  $('#button_select_all').on('click', cb_button_select_all);
  $('#button_unselect_all').on('click', cb_button_unselect_all);
});

cb_button_output_pdf = () => {
  const studentIds = $('[type=checkbox]').filter((index, element) => {
    return element.checked;
  }).map((index, element) => {
    return element.id;
  }).get();
  location.href = "/studentschedule.pdf?student_id=" + JSON.stringify(studentIds);
}

cb_button_select_all = () => {
  $('[type=checkbox]').each((index, element) => {
    $(element).prop("checked", true);
  });
}

cb_button_unselect_all = () => {
  $('[type=checkbox]').each((index, element) => {
    $(element).prop("checked", false);
  });
}
