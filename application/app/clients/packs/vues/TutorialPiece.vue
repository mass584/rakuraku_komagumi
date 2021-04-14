<template>
  <div
    class="piece border text-center bg-warning"
    v-bind:draggable="!tutorialPiece.isFixed"
    v-on:dragstart="$emit('dragstart', { event: $event })"
  >
    {{ displayText }}
  </div>
</template>

<script lang="ts">
import Vue from 'vue';

export default Vue.component('tutorial-piece', {
  props: {
    tutorialPiece: Object,
  },
  computed: {
    displayText() {
      const studentName = this.tutorialPiece.termStudentName;
      const studentSchoolGrade = this.tutorialPiece.termStudentSchoolGrade;
      const tutorialName = this.tutorialPiece.termTutorialName.charAt(0);

      return `${studentSchoolGrade} ${studentName} ${tutorialName}`;
    },
  },
}) 
</script>

<style scoped lang="scss">
.piece {
  cursor: pointer;
  height: 100%;
  width: 100%;
}
</style>
