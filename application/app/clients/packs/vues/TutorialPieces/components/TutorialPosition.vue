<template>
  <div
    class="position"
    v-bind:class="{ 'bg-info': isDroppable, 'bg-secondary': isNotVacant || isDisabled }"
    v-on:drop="$emit('drop', $event)"
    v-on:dragover="$emit('dragover', $event)"
    v-on:dragenter.prevent
  >
    <tutorial-piece
      :tutorial-piece="tutorialPiece"
      v-if="tutorialPiece"
      v-on:dragstart="$emit('dragstart', $event)"
      v-on:dragend="$emit('dragend', $event)"
    />
  </div>
</template>

<script lang="ts">
import Vue from 'vue';
import './TutorialPiece.vue';

export default Vue.component('tutorial-position', {
  props: {
    isDroppable: Boolean,
    isNotVacant: Boolean,
    isDisabled: Boolean,
    tutorialPiece: Object,
  },
}) 
</script>

<style scoped lang="scss">
.position {
  height: 28px;
  width: 148px;
}
</style>
