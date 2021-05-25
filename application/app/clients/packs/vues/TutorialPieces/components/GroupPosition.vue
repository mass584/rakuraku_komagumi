<template>
  <div class="d-table">
    <div
      class="text-center d-table-cell align-middle position bg-secondary"
      v-bind:class="{ 'bg-warning-light': timetable.termGroupTeacherIds.includes(termTeacher.id) }"
    >
      <small>{{ timetable.termGroupName }}</small>
    </div>
  </div>
</template>

<script lang="ts">
import Vue, { PropType } from 'vue';

import { Timetable, TermTeacher } from '../model/Term';

export default Vue.component('group-position', {
  props: {
    timetable: Object as PropType<Timetable>,
    termTeacher: Object as PropType<TermTeacher>,
  },
}) 
</script>

<style scoped lang="scss">
.position {
  height: 28px;
  width: 149px;
  min-width: 149px;
}
</style>
