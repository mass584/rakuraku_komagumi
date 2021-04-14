<template>
  <div class="table-wrapper overflow-auto">
    <table class="table table-borderless">
      <thead>
        <tr>
          <th class="nospace fixed1">
            <div class="border w-150px h-60px d-table">
              <div class="d-table-cell align-middle">日付・時限（残席）</div>
            </div>
          </th>
          <th class="nospace fixed2" v-for="termTeacher in termTeachers" v-bind:key="termTeacher.id">
            <div class="border h-60px">
              {{ termTeacher.termTeacherName }}
            </div>
          </th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="timetable in timetables" v-bind:key="timetable.id">
          <td class="nospace fixed2">
            <div class="border w-150px h-30px d-table">
              <div class="d-table-cell align-middle">
                {{ timetable.dateIndex }}日目 {{ timetable.periodIndex }}限（席）
              </div>
            </div>
          </td>
          <td class="nospace" v-for="termTeacher in termTeachers" v-bind:key="termTeacher.id">
            <seat
              :is-droppable="isDroppable(timetable, termTeacher)"
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
import Vue from 'vue';

import './Seat.vue';

export default Vue.component('scheduling-table', {
  props: {
    positionCount: Number,
    termTeachers: Array,
    timetables: Array,
    tutorialPieces: Array,
    droppables: Array,
  },
  methods: {
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
.w-150px {
  width: 150px;
}
.h-30px {
  height: 30px;
} 
.h-60px {
  height: 60px;
} 
</style>
