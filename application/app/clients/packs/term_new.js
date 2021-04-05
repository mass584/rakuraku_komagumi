import $ from 'jquery';
import 'bootstrap4-datetimepicker';
import moment from 'moment';

$(() => {
  const defaultDate = moment().startOf('month');
  $('#term_begin_at_datepicker').datetimepicker({ format: 'YYYY/MM/DD', defaultDate });
  $('#term_end_at_datepicker').datetimepicker({ format: 'YYYY/MM/DD', defaultDate });
});
