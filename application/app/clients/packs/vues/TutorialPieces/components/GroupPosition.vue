<template>
  <div class="d-table">
    <div
      class="text-center d-table-cell align-middle position bg-secondary"
      v-bind:class="{ 'bg-warning-light': timetable.termGroupTeacherId === termTeacher.id }"
    >
      <small>{{ timetable.termGroupName }}</small>
    </div>
  </div>
</template>

<script lang="ts">
import Vue from 'vue';

export default Vue.component('group-position', {
  props: {
    timetable: Object,
    termTeacher: Object,
  },
}) 
</script>

<style scoped lang="scss">
.position {
  height: 28px;
  width: 148px;
}
</style>
