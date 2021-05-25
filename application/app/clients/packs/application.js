require('@rails/ujs').start();
require('jquery');
require('../stylesheets/application.scss');
require('popper.js');
require('select2');
require('bootstrap');
require('bootstrap-icons/font/bootstrap-icons.css');

window.jQuery = $;
window.$ = $;

$(() => $('[data-toggle="popover"]').popover());
$(() => $('[id^=multiselect]').select2({ width: '100%' }));
