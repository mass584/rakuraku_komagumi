<template>
  <div class="d-table">
    <div
      class="text-center d-table-cell align-middle position bg-secondary"
      v-bind:class="{ 'bg-warning-light': tutorialPiece }"
    >
      <div v-if="tutorialPiece">
        <small>{{ displayText }}</small>
      </div>
      <div v-else>
        <small>予定未確定</small>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import Vue, { PropType } from 'vue';

import './TutorialPiece.vue';
import { TutorialPiece } from '../model/Term';

export default Vue.component('unfixed-position', {
  props: {
    tutorialPiece: Object as PropType<TutorialPiece>,
  },
  computed: {
    displayText() {
      const studentName = this.tutorialPiece.termStudentName;
      const studentSchoolGrade = this.tutorialPiece.termStudentSchoolGradeI18n;
      const tutorialName = this.tutorialPiece.termTutorialName;

      return `${studentSchoolGrade} ${studentName} ${tutorialName}`;
    },
  },
}) 
</script>

<style scoped lang="scss">
.position {
  height: 28px;
  width: 148px;
  min-width: 148px;
}
</style>
