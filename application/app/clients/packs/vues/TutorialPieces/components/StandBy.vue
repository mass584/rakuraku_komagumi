<template>
  <div class="d-flex justify-content-between h-100 align-items-center">
    <div class="text-center w-100">
      {{ termTeacher.termTeacherName }}
    </div>
    <div class="d-flex flex-column justify-content-between h-100">
      <div class="my-auto mx-1">
        <select class="form-select form-select-sm w-100" v-model="selectedId">
          <option value="">
            未決定コマ
          </option>
          <option
            v-for="tutorialPiece in filteredTutorialPieces"
            v-bind:key="tutorialPiece.id"
            v-bind:value="tutorialPiece.id"
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
      const studentSchoolGrade = tutorialPiece.termStudentSchoolGrade;
      const tutorialName = tutorialPiece.termTutorialName.charAt(0);

      return `${studentSchoolGrade} ${studentName} ${tutorialName}`;
    },
  }
}) 
</script>
