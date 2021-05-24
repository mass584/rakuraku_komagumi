<template>
  <div>
    <scheduling-table
      v-if="isLoaded"
      :term="term"
      :term-teachers="termTeachers"
      :term-students="termStudents"
      :timetables="timetables"
      :tutorial-pieces="tutorialPieces"
      :droppables="droppables"
      :notVacants="notVacants"
      :selected-term-teacher-id="selectedTermTeacherId"
      v-on:toggle="onClickToggle($event.tutorialPiece)"
      v-on:delete="onClickDelete($event.tutorialPiece)"
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
import { Timetable, TermTeacher, TutorialPiece, Seat } from './model/Term';
import { validate, isStudentVacant, isTeacherVacant } from './validator';
import { store } from './store';

export default Vue.extend({
  name: 'tutorial_pieces_container',
  computed: {
    term() {
      return store.state.term;
    },
    termTeachers() {
      return store.state.termTeachers;
    },
    termStudents() {
      return store.state.termStudents;
    },
    timetables() {
      return store.state.timetables;
    },
    tutorialPieces() {
      return store.state.tutorialPieces;
    },
    teacherOptimizationRules() {
      return store.state.teacherOptimizationRules;
    },
    studentOptimizationRules() {
      return store.state.studentOptimizationRules;
    },
    isLoading() {
      return store.state.isLoading;
    },
    isLoaded() {
      return store.state.isLoaded;
    },
    selectedTermTeacherId() {
      return store.state.selectedTermTeacherId;
    },
    droppables() {
      return store.state.droppables;
    },
    notVacants() {
      return store.state.notVacants;
    },
  },
  methods: {
    // API呼び出し関数
    fetchTutorialPieces: async function() {
      const url = '/tutorial_pieces.json';
      const response = await axios.get(url);
      const { term } = response.data;
      store.commit('setTermObject', term);
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
    // コンポーネントのコールバック
    onClickToggle: async function(tutorialPiece: TutorialPiece) {
      store.commit('setIsLoading', true);
      await this.updateTutorialPieceIsFixed(tutorialPiece.id, !tutorialPiece.isFixed);
      const newTutorialPieces = this.tutorialPieces.map((item) => {
        return item.id === tutorialPiece.id ? { ...item, isFixed: !item.isFixed } : item;
      });
      store.commit('setTutorialPieces', newTutorialPieces);
      store.commit('setIsLoading', false);
    },
    onClickDelete: async function(tutorialPiece: TutorialPiece) {
      if (tutorialPiece.isFixed) return;
      // srcの取得
      const srcTimetable = this.timetables.find((timetable) => {
        return timetable.seats.some((seat) => seat.tutorialPieceIds.includes(tutorialPiece.id));
      });
      const srcSeat = srcTimetable && srcTimetable.seats.find(
        item => item.termTeacherId === tutorialPiece.termTeacherId,
      );
      store.commit('setIsLoading', true);
      // apiコール
      await this.updateTutorialPieceSeatId(tutorialPiece.id, null);
      // this.termの更新
      const newTutorialPieces = this.tutorialPieces.map((item) => {
        return item.id === tutorialPiece.id ? { ...item, seatId: null, isFixed: false } : item;
      });
      const newTimetables = this.getNewTimetables(tutorialPiece, srcTimetable, undefined, srcSeat, undefined); 
      store.commit('setTimetables', newTimetables);
      store.commit('setTutorialPieces', newTutorialPieces);
      store.commit('setIsLoading', false);
    },
    onDragStart: function(event: DragEvent, srcTimetable: Timetable, tutorialPiece: TutorialPiece) {
      if (!event.dataTransfer) return;
      event.dataTransfer.setData('tutorialPieceId', String(tutorialPiece.id));
      event.dataTransfer.effectAllowed = 'move';
      event.dataTransfer.dropEffect = 'move';
      const termTeacher = this.termTeachers.find((termTeacher) => {
        return termTeacher.id === tutorialPiece.termTeacherId;
      });
      if (!termTeacher) return;
      store.commit('setDroppables', this.timetables.filter((timetable) => {
        return this.term && validate(
          this.term.periodCount,
          this.term.seatCount,
          this.term.positionCount,
          this.studentOptimizationRules,
          this.teacherOptimizationRules,
          this.timetables,
          srcTimetable,
          timetable,
          termTeacher,
          tutorialPiece,
        );
      }).map((timetable) => {
        return { timetableId: timetable.id, termTeacherId: termTeacher.id };
      }));
      store.commit('setNotVacants', this.timetables.filter((timetable) => {
        return !isStudentVacant(timetable, tutorialPiece) || !isTeacherVacant(timetable, termTeacher);
      }).map((timetable) => {
        return { timetableId: timetable.id, termTeacherId: termTeacher.id };
      }));
      store.commit('setSelectedTermTeacherId', termTeacher.id);
    },
    onDragEnd: function() {
      store.commit('resetDragState');
    },
    onDrop: async function(event: DragEvent, destTimetable: Timetable, termTeacher: TermTeacher) {
      if (!event.dataTransfer) return;
      const tutorialPieceId = Number(event.dataTransfer.getData('tutorialPieceId'));
      const tutorialPiece = this.tutorialPieces.find(item => item.id === tutorialPieceId);
      if (!tutorialPiece) return;
      const termTeacherSeat = destTimetable.seats.find((seat) => {
        return seat.termTeacherId === termTeacher.id;
      });
      const emptySeat = destTimetable.seats.find((seat) => {
        return seat.termTeacherId === null;
      });
      // srcとdestの取得
      const srcTimetable = this.timetables.find((timetable) => {
        return timetable.seats.some((seat) => seat.tutorialPieceIds.includes(tutorialPiece.id));
      });
      const srcSeat = srcTimetable && srcTimetable.seats.find(item => item.termTeacherId === termTeacher.id);
      const destSeat = termTeacherSeat || emptySeat;
      store.commit('setIsLoading', true);
      // apiコール
      await this.updateTutorialPieceSeatId(tutorialPieceId, destSeat ? destSeat.id : null);
      // this.termの更新
      const newTutorialPieces = this.tutorialPieces.map(item => {
        return item.id === tutorialPieceId ? { ...item, seatId: destSeat ? destSeat.id : null } : item;
      });
      const newTimetables = this.getNewTimetables(tutorialPiece, srcTimetable, destTimetable, srcSeat, destSeat); 
      store.commit('setTutorialPieces', newTutorialPieces);
      store.commit('setTimetables', newTimetables);
      store.commit('setIsLoading', false);
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
    getNewTimetables: function(
      tutorialPiece: TutorialPiece,
      srcTimetable?: Timetable,
      destTimetable?: Timetable,
      srcSeat?: Seat,
      destSeat?: Seat,
    ): Timetable[] {
      return this.timetables.map((timetable) => {
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
    store.commit('setIsLoading', true);
    await this.fetchTutorialPieces();
    store.commit('setIsLoading', false);
  },
}) 
</script>
