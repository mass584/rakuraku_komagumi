<template>
  <tutorial-piece
    :tutorial-piece="tutorialPiece"
    :is-deletion-error="isDeletionError"
    v-on:dragstart="$emit('dragstart', $event)"
    v-on:dragend="$emit('dragend', $event)"
    v-on:closemodal="isDeletionError = false"
    v-on:toggle="onClickToggle()"
    v-on:delete="onClickDelete()"
  />
</template>

<script lang="ts">
import axios from 'axios';
import Vue, { PropType } from 'vue';

import '../components/TutorialPiece';
import { TutorialPiece, Timetable, Seat } from '../model/Term';
import { store } from '../store';

export default Vue.component('tutorial-piece-container', {
  props: {
    tutorialPiece: Object as PropType<TutorialPiece>,
  },
  data(): {
    isDeletionError: boolean;
  } {
    return {
      isDeletionError: false,
    }
  },
  computed: {
    timetables() {
      return store.state.timetables;
    },
    tutorialPieces() {
      return store.state.tutorialPieces;
    },
  },
  methods: {
    updateTutorialPieceSeatId: async function(tutorialPieceId: number, seatId: number | null) {
      try {
        const url = "/term_schedules.json";
        const reqBody = { term_schedule: { seat_id: seatId, tutorial_piece_id: tutorialPieceId } };
        await axios.post(url, reqBody);
      } catch (error) {
        switch (error.message) {
          case 'Request failed with status code 400':
            throw new Error('BadRequest');
          default:
            throw new Error('UnexpectedError');
        }
      }
    },
    updateTutorialPieceIsFixed: async function(tutorialPieceId: number, isFixed: boolean) {
      const url = `/tutorial_pieces/${tutorialPieceId}.json`;
      const reqBody = { tutorial_piece: { is_fixed: isFixed } };
      await axios.put(url, reqBody);
    },
    onClickToggle: async function() {
      store.commit('setIsLoading', true);
      await this.updateTutorialPieceIsFixed(this.tutorialPiece.id, !this.tutorialPiece.isFixed);
      const newTutorialPieces = this.tutorialPieces.map((item) => {
        return item.id === this.tutorialPiece.id ? { ...item, isFixed: !item.isFixed } : item;
      });
      store.commit('setTutorialPieces', newTutorialPieces);
      store.commit('setIsLoading', false);
    },
    onClickDelete: async function() {
      if (this.tutorialPiece.isFixed) return;
      const srcTimetable = this.timetables.find((timetable) => {
        return timetable.seats.some((seat) => seat.tutorialPieceIds.includes(this.tutorialPiece.id));
      });
      if (!srcTimetable) return;
      const srcSeat = srcTimetable.seats.find(
        item => item.termTeacherId === this.tutorialPiece.termTeacherId,
      );
      if (!srcSeat) return;
      store.commit('setIsLoading', true);
      try {
        await this.updateTutorialPieceSeatId(this.tutorialPiece.id, null);
        const newTutorialPieces = this.tutorialPieces.map((item) => {
          return item.id === this.tutorialPiece.id ? { ...item, seatId: null, isFixed: false } : item;
        });
        const newTimetables = this.getNewTimetables(this.tutorialPiece, srcTimetable, srcSeat); 
        store.commit('setTutorialPieces', newTutorialPieces);
        store.commit('setTimetables', newTimetables);
      } catch {
        this.isDeletionError = true;
      }
      store.commit('setIsLoading', false);
    },
    getNewTimetables: function(
      tutorialPiece: TutorialPiece,
      srcTimetable: Timetable,
      srcSeat: Seat,
    ): Timetable[] {
      return this.timetables.map((timetable) => {
        const newOccupiedTermTeacherIds = (() => {
          const srcSeatWillBeEmpty = timetable.seats.find((seat) => {
            return seat.tutorialPieceIds.includes(tutorialPiece.id) &&
              seat.tutorialPieceIds.length === 1;
          });
          if (srcTimetable.id === timetable.id && srcSeatWillBeEmpty) {
            return timetable.occupiedTermTeacherIds.filter(
              occupiedTermTeacherId => occupiedTermTeacherId !== tutorialPiece.termTeacherId,
            );
          } else if (srcTimetable.id === timetable.id && !srcSeatWillBeEmpty) {
            return timetable.occupiedTermTeacherIds;
          } else {
            return timetable.occupiedTermTeacherIds;
          }
        })();
        const newOccupiedTermStudentIds = (() => {
          if (srcTimetable.id === timetable.id) {
            return timetable.occupiedTermStudentIds.filter(
              occupiedTermStudentId => occupiedTermStudentId !== tutorialPiece.termStudentId,
            );
          } else {
            return timetable.occupiedTermStudentIds;
          }
        })();
        const newSeats = timetable.seats.map((seat) => {
          const srcSeatWillBeEmpty = timetable.seats.find((seat) => {
            return seat.tutorialPieceIds.includes(tutorialPiece.id) && seat.tutorialPieceIds.length === 1;
          });
          const isSrcSeat = srcSeat && seat.id === srcSeat.id;
          const newTutorialPieceIds = (() => {
            if (isSrcSeat) {
              return seat.tutorialPieceIds.filter(
                tutorialPieceId => tutorialPieceId !== tutorialPiece.id,
              );
            } else {
              return seat.tutorialPieceIds;
            };
          })();
          const newTermTeacherId = (() => {
            if (srcSeat && isSrcSeat && srcSeatWillBeEmpty) {
              return null;
            } else if (srcSeat && isSrcSeat && !srcSeatWillBeEmpty) {
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
}) 
</script>

<style scoped lang="scss">
.piece {
  cursor: pointer;
  height: 100%;
  width: 100%;
  min-width: 100%;
}
.icon:hover {
  background-color: rgba(255, 255, 255, 0.6);
}
</style>
