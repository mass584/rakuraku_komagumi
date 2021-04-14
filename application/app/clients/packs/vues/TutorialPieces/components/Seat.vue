<template>
  <div v-if="timetable.isClosed" class="border d-flex">
    <closed-position
      v-for="positionIndex in positionIndexes"
      v-bind:key="positionIndex"
    />
  </div>
  <div v-else-if="timetable.termGroupId" class="border d-flex">
    <group-position
      v-for="positionIndex in positionIndexes"
      v-bind:key="positionIndex"
      :timetable="timetable"
      :term-teacher="termTeacher"
    />
  </div>
  <div v-else class="border d-flex">
    <tutorial-position
      v-for="positionIndex in positionIndexes"
      v-bind:key="positionIndex"
      :is-droppable="isDroppable"
      :tutorial-piece="tutorialPiece(positionIndex)"
      v-on:dragstart="$emit('dragstart', { ...$event, tutorialPiece: tutorialPiece(positionIndex) })"
      v-on:drop="$emit('drop', { event: $event })"
      v-on:dragover="$emit('dragover', { event: $event })"
    />
  </div>
</template>

<script lang="ts">
import _ from 'lodash';
import Vue from 'vue';

import './TutorialPosition.vue';
import './GroupPosition.vue';
import './ClosedPosition.vue';

export default Vue.component('seat', {
  props: {
    isDroppable: Boolean,
    positionCount: Number,
    tutorialPieces: Array,
    timetable: Object,
    termTeacher: Object,
  },
  computed: {
    positionIndexes() {
      return _.range(1, this.positionCount + 1);
    },
  },
  methods: {
    tutorialPiece: function(positionIndex) {
      return this.tutorialPieces[positionIndex - 1];
    },
  },
}) 
</script>
