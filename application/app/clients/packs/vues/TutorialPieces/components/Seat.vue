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
  <div v-else-if="termTeacher.vacancyStatus !== 'fixed'" class="border d-flex">
    <unfixed-position
      v-for="positionIndex in positionIndexes"
      v-bind:key="positionIndex"
      :tutorial-piece="tutorialPiece(positionIndex)"
    />
  </div>
  <div v-else class="border d-flex">
    <tutorial-position
      v-for="positionIndex in positionIndexes"
      v-bind:key="positionIndex"
      :is-droppable="isDroppable"
      :is-not-vacant="isNotVacant"
      :is-disabled="isDisabled"
      :tutorial-piece="tutorialPiece(positionIndex)"
      v-on:toggle="$emit('toggle', { ...$event, tutorialPiece: tutorialPiece(positionIndex) })"
      v-on:delete="$emit('delete', { ...$event, tutorialPiece: tutorialPiece(positionIndex) })"
      v-on:dragstart="$emit('dragstart', { ...$event, tutorialPiece: tutorialPiece(positionIndex) })"
      v-on:dragend="$emit('dragend', { ...$event, tutorialPiece: tutorialPiece(positionIndex) })"
      v-on:drop="$emit('drop', { event: $event })"
      v-on:dragover="$emit('dragover', { event: $event })"
    />
  </div>
</template>

<script lang="ts">
import _ from 'lodash';
import Vue, { PropType } from 'vue';

import './ClosedPosition.vue';
import './GroupPosition.vue';
import './TutorialPosition.vue';
import './UnfixedPosition.vue';
import { TutorialPiece, Timetable, TermTeacher } from '../model/Term';

export default Vue.component('seat', {
  props: {
    isDroppable: Boolean,
    isNotVacant: Boolean,
    isDisabled: Boolean,
    positionCount: Number,
    termTeacher: Object as PropType<TermTeacher>,
    timetable: Object as PropType<Timetable>,
    tutorialPieces: Array as PropType<TutorialPiece[]>,
  },
  computed: {
    positionIndexes() {
      return _.range(1, this.positionCount + 1);
    },
  },
  methods: {
    tutorialPiece(positionIndex: number) {
      return this.tutorialPieces[positionIndex - 1];
    },
  },
}) 
</script>
