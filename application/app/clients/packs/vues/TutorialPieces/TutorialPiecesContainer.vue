<template>
  <div>
    <scheduling-table
      v-if="term"
      :term-type="term.termType"
      :seat-count="term.seatCount"
      :position-count="term.positionCount"
      :begin-at="term.beginAt"
      :selected-term-teacher-id="selectedTermTeacherId"
      :term-teachers="term.termTeachers"
      :term-students="term.termStudents"
      :timetables="term.timetables"
      :tutorial-pieces="term.tutorialPieces"
      :droppables="droppables"
      :notVacants="notVacants"
      v-on:toggle="onClickToggle($event.tutorialPiece)"
      v-on:delete="onClickDelete($event.tutorialPiece)"
      v-on:pushleft="onPushLeft($event.termTeacher)"
      v-on:pushright="onPushRight($event.termTeacher)"
      v-on:dragstart="onDragStart($event.event, $event.timetable, $event.tutorialPiece)"
      v-on:dragend="onDragEnd()"
      v-on:drop="onDrop($event.event, $event.timetable, $event.termTeacher)"
      v-on:dragover="onDragOver($event.event, $event.timetable, $event.termTeacher)"
    />
    <div v-if="isLoading" class="modal modal-backdrop d-block show" tabindex="-1" role="dialog">
      <div class="modal-dialog modal-dialog-centered">
        <div class="spinner-border text-primary m-auto" role="status" />
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import axios from 'axios';
import _ from 'lodash';
import Vue from 'vue';

import './components/SchedulingTable.vue';
import { Timetable, TermTeacher, TutorialPiece, Term } from './model/Term';
import { Position } from './model/Position';
import { validate, isStudentVacant, isTeacherVacant } from './validator';

export default Vue.extend({
  name: 'tutorial_pieces_container',
  data(): {
    isLoading: boolean;
    selectedTermTeacherId: number | null;
    term: Term | null;
    droppables: Position[];
    notVacants: Position[];
  } {
    return {
      isLoading: false,
      term: null,
      selectedTermTeacherId: null,
      droppables: [],
      notVacants: [],
    }
  },
  methods: {
    fetchTutorialPieces: async function() {
      const url = '/tutorial_pieces.json';
      const response = await axios.get(url);
      const { term } = response.data;
      this.term = term;
      return response;
    },
    updateTutorialPiece: async function(tutorialPieceId: number, seatId: number | null, isFixed: boolean) {
      const url1 = "/term_schedules";
      const reqBody1 = { term_schedule: { seat_id: seatId, tutorial_piece_id: tutorialPieceId } };
      await axios.post(url1, reqBody1);
      const url2 = `/tutorial_pieces/${tutorialPieceId}.json`;
      const reqBody2 = { tutorial_piece: { is_fixed: isFixed } };
      await axios.put(url2, reqBody2);
    },
    updateRowOrder: async function(termTeacher: TermTeacher, rowOrderPosition: 'up' | 'down') {
      const url = `/term_teachers/${termTeacher.id}.json`;
      const reqBody = { term_teacher: { row_order_position: rowOrderPosition } };
      const response = await axios.put(url, reqBody);
      return response;
    },
    onCreate: async function() {
      this.isLoading = true;
      await this.fetchTutorialPieces();
      this.isLoading = false;
    },
    onPushLeft: async function(termTeacher: TermTeacher) {
      this.isLoading = true;
      await this.updateRowOrder(termTeacher, 'up');
      await this.fetchTutorialPieces();
      this.isLoading = false;
    },
    onPushRight: async function(termTeacher: TermTeacher) {
      this.isLoading = true;
      await this.updateRowOrder(termTeacher, 'down');
      await this.fetchTutorialPieces();
      this.isLoading = false;
    },
    onClickToggle: async function(tutorialPiece: TutorialPiece) {
      this.isLoading = true;
      await this.updateTutorialPiece(tutorialPiece.id, tutorialPiece.seatId, !tutorialPiece.isFixed);
      await this.fetchTutorialPieces();
      this.isLoading = false;
    },
    onClickDelete: async function(tutorialPiece: TutorialPiece) {
      this.isLoading = true;
      await this.updateTutorialPiece(tutorialPiece.id, null, false);
      await this.fetchTutorialPieces();
      this.isLoading = false;
    },
    onDragStart: function(event: DragEvent, srcTimetable: Timetable, tutorialPiece: TutorialPiece) {
      if (!this.term || !event.dataTransfer) return;
      event.dataTransfer.setData('tutorialPieceId', String(tutorialPiece.id));
      event.dataTransfer.effectAllowed = 'move';
      event.dataTransfer.dropEffect = 'move';
      const termTeacher = this.term.termTeachers.find((termTeacher) => {
        return termTeacher.id === tutorialPiece.termTeacherId;
      });
      if (!termTeacher) return;
      this.droppables = this.term.timetables.filter((timetable) => {
        return this.term && validate(
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
        return !isStudentVacant(timetable, tutorialPiece) || !isTeacherVacant(timetable, termTeacher);
      }).map((timetable) => {
        return { timetableId: timetable.id, termTeacherId: termTeacher.id };
      });
      this.selectedTermTeacherId = termTeacher.id;
    },
    onDragEnd: function() {
      this.droppables = [];
      this.notVacants = [];
      this.selectedTermTeacherId = null;
    },
    onDrop: async function(event: DragEvent, destTimetable: Timetable, termTeacher: TermTeacher) {
      if (!this.term || !event.dataTransfer) return;
      const tutorialPieceId = Number(event.dataTransfer.getData('tutorialPieceId'));
      const termTeacherSeat = destTimetable.seats.find((seat) => {
        return seat.termTeacherId === termTeacher.id;
      });
      const emptySeat = destTimetable.seats.find((seat) => {
        return seat.termTeacherId === null;
      });
      const seatId = termTeacherSeat ? termTeacherSeat.id : emptySeat ? emptySeat.id : null;
      this.isLoading = true;
      await this.updateTutorialPiece(tutorialPieceId, seatId, false);
      await this.fetchTutorialPieces();
      this.isLoading = false;
    },
    onDragOver: function(event: DragEvent, destTimetable: Timetable, termTeacher: TermTeacher) {
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
    await this.onCreate();
  },
}) 
</script>
