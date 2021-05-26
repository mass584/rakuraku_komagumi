<template>
  <dropdown-menu
    v-on:unlock-all="unlockAll()"
    v-on:lock-all="lockAll()"
    v-on:reset-all="resetAll()"
  />
</template>

<script lang="ts">
import axios from 'axios';
import Vue from 'vue';

import '../components/DropdownMenu.vue';

export default Vue.component('dropdown-menu-container', {
  methods: {
    async unlockAll() {
      const url = '/tutorial_pieces/bulk_update.json';
      const reqBody = { tutorial_piece: { is_fixed: false } };
      await axios.post(url, reqBody);
      location.reload();
    },
    async lockAll() {
      const url = '/tutorial_pieces/bulk_update.json';
      const reqBody = { tutorial_piece: { is_fixed: true } };
      await axios.post(url, reqBody);
      location.reload();
    },
    async resetAll() {
      const url = '/term_schedules/bulk_reset.json';
      await axios.post(url);
      location.reload();
    },
  },
}) 
</script>
