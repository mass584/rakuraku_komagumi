import Axios from 'axios';
import Vue from 'vue'
import Vuex from 'vuex'
import Term from './vues/term.vue'

Vue.use(Vuex)

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
    el: '#app',
    render: (h) => h(Term),
  });
})
