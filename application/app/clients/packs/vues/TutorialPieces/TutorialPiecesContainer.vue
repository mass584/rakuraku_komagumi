<template>
  <scheduling-table
    v-if="term"
    :seat-count="term.seatCount"
    :position-count="term.positionCount"
    :term-teachers="term.termTeachers"
    :timetables="term.timetables"
    :tutorial-pieces="term.tutorialPieces"
    :droppables="droppables"
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
import { validate } from './validator';

export default Vue.extend({
  name: 'tutorial_pieces_container',
  data: () => ({
    term: null,
    droppables: [],
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
      this.droppables = this.term.termTeachers.reduce((accu1, destTermTeacher) => {
        return accu1.concat(this.term.timetables.reduce((accu2, destTimetable) => {
          const isValid = validate(
            this.term.periodCount,
            this.term.seatCount,
            this.term.studentOptimizationRules,
            this.term.teacherOptimizationRules,
            this.term.timetables,
            srcTimetable,
            destTimetable,
            destTermTeacher,
            tutorialPiece,
          );
          const droppable = { timetableId: destTimetable.id, termTeacherId: destTermTeacher.id };
          return isValid ? accu2.concat([droppable]) : accu2;
        }, []));
      }, []);
    },
    onDragEnd: function() {
      this.droppables = [];
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
