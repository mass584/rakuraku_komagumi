import '../stylesheets/application.scss';
import 'bootstrap';
import $ from 'jquery';
import Rails from '@rails/ujs';

global.$ = $;
Rails.start();
