<template>
  <scheduling-table
    v-if="term"
    :seat-count="term.seatCount"
    :position-count="term.positionCount"
    :term-teachers="term.termTeachers"
    :timetables="term.timetables"
    :tutorial-pieces="term.tutorialPieces"
    :droppables="droppables"
    :notVacants="notVacants"
    v-on:dragstart="onDragStart($event.event, $event.timetable, $event.tutorialPiece)"
    v-on:dragend="onDragEnd()"
    v-on:drop="onDrop($event.event, $event.timetable, $event.termTeacher)"
    v-on:dragover="onDragOver($event.event, $event.timetable, $event.termTeacher)"
  />
</template>

<script lang="ts">
import axios from 'axios';
import Vue from 'vue';

import './components/SchedulingTable.vue';
import { Timetable, TermTeacher, TutorialPiece } from './types';
import { validate, isStudentVacant, isTeacherVacant } from './validator';

export default Vue.extend({
  name: 'tutorial_pieces_container',
  data: () => ({
    term: null,
    droppables: [],
    notVacants: [],
  }),
  methods: {
    fetchTutorialPieces: async function() {
      const url = '/tutorial_pieces.json';
      const response = await axios.get(url);
      const { term } = response.data;
      this.term = term;
      return response;
    },
    updateTutorialPiece: async function(tutorialPieceId: number, seatId: number) {
      const url = `/tutorial_pieces/${tutorialPieceId}`;
      const reqBody = { tutorial_piece: { seat_id: seatId } };
      const response = await axios.put(url, reqBody);
      return response;
    },
    onDragStart: function(event, srcTimetable: Timetable, tutorialPiece: TutorialPiece) {
      event.dataTransfer.setData('tutorialPieceId', tutorialPiece.id);
      event.dataTransfer.effectAllowed = 'move';
      event.dataTransfer.dropEffect = 'move';
      const termTeacher = this.term.termTeachers.find((termTeacher) => {
        return termTeacher.id === tutorialPiece.termTeacherId;
      });
      this.droppables = this.term.timetables.filter((timetable) => {
        return validate(
          this.term.periodCount,
          this.term.seatCount,
          this.term.positionCount,
          this.term.studentOptimizationRules,
          this.term.teacherOptimizationRules,
          this.term.timetables,
          srcTimetable,
          timetable,
          termTeacher,
          tutorialPiece,
        );
      }).map((timetable) => {
        return { timetableId: timetable.id, termTeacherId: termTeacher.id };
      });;
      this.notVacants = this.term.timetables.filter((timetable) => {
        return !isStudentVacant(timetable, tutorialPiece) || !isTeacherVacant(timetable, termTeacher)
      }).map((timetable) => {
        return { timetableId: timetable.id, termTeacherId: termTeacher.id };
      });
    },
    onDragEnd: function() {
      this.droppables = [];
      this.notVacants = [];
    },
    onDrop: async function(event, destTimetable: Timetable, termTeacher: TermTeacher) {
      const tutorialPieceId = Number(event.dataTransfer.getData('tutorialPieceId'));
      const termTeacherSeat = destTimetable.seats.find((seat) => {
        return seat.termTeacherId === termTeacher.id;
      });
      const emptySeat = destTimetable.seats.find((seat) => {
        return seat.termTeacherId === null;
      });
      const seatId = termTeacherSeat ? termTeacherSeat.id : emptySeat.id;
      await this.updateTutorialPiece(tutorialPieceId, seatId);
      await this.fetchTutorialPieces();
    },
    onDragOver: function(event, destTimetable: Timetable, termTeacher: TermTeacher) {
      const isDroppable = this.droppables.some((droppable) => {
        return droppable.timetableId === destTimetable.id &&
          droppable.termTeacherId === termTeacher.id;
      });
      if (isDroppable) {
        event.preventDefault();
      }
    },
  },
  created: async function() {
    await this.fetchTutorialPieces();
  },
}) 
</script>

<style scoped lang="scss">
</style>
