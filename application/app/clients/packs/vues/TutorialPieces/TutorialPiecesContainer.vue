<template>
  <div>
    <scheduling-table-container v-if="isLoaded" />
    <div v-if="isLoading" id="modal-loader" class="modal modal-backdrop d-block show" tabindex="-1" role="dialog">
      <div class="modal-dialog modal-dialog-centered">
        <div class="spinner-border text-primary m-auto" role="status" />
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import axios from 'axios';
import _ from 'lodash';
import Vue from 'vue';

import './containers/SchedulingTable.vue';
import { store } from './store';

export default Vue.extend({
  name: 'tutorial_pieces_container',
  computed: {
    isLoaded() {
      return store.state.isLoaded;
    },
    isLoading() {
      return store.state.isLoading;
    },
  },
  methods: {
    fetchTutorialPieces: async function() {
      const url = '/tutorial_pieces.json';
      const response = await axios.get(url);
      const { term } = response.data;
      store.commit('setTermObject', term);
    },
  },
  created: async function() {
    store.commit('setIsLoading', true);
    await this.fetchTutorialPieces();
    store.commit('setIsLoading', false);
  },
}) 
</script>
