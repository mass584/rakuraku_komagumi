<template>
  <div class="border d-flex w-300px">
    <div v-for="positionIndex in positionIndexes" v-bind:key="positionIndex">
      <div v-if="timetable.isClosed">
        <closed-position />
      </div>
      <div v-else-if="timetable.termGroupId">
        <group-position :timetable="timetable" :term-teacher="termTeacher" />
      </div>
      <div v-else-if="termTeacherUnfixed()">
        <unfixed-position :tutorial-piece="tutorialPiece(positionIndex)" />
      </div>
      <div v-else-if="termStudentUnfixed(positionIndex)">
        <unfixed-position :tutorial-piece="tutorialPiece(positionIndex)" />
      </div>
      <div v-else>
        <tutorial-position
          :is-droppable="isDroppable"
          :is-not-vacant="isNotVacant"
          :is-disabled="isDisabled"
          :tutorial-piece="tutorialPiece(positionIndex)"
          v-on:dragstart="$emit('dragstart', { ...$event, tutorialPiece: tutorialPiece(positionIndex) })"
          v-on:dragend="$emit('dragend', { ...$event, tutorialPiece: tutorialPiece(positionIndex) })"
          v-on:drop="$emit('drop', { event: $event })"
          v-on:dragover="$emit('dragover', { event: $event })"
        />
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import Vue, { PropType } from 'vue';

import './ClosedPosition.vue';
import './GroupPosition.vue';
import './TutorialPosition.vue';
import './UnfixedPosition.vue';
import { TutorialPiece, Timetable, TermTeacher, TermStudent } from '../model/Term';

export default Vue.component('seat', {
  props: {
    isDroppable: Boolean,
    isNotVacant: Boolean,
    isDisabled: Boolean,
    positionCount: Number,
    termTeacher: Object as PropType<TermTeacher>,
    termStudents: Array as PropType<TermStudent[]>,
    timetable: Object as PropType<Timetable>,
    tutorialPieces: Array as PropType<TutorialPiece[]>,
  },
  computed: {
    positionIndexes() {
      return Array.from({ length: this.positionCount }, (_, i) => i + 1);
    },
  },
  methods: {
    tutorialPiece(positionIndex: number) {
      return this.tutorialPieces[positionIndex - 1];
    },
    termTeacherUnfixed() {
      return this.termTeacher.vacancyStatus !== 'fixed';
    },
    termStudentUnfixed(positionIndex: number) {
      const tutorialPiece = this.tutorialPiece(positionIndex);
      const termStudent = this.termStudents.find((termStudent) => {
        return tutorialPiece && termStudent.id === tutorialPiece.termStudentId;
      });

      return termStudent ? termStudent.vacancyStatus !== 'fixed' : false;
    }
  },
}) 
</script>

<style scoped lang="scss">
.w-300px {
  width: 300px;
}
</style>
