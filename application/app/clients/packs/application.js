import '../stylesheets/application.scss';
import 'bootstrap';
import 'bootstrap-icons/font/bootstrap-icons.css'
import $ from 'jquery';
import Rails from '@rails/ujs';

global.$ = $;
Rails.start();
