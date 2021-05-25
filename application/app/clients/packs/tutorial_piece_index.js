import Axios from 'axios';
import Vue from 'vue';
import TutorialPiecesContainer from './vues/TutorialPieces/TutorialPiecesContainer';

Vue.config.productionTip = false

Axios.interceptors.request.use((config) => {
  const querySelector = document.querySelector('meta[name="csrf-token"]');
  const csrfToken = querySelector ? querySelector.getAttribute('content') : '';
  if(['post', 'put', 'patch', 'delete'].includes(config.method)) {
    config.headers['X-CSRF-Token'] = csrfToken;
  }
  return config;
}, (error) => {
  return Promise.reject(error);
});

document.addEventListener('DOMContentLoaded', () => {
  new Vue({
    el: '#tutorial_pieces_container',
    render: (createElement) => createElement(TutorialPiecesContainer),
  });
});
