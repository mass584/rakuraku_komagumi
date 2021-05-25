import Axios from 'axios';
import Vue from 'vue';
import TutorialPiecesContainer from './vues/TutorialPieces/TutorialPiecesContainer';

Vue.config.productionTip = false

document.addEventListener('DOMContentLoaded', () => {
  new Vue({
    el: '#tutorial_pieces_container',
    render: (createElement) => createElement(TutorialPiecesContainer),
  });
});
