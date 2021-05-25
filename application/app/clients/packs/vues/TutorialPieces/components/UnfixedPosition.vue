<template>
  <div class="d-table">
    <div v-if="tutorialPiece">
      <div
        class="px-1 d-flex align-item-center justify-content-between piece border border-white text-center position bg-warning-light"
      >
        <div>
          <small>{{ displayText }}</small>
        </div>
        <div
          type="button"
          data-toggle="popover"
          title="編集できません"
          data-content="講師、もしくは生徒の予定が提出済みでないため、このコマを編集することはできません。"
        >
          <i class="bi bi-exclamation-circle text-danger"></i>
        </div>
      </div>
    </div>
    <div v-else>
      <div class="text-center d-table-cell align-middle position bg-secondary">
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
  created: function () {
    window.$('[data-toggle="popover"]').popover();
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
