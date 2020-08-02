import Vue from 'vue'
import Vuex from 'vuex'
import Pieces from './vues/pieces.vue'

Vue.use(Vuex)

Vue.config.productionTip = false

document.addEventListener('DOMContentLoaded', () => {
  new Vue({
    el: '#app',
    render: (h) => h(Pieces, { props: { termId: 1 } }),
  });
})
