<template>
  <div class="table-wrapper overflow-auto">
    <table class="table table-borderless">
      <thead>
        <tr>
          <td class="nospace fixed1">
            <div class="d-flex">
              <div id="date-and-period-header" class="border w-150px h-60px d-table">
                <div class="d-table-cell align-middle text-center">
                  <div class="d-flex justify-content-around align-items-center text-center">
                    <div>日時</div>
                    <dropdown-menu-container />
                  </div>
                </div>
              </div>
              <div id="seat-header" class="border w-50px h-60px d-table">
                <div class="d-table-cell align-middle text-center">残席</div>
              </div>
            </div>
          </td>
          <td class="nospace fixed2" v-for="termTeacher in termTeachers" v-bind:key="termTeacher.id">
            <div class="border h-60px w-300px">
              <stand-by-container
                :termTeacher="termTeacher"
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
              :is-disabled="isDifferentTermTeacher(termTeacher)"
              :position-count="term.positionCount"
              :tutorial-pieces="tutorialPiecesPerSeat(timetable, termTeacher)"
              :timetable="timetable"
              :term-teacher="termTeacher"
              :term-students="termStudents"
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
import Vue, { PropType } from 'vue';

import '../containers/DropdownMenu.vue';
import '../containers/StandBy.vue';
import './Seat.vue';
import { TutorialPiece, Timetable, Term, TermTeacher, TermStudent } from '../model/Term';
import { Position } from '../model/Position';

export default Vue.component('scheduling-table', {
  props: {
    term: Object as PropType<Term>,
    selectedTermTeacherId: Number,
    termTeachers: Array as PropType<TermTeacher[]>,
    termStudents: Array as PropType<TermStudent[]>,
    timetables: Array as PropType<Timetable[]>,
    tutorialPieces: Array as PropType<TutorialPiece[]>,
    droppables: Array as PropType<Position[]>,
    notVacants: Array as PropType<Position[]>,
  },
  methods: {
    dateDisplayText: function(timetable: Timetable) {
      const date = (() => {
        if (this.term.termType === 'normal') {
          return ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日'][timetable.dateIndex - 1];
        } else if (this.term.termType === 'season') {
          return moment(this.term.beginAt).add(timetable.dateIndex - 1, 'day').locale('ja').format('MM/DD（ddd）');
        } else if (this.term.termType === 'exam_planning') {
          return moment(this.term.beginAt).add(timetable.dateIndex - 1, 'day').locale('ja').format('MM/DD（ddd）');
        }
      })();

      return `${date} ${timetable.periodIndex}限`;
    },
    seatDisplayText: function(timetable: Timetable) {
      const maxSeat = this.term.seatCount;
      const occupiedSeat = timetable.occupiedTermTeacherIds.length;
      const unoccupiedSeat = maxSeat - occupiedSeat;

      return `${unoccupiedSeat}席`;
    },
    tutorialPiecesPerSeat: function(timetable: Timetable, termTeacher: TermTeacher) {
      const seat = timetable.seats.find((seat) => seat.termTeacherId === termTeacher.id);
      const tutorialPieceIds = seat ? seat.tutorialPieceIds : [];
      const tutorialPiece = this.tutorialPieces.filter(
        (tutorialPiece) => tutorialPieceIds.includes(tutorialPiece.id)
      );

      return tutorialPiece;
    },
    isDroppable: function(timetable: Timetable, termTeacher: TermTeacher) {
      return this.droppables.some((droppable) => {
        return droppable.timetableId === timetable.id &&
          droppable.termTeacherId === termTeacher.id;
      });
    },
    isNotVacant: function(timetable: Timetable, termTeacher: TermTeacher) {
      return this.notVacants.some((vacant) => {
        return vacant.timetableId === timetable.id &&
          vacant.termTeacherId === termTeacher.id;
      });
    },
    isDifferentTermTeacher: function(termTeacher: TermTeacher) {
      return this.selectedTermTeacherId === termTeacher.id;
    },
  },
}) 
</script>

<style scoped lang="scss">
.nospace {
  margin: 0;
  padding: 0;
}
</style>
