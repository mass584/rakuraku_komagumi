<template>
  <div
    class="px-1 d-flex align-item-center justify-content-between piece border text-center bg-warning"
    v-bind:class="{ 'bg-warning-light': tutorialPiece.isFixed }"
    v-bind:draggable="!tutorialPiece.isFixed"
    v-on:dragstart="$emit('dragstart', { event: $event })"
    v-on:dragend="$emit('dragend', { event: $event })"
  >
    <div>
      <small>{{ displayText }}</small>
    </div>
    <div>
      <i v-on:click="$emit('toggle', { event: $event })" class="bi bi-key"></i>
      <i v-on:click="$emit('delete', { event: $event })" class="bi bi-x-circle"></i>
    </div>
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
      const studentSchoolGrade = this.tutorialPiece.termStudentSchoolGradeI18n;
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
