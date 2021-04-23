import Axios from 'axios';
import Vue from 'vue';
import PieChartContainer from './vues/ShowTerm/PieChartContainer';

Vue.config.productionTip = false

Axios.interceptors.request.use((config) => {
  const csrf = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
  if(['post', 'put', 'patch', 'delete'].includes(config.method)) {
    config.headers['X-CSRF-Token'] = csrf;
  }
  return config;
}, (error) => {
  return Promise.reject(error);
});

document.addEventListener('DOMContentLoaded', () => {
  new Vue({
    el: '#pie_chart_container',
    render: (createElement) => createElement(PieChartContainer),
  });
});
