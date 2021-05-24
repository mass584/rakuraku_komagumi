<template>
  <div class="d-flex justify-content-between align-items-center h-100">
    <div class="d-flex justify-content-around align-items-center text-center w-100">
      <button
        type="button"
        class="btn btn-outline-secondary btn-sm"
        v-on:click="$emit('pushleft', { termTeacher })"
      >
        ◀︎
      </button>
      <div>{{ termTeacher.termTeacherName }}</div>
      <button
        type="button"
        class="btn btn-outline-secondary btn-sm"
        v-on:click="$emit('pushright', { termTeacher })"
      >
        ▶
      </button>
    </div>
    <div class="d-flex flex-column justify-content-between h-100">
      <div class="my-auto mx-1">
        <select
          class="form-select form-select-sm w-100"
          v-model="selectedId"
        >
          <option value="">
            配置コマを選択
          </option>
          <option
            v-for="tutorialPiece in filteredTutorialPieces"
            v-bind:key="tutorialPiece.id"
            v-bind:value="tutorialPiece.id"
            v-bind:disabled="isDisabledTutorialPiece(tutorialPiece)"
          >
            {{ displayText(tutorialPiece) }}
          </option>
        </select>
      </div>
      <tutorial-position
        :is-droppable="false"
        :tutorial-piece="tutorialPiece"
        v-on:dragstart="$emit('dragstart', { ...$event, tutorialPiece })"
        v-on:dragend="$emit('dragend', { ...$event, tutorialPiece })"
      />
    </div>
  </div>
</template>

<script lang="ts">
import Vue from 'vue';
import './TutorialPosition';

export default Vue.component('stand-by', {
  props: {
    tutorialPieces: Array,
    termTeacher: Object,
    termStudents: Array,
  },
  data: function() {
    return {
      selectedId: '',
    }
  },
  computed: {
    tutorialPiece: function() {
      return this.filteredTutorialPieces.find((tutorialPiece) => {
        return tutorialPiece.id === this.selectedId;
      });
    },
    filteredTutorialPieces: function() {
      return this.tutorialPieces.filter((tutorialPiece) => {
        return tutorialPiece.termTeacherId === this.termTeacher.id &&
          tutorialPiece.seatId === null;
      });
    },
  },
  methods: {
    displayText: function (tutorialPiece) {
      const studentName = tutorialPiece.termStudentName;
      const studentSchoolGrade = tutorialPiece.termStudentSchoolGradeI18n;
      const tutorialName = tutorialPiece.termTutorialName;

      return `${studentSchoolGrade} ${studentName} ${tutorialName}`;
    },
    isDisabledTutorialPiece: function(tutorialPiece) {
      const isUnfixedTeacher = this.termTeacher.vacancyStatus !== 'fixed';
      const isUnfixedStudent = this.termStudents.find((termStudent) => {
        return termStudent.vacancyStatus !== 'fixed' && termStudent.id === tutorialPiece.termStudentId;
      });

      return isUnfixedTeacher || isUnfixedStudent;
    },
  }
}) 
</script>
