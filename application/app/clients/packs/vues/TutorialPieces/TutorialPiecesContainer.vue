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
import { Timetable, TermTeacher, TutorialPiece, Term, Seat } from './model/Term';
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
    // API呼び出し関数
    fetchTutorialPieces: async function() {
      const url = '/tutorial_pieces.json';
      const response = await axios.get(url);
      const { term } = response.data;
      this.term = term;
    },
    updateTutorialPieceSeatId: async function(tutorialPieceId: number, seatId: number | null) {
      const url = "/term_schedules.json";
      const reqBody = { term_schedule: { seat_id: seatId, tutorial_piece_id: tutorialPieceId } };
      await axios.post(url, reqBody);
    },
    updateTutorialPieceIsFixed: async function(tutorialPieceId: number, isFixed: boolean) {
      const url = `/tutorial_pieces/${tutorialPieceId}.json`;
      const reqBody = { tutorial_piece: { is_fixed: isFixed } };
      await axios.put(url, reqBody);
    },
    updateRowOrder: async function(termTeacher: TermTeacher, rowOrderPosition: 'up' | 'down') {
      const url = `/term_teachers/${termTeacher.id}.json`;
      const reqBody = { term_teacher: { row_order_position: rowOrderPosition } };
      await axios.put(url, reqBody);
    },
    // コンポーネントのコールバック
    onPushLeft: async function(termTeacher: TermTeacher) {
      if (!this.term) return;
      const termTeacherIndex = this.term.termTeachers.findIndex((item) => item.id === termTeacher.id);
      if (termTeacherIndex === 0) return;
      this.isLoading = true;
      await this.updateRowOrder(termTeacher, 'up');
      const nextTermTeacherIndex = termTeacherIndex - 1;
      const newTermTeachers = this.swapTermTeachers(this.term.termTeachers, termTeacherIndex, nextTermTeacherIndex);
      this.term = { ...this.term, termTeachers: newTermTeachers };
      this.isLoading = false;
    },
    onPushRight: async function(termTeacher: TermTeacher) {
      if (!this.term) return;
      const termTeacherIndex = this.term.termTeachers.findIndex((item) => item.id === termTeacher.id);
      if (termTeacherIndex === this.term.termTeachers.length - 1) return;
      this.isLoading = true;
      await this.updateRowOrder(termTeacher, 'down');
      const nextTermTeacherIndex = termTeacherIndex + 1;
      const newTermTeachers = this.swapTermTeachers(this.term.termTeachers, termTeacherIndex, nextTermTeacherIndex);
      this.term = { ...this.term, termTeachers: newTermTeachers };
      this.isLoading = false;
    },
    onClickToggle: async function(tutorialPiece: TutorialPiece) {
      if (!this.term) return;
      this.isLoading = true;
      await this.updateTutorialPieceIsFixed(tutorialPiece.id, !tutorialPiece.isFixed);
      const newTutorialPieces = this.term.tutorialPieces.map((item) => {
        return item.id === tutorialPiece.id ? { ...item, isFixed: !item.isFixed } : item;
      });
      this.term = { ...this.term, tutorialPieces: newTutorialPieces };
      this.isLoading = false;
    },
    onClickDelete: async function(tutorialPiece: TutorialPiece) {
      if (!this.term) return;
      if (tutorialPiece.isFixed) return;
      // srcの取得
      const srcTimetable = this.term.timetables.find((timetable) => {
        return timetable.seats.some((seat) => seat.tutorialPieceIds.includes(tutorialPiece.id));
      });
      const srcSeat = srcTimetable && srcTimetable.seats.find(
        item => item.termTeacherId === tutorialPiece.termTeacherId,
      );
      this.isLoading = true;
      // apiコール
      await this.updateTutorialPieceSeatId(tutorialPiece.id, null);
      // this.termの更新
      const newTutorialPieces = this.term.tutorialPieces.map((item) => {
        return item.id === tutorialPiece.id ? { ...item, seatId: null, isFixed: false } : item;
      });
      const newTimetables = this.getNewTimetables(tutorialPiece, srcTimetable, undefined, srcSeat, undefined); 
      this.term = { ...this.term, tutorialPieces: newTutorialPieces, timetables: newTimetables };
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
      if (!event.dataTransfer) return;
      const tutorialPieceId = Number(event.dataTransfer.getData('tutorialPieceId'));
      if (!this.term) return;
      const tutorialPiece = this.term.tutorialPieces.find(item => item.id === tutorialPieceId);
      if (!tutorialPiece) return;
      const termTeacherSeat = destTimetable.seats.find((seat) => {
        return seat.termTeacherId === termTeacher.id;
      });
      const emptySeat = destTimetable.seats.find((seat) => {
        return seat.termTeacherId === null;
      });
      // srcとdestの取得
      const srcTimetable = this.term.timetables.find((timetable) => {
        return timetable.seats.some((seat) => seat.tutorialPieceIds.includes(tutorialPiece.id));
      });
      const srcSeat = srcTimetable && srcTimetable.seats.find(item => item.termTeacherId === termTeacher.id);
      const destSeat = termTeacherSeat || emptySeat;
      this.isLoading = true;
      // apiコール
      await this.updateTutorialPieceSeatId(tutorialPieceId, destSeat ? destSeat.id : null);
      // this.termの更新
      const newTutorialPieces = this.term.tutorialPieces.map(item => {
        return item.id === tutorialPieceId ? { ...item, seatId: destSeat ? destSeat.id : null } : item;
      });
      const newTimetables = this.getNewTimetables(tutorialPiece, srcTimetable, destTimetable, srcSeat, destSeat); 
      this.term = { ...this.term, tutorialPieces: newTutorialPieces, timetables: newTimetables };
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
    // ヘルパー関数
    swapTermTeachers: function(termTeachers: TermTeacher[], index1: number, index2: number) {
      return termTeachers.reduce(
        (resultArray, item, currentIndex, originalArray) => {
          return [
            ...resultArray,
            currentIndex === index1 ? originalArray[index2] :
            currentIndex === index2 ? originalArray[index1] :
            item,
          ]
        },
        [] as TermTeacher[]
      );
    },
    getNewTimetables: function(
      tutorialPiece: TutorialPiece,
      srcTimetable?: Timetable,
      destTimetable?: Timetable,
      srcSeat?: Seat,
      destSeat?: Seat,
    ): Timetable[] {
      if (!this.term) return [];

      return this.term.timetables.map((timetable) => {
        const newOccupiedTermTeacherIds = (() => {
          const srcSeatWillBeEmpty = timetable.seats.find((seat) => {
            return seat.tutorialPieceIds.includes(tutorialPiece.id) &&
              seat.tutorialPieceIds.length === 1;
          });
          const destSeatWasEmpty = destTimetable &&
            !destTimetable.occupiedTermTeacherIds.includes(tutorialPiece.termTeacherId);
          if (srcTimetable && srcTimetable.id === timetable.id && srcSeatWillBeEmpty) {
            return timetable.occupiedTermTeacherIds.filter(
              occupiedTermTeacherId => occupiedTermTeacherId !== tutorialPiece.termTeacherId,
            );
          } else if (srcTimetable && srcTimetable.id === timetable.id && !srcSeatWillBeEmpty) {
            return timetable.occupiedTermTeacherIds;
          } else if (destTimetable && destTimetable.id === timetable.id && destSeatWasEmpty) {
            return timetable.occupiedTermTeacherIds.concat(tutorialPiece.termTeacherId);
          } else if (destTimetable && destTimetable.id === timetable.id && !destSeatWasEmpty) {
            return timetable.occupiedTermTeacherIds;
          } else {
            return timetable.occupiedTermTeacherIds;
          }
        })();
        const newOccupiedTermStudentIds = (() => {
          if (srcTimetable && srcTimetable.id === timetable.id) {
            return timetable.occupiedTermStudentIds.filter(
              occupiedTermStudentId => occupiedTermStudentId !== tutorialPiece.termStudentId,
            );
          } else if (destTimetable && destTimetable.id === timetable.id) {
            return timetable.occupiedTermStudentIds.concat(tutorialPiece.termStudentId);
          } else {
            return timetable.occupiedTermStudentIds;
          }
        })();
        const newSeats = timetable.seats.map((seat) => {
          const srcSeatWillBeEmpty = timetable.seats.find((seat) => {
            return seat.tutorialPieceIds.includes(tutorialPiece.id) && seat.tutorialPieceIds.length === 1;
          });
          const isSrcSeat = srcSeat && seat.id === srcSeat.id;
          const isDestSeat = destSeat && seat.id === destSeat.id;
          const newTutorialPieceIds = (() => {
            if (isSrcSeat) {
              return seat.tutorialPieceIds.filter(
                tutorialPieceId => tutorialPieceId !== tutorialPiece.id,
              );
            } else if (isDestSeat) {
              return seat.tutorialPieceIds.concat(tutorialPiece.id);
            } else {
              return seat.tutorialPieceIds;
            };
          })();
          const newTermTeacherId = (() => {
            if (srcSeat && isSrcSeat && srcSeatWillBeEmpty) {
              return null;
            } else if (srcSeat && isSrcSeat && !srcSeatWillBeEmpty) {
              return tutorialPiece.termTeacherId;
            } else if (destSeat && isDestSeat) {
              return tutorialPiece.termTeacherId;
            } else {
              return seat.termTeacherId;
            };
          })();

          return {
            ...seat,
            termTeacherId: newTermTeacherId,
            tutorialPieceIds: newTutorialPieceIds,
          }
        });

        return {
          ...timetable,
          occupiedTermTeacherIds: newOccupiedTermTeacherIds,
          occupiedTermStudentIds: newOccupiedTermStudentIds,
          seats: newSeats,
        }
      });
    },
  },
  created: async function() {
    this.isLoading = true;
    await this.fetchTutorialPieces();
    this.isLoading = false;
  },
}) 
</script>
