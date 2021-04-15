<template>
  <div class="table-wrapper overflow-auto border border-secondary">
    <table class="table table-borderless">
      <thead>
        <tr>
          <td class="nospace fixed1">
            <div class="d-flex">
              <div class="border w-150px h-60px d-table">
                <div class="d-table-cell align-middle text-center">日時</div>
              </div>
              <div class="border w-50px h-60px d-table">
                <div class="d-table-cell align-middle text-center">残席</div>
              </div>
            </div>
          </td>
          <td class="nospace fixed2" v-for="termTeacher in termTeachers" v-bind:key="termTeacher.id">
            <div class="border h-60px">
              <stand-by
                :tutorialPieces="tutorialPieces"
                :termTeacher="termTeacher"
                v-on:pushleft="$emit('pushleft', $event)"
                v-on:pushright="$emit('pushright', $event)"
                v-on:dragstart="$emit('dragstart', { ...$event, timetable: null, termTeacher })"
                v-on:dragend="$emit('dragend', { ...$event, timetable: null, termTeacher })"
              />
            </div>
          </td>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="timetable in timetables"
          v-bind:key="timetable.id"
          v-bind:class="{
            'border-top': timetable.periodIndex === 1,
            'border-secondary': timetable.periodIndex === 1,
          }"
        >
          <td class="nospace fixed2">
            <div class="d-flex">
              <div class="border w-150px h-30px d-table">
                <div class="d-table-cell align-middle text-center">
                  {{ dateDisplayText(timetable) }}
                </div>
              </div>
              <div class="border w-50px h-30px d-table">
                <div class="d-table-cell align-middle text-center">
                  {{ seatDisplayText(timetable) }}
                </div>
              </div>
            </div>
          </td>
          <td class="nospace" v-for="termTeacher in termTeachers" v-bind:key="termTeacher.id">
            <seat
              :is-droppable="isDroppable(timetable, termTeacher)"
              :is-not-vacant="isNotVacant(timetable, termTeacher)"
              :is-disabled="isDisabled(termTeacher)"
              :position-count="positionCount"
              :tutorial-pieces="tutorialPiecesPerSeat(timetable, termTeacher)"
              :timetable="timetable"
              :term-teacher="termTeacher"
              v-on:dragstart="$emit('dragstart', { ...$event, timetable, termTeacher })"
              v-on:dragend="$emit('dragend', { ...$event, timetable, termTeacher })"
              v-on:drop="$emit('drop', { ...$event, timetable, termTeacher })"
              v-on:dragover="$emit('dragover', { ...$event, timetable, termTeacher })"
            />
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script lang="ts">
import moment from 'moment';
import Vue from 'vue';

import './Seat.vue';
import './StandBy.vue';

export default Vue.component('scheduling-table', {
  props: {
    beginAt: String,
    seatCount: Number,
    positionCount: Number,
    termTeachers: Array,
    timetables: Array,
    tutorialPieces: Array,
    droppables: Array,
    notVacants: Array,
    isDisables: Array,
  },
  methods: {
    dateDisplayText: function(timetable) {
      const date = moment(this.beginAt).add(timetable.dateIndex - 1, 'day').locale('ja').format('MM/DD（ddd）');

      return `${date} ${timetable.periodIndex}限`;
    },
    seatDisplayText: function(timetable) {
      const maxSeat = this.seatCount;
      const occupiedSeat = timetable.occupiedTermTeacherIds.length;
      const unoccupiedSeat = maxSeat - occupiedSeat;

      return `${unoccupiedSeat}席`;
    },
    tutorialPiecesPerSeat: function(timetable, termTeacher) {
      const seat = timetable.seats.find((seat) => seat.termTeacherId === termTeacher.id);
      const tutorialPieceIds = seat ? seat.tutorialPieceIds : [];
      const tutorialPiece = this.tutorialPieces.filter(
        (tutorialPiece) => tutorialPieceIds.includes(tutorialPiece.id)
      );

      return tutorialPiece;
    },
    isDroppable: function(timetable, termTeacher) {
      return this.droppables.some((droppable) => {
        return droppable.timetableId === timetable.id &&
          droppable.termTeacherId === termTeacher.id;
      });
    },
    isNotVacant: function(timetable, termTeacher) {
      return this.notVacants.some((vacant) => {
        return vacant.timetableId === timetable.id &&
          vacant.termTeacherId === termTeacher.id;
      });
    },
    isDisabled: function(termTeacher) {
      return this.isDisables.some((isDisable) => {
        return isDisable.termTeacherId === termTeacher.id;
      });
    },
  },
}) 
</script>

<style scoped lang="scss">
.table-wrapper {
  height: calc(100vh - 56px - 41px - 100px);
}
.fixed1, .fixed2 {
  position: sticky;
  background-color: #FFF;
  top: 0;
  left: 0;
}
.fixed1{
  z-index: 2;
}
.fixed2{
  z-index: 1;
}
.nospace {
  margin: 0;
  padding: 0;
}
.w-50px {
  width: 50px;
}
.w-150px {
  width: 150px;
}
.w-200px {
  width: 200px;
}
.h-30px {
  height: 30px;
} 
.h-60px {
  height: 60px;
} 
</style>
