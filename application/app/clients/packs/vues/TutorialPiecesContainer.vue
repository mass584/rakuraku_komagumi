<template>
  <scheduling-table
    :count="count"
    :term-teachers="termTeachers"
    :timetables="timetables"
    :tutorial-pieces="tutorialPieces"
    :droppables="droppables"
    v-on:dragstart="onDragStart($event.event, $event.timetable, $event.tutorialPiece)"
    v-on:drop="onDrop($event.event, $event.timetable, $event.termTeacher)"
    v-on:dragover="onDragOver($event.event, $event.timetable, $event.termTeacher)"
  />
</template>

<script lang="ts">
import axios from 'axios';
import Vue from 'vue';

import './SchedulingTable.vue';
import { Timetable, TermTeacher, TutorialPiece } from './TutorialPieces/types';
import { validate } from './TutorialPieces/validator';

export default Vue.extend({
  name: 'tutorial_pieces_container',
  data: () => ({
    count: null,
    studentOptimizationRules: [],
    teacherOptimizationRules: [],
    termTeachers: [],
    timetables: [],
    tutorialPieces: [],
    droppables: [],
  }),
  methods: {
    fetchTutorialPieces: async function() {
      const url = '/tutorial_pieces.json';
      const response = await axios.get(url);
      const { term } = response.data;
      this.count = {
        dateCount: term.dateCount,
        periodCount: term.periodCount,
        seatCount: term.seatCount,
        positionCount: term.positionCount,
      };
      this.studentOptimizationRules = term.studentOptimizationRules;
      this.teacherOptimizationRules = term.teacherOptimizationRules;
      this.termTeachers = term.termTeachers;
      this.timetables = term.timetables;
      this.tutorialPieces = term.tutorialPieces;
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
      this.droppables = this.termTeachers.reduce((accu1, destTermTeacher) => {
        return accu1.concat(this.timetables.reduce((accu2, destTimetable) => {
          const isValid = validate(
            this.count,
            this.studentOptimizationRules,
            this.teacherOptimizationRules,
            this.timetables,
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
      this.droppables = [];
    },
    onDragOver: function(event, destTimetable: Timetable, termTeacher: TermTeacher) {
      if (this.isDroppable(destTimetable, termTeacher)) {
        event.preventDefault();
      }
    },
    isDroppable: function(timetable: Timetable, termTeacher: TermTeacher) {
      return this.droppables.some((droppable) => {
        return droppable.timetableId === timetable.id &&
          droppable.termTeacherId === termTeacher.id;
      });
    },
  },
  created: async function() {
    await this.fetchTutorialPieces();
  },
}) 
</script>

<style scoped lang="scss">
</style>
