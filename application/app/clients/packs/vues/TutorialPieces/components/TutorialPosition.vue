<template>
  <div
    class="position"
    v-bind:class="{ 'bg-info': isDroppable, 'bg-secondary': isNotVacant || isDisabled }"
    v-on:drop="$emit('drop', $event)"
    v-on:dragover="$emit('dragover', $event)"
    v-on:dragenter.prevent
  >
    <tutorial-piece-container
      :tutorial-piece="tutorialPiece"
      v-if="tutorialPiece"
      v-on:dragstart="$emit('dragstart', $event)"
      v-on:dragend="$emit('dragend', $event)"
    />
  </div>
</template>

<script lang="ts">
import Vue, { PropType } from 'vue';

import '../containers/TutorialPiece.vue';
import { TutorialPiece } from '../model/Term';

export default Vue.component('tutorial-position', {
  props: {
    isDroppable: Boolean,
    isNotVacant: Boolean,
    isDisabled: Boolean,
    tutorialPiece: Object as PropType<TutorialPiece>,
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
