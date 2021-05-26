<template>
  <div
    :id="`stand_by_${termTeacher.id}`"
    class="d-flex justify-content-between align-items-center h-100"
  >
    <div class="d-flex justify-content-around align-items-center text-center w-100">
      <button
        :id="`left_button_${termTeacher.id}`"
        type="button"
        class="btn btn-light btn-sm"
        v-on:click="$emit('pushleft', { ...$event, termTeacher })"
      >
        ◀︎
      </button>
      <div>{{ termTeacher.termTeacherName }}</div>
      <button
        :id="`right_button_${termTeacher.id}`"
        type="button"
        class="btn btn-light btn-sm"
        v-on:click="$emit('pushright', { ...$event, termTeacher })"
      >
        ▶
      </button>
    </div>
    <div class="d-flex flex-column justify-content-between h-100">
      <div class="my-auto mx-1">
        <select
          :id="`tutorial_piece_select_${termTeacher.id}`"
          class="form-select form-select-sm w-100"
          v-model="selectedId"
        >
          <option value="null">
            配置コマを選択
          </option>
          <option
            v-for="tutorialPiece in uninstalledTutorialPieces"
            v-bind:key="tutorialPiece.id"
            v-bind:value="tutorialPiece.id"
            v-bind:disabled="isDisabledTutorialPiece(tutorialPiece)"
          >
            {{ displayText(tutorialPiece) }}
          </option>
        </select>
      </div>
      <tutorial-position
        :id="`stand_by_tutorial_position_${termTeacher.id}`"
        :is-droppable="false"
        :tutorial-piece="tutorialPiece"
        v-on:dragstart="$emit('dragstart', { ...$event, tutorialPiece })"
        v-on:dragend="$emit('dragend', { ...$event, tutorialPiece })"
      />
    </div>
  </div>
</template>

<script lang="ts">
import Vue, { PropType } from 'vue';

import './TutorialPosition';
import { TutorialPiece, TermTeacher, TermStudent } from '../model/Term';

export default Vue.component('stand-by', {
  props: {
    termTeacher: Object as PropType<TermTeacher>,
    termStudents: Array as PropType<TermStudent[]>,
    tutorialPieces: Array as PropType<TutorialPiece[]>,
  },
  data(): { selectedId: null | number } {
    return {
      selectedId: null,
    }
  },
  computed: {
    uninstalledTutorialPieces(): TutorialPiece[] {
      return this.tutorialPieces.filter((tutorialPiece) => {
        return tutorialPiece.termTeacherId === this.termTeacher.id &&
          tutorialPiece.seatId === null;
      });
    },
    tutorialPiece(): TutorialPiece | undefined {
      return this.uninstalledTutorialPieces.find((tutorialPiece) => {
        return tutorialPiece.id === this.selectedId;
      });
    },
  },
  methods: {
    displayText(tutorialPiece: TutorialPiece) {
      const studentName = tutorialPiece.termStudentName;
      const studentSchoolGrade = tutorialPiece.termStudentSchoolGradeI18n;
      const tutorialName = tutorialPiece.termTutorialName;

      return `${studentSchoolGrade} ${studentName} ${tutorialName}`;
    },
    isDisabledTutorialPiece(tutorialPiece: TutorialPiece) {
      const isUnfixedTeacher = this.termTeacher.vacancyStatus !== 'fixed';
      const isUnfixedStudent = this.termStudents.find((termStudent) => {
        return termStudent.vacancyStatus !== 'fixed' &&
          termStudent.id === tutorialPiece.termStudentId;
      });

      return isUnfixedTeacher || isUnfixedStudent;
    },
  }
}) 
</script>
