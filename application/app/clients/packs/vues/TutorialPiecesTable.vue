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
          <div v-if="timetable.isClosed" class="border d-flex">
            <div class="d-table">
              <div
                class="text-center d-table-cell align-middle position bg-secondary"
                v-for="positionIndex in positionIndexes"
                v-bind:key="positionIndex"
              >
                休講
              </div>
            </div>
          </div>
          <div v-else-if="timetable.termGroupId" class="border d-flex">
            <div class="d-table">
              <div
                class="text-center d-table-cell align-middle position bg-secondary"
                v-for="positionIndex in positionIndexes"
                v-bind:key="positionIndex"
                v-bind:class="{ 'bg-warning': timetable.termGroup.termTeacherId === termTeacher.id }"
              >
                {{ timetable.termGroup.termGroupName }}
              </div>
            </div>
          </div>
          <div v-else class="border d-flex">
            <div
              class="position"
              v-for="positionIndex in positionIndexes"
              v-bind:key="positionIndex"
              v-bind:class="{ position__droppable: isDroppable(timetable, termTeacher) }"
              @drop="onDrop($event, timetable, termTeacher, positionIndex)"
              @dragover="onDragover($event, timetable, positionIndex)"
              @dragenter.prevent
            >
              <div
                v-if="tutorialPiece(timetable, termTeacher, positionIndex)"
                class="piece border text-center bg-warning"
                v-bind:draggable="!tutorialPiece(timetable, termTeacher, positionIndex).isFixed"
                @dragstart="onDragStart($event, timetable, termTeacher, positionIndex)"
              >
                {{ tutorialPieceDisplayText(tutorialPiece(timetable, termTeacher, positionIndex)) }}
              </div>
            </div>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</div>
</template>

<script lang="ts">
import axios from 'axios';
import camelcaseKeys from 'camelcase-keys';
import _ from 'lodash';
import Vue from 'vue';

import { isValid } from './TutorialPieces/validator';

export default Vue.extend({
  name: 'tutorial_pieces',
  data: () => ({
    term: null,
    studentOptimizationRules: [],
    teacherOptimizationRule: null,
    termTeachers: [],
    timetables: [],
    tutorialPieces: [],
    droppables: [],
  }),
  computed: {
    positionIndexes() {
      const positionCount = this.term.positionCount || 0;
      return _.range(1, positionCount + 1);
    },
  },
  methods: {
    fetchTutorialPieces: async function() {
      const url = '/tutorial_pieces.json';
      const response = await axios.get(url);
      const { term } = response.data;
      this.term = {
        dateCount: term.date_count,
        periodCount: term.period_count,
        seatCount: term.seat_count,
        positionCount: term.position_count,
      };
      this.studentOptimizationRules = term.student_optimization_rules.map((studentOptimizationRule) => {
        return camelcaseKeys(studentOptimizationRule);
      });
      this.teacherOptimizationRule = camelcaseKeys(term.teacher_optimization_rules[0]);
      this.termTeachers = term.term_teachers.map((termTeacher) => {
        return camelcaseKeys(termTeacher);
      });
      this.timetables = _.orderBy(term.timetables.map((timetable) => {
        return camelcaseKeys({
          ...timetable,
          seats: timetable.seats.map((seat) => camelcaseKeys(seat)),
          termGroup: timetable.term_group ? camelcaseKeys(timetable.term_group) : null,
        });
      }), ['dateIndex', 'periodIndex']);
      this.tutorialPieces = term.tutorial_pieces.map((tutorialPiece) => {
        return camelcaseKeys({
          ...tutorialPiece,
          tutorialContract: camelcaseKeys(tutorialPiece.tutorial_contract),
        });
      });
    },
    updateTutorialPiece: async function(tutorialPiece, seat) {
      const url = `/tutorial_pieces/${tutorialPiece.id}`;
      const reqBody = { seat_id: seat.id };
      const response = await axios.put(url, reqBody);
      return response.status === 200;
    },
    tutorialPiece: function(timetable, termTeacher, positionIndex) {
      const seat = timetable.seats.find((seat) => seat.termTeacherId === termTeacher.id);
      const tutorialPieceId = seat && seat.tutorialPieceIds[positionIndex - 1];
      const tutorialPiece = tutorialPieceId && this.tutorialPieces.find((tutorialPiece) => {
        return tutorialPiece.id === tutorialPieceId;
      });
      return tutorialPiece;
    },
    tutorialPieceDisplayText: function(tutorialPiece) {
      const studentName = tutorialPiece.tutorialContract.termStudentName;
      const studentSchoolGrade = tutorialPiece.tutorialContract.termStudentSchoolGrade;
      const tutorialName = tutorialPiece.tutorialContract.termTutorialName.charAt(0);
      return `${studentSchoolGrade} ${studentName} ${tutorialName}`;
    },
    onDragStart: function(event, timetable, termTeacher, positionIndex) {
      const tutorialPiece = this.tutorialPiece(timetable, termTeacher, positionIndex);
      event.dataTransfer.effectAllowed = 'move';
      event.dataTransfer.dropEffect = 'move';
      event.dataTransfer.setData('tutorialPieceId', tutorialPiece.id);
      const droppables = this.termTeachers.reduce((accu1, targetTermTeacher) => {
        return accu1.concat(this.timetables.reduce((accu2, targetTimetable) => {
          const item = { timetableId: targetTimetable.id, termTeacherId: targetTermTeacher.id };
          const valid = isValid(
            this.term,
            this.studentOptimizationRules,
            this.teacherOptimizationRule,
            this.timetables,
            timetable,
            targetTimetable,
            targetTermTeacher,
            tutorialPiece,
          );
          return valid ? accu2.concat([item]) : accu2;
        }, []));
      }, []);
      this.droppables = droppables;
    },
    onDragover: function(event, date, period, seatNumber, position) {
    //  const pieceId = Number(event.dataTransfer.getData('pieceId'));
    //  const piece = this.getPieceById(pieceId);
    //  const seat = this.getSeat(date, period, seatNumber);
    //  if (seat.droppable) event.preventDefault();
    },
    onDrop: function(event, rowObject, colObject, positionIndex) {
    //  const pieceId = Number(event.dataTransfer.getData('pieceId'));
    //  const piece = this.getPieceById(pieceId);
    //  const seat = this.getSeat(date, period, seatNumber);
    //  const res = await this.updatePiece(piece, seat);
    //  this.seats = this.seats.map(seat => {
    //    return { ...seat, droppable: false };
    //  });
    //  if (res) {
    //    piece.seat_id = seat.id;
    //    piece.date = date;
    //    piece.period = period;
    //    piece.number = seatNumber;
    //    seat.teacher_term_id = piece.teacher_term_id
    //    seat.teacher_name = piece.teacher_name
    //  }
      this.droppables = [];
    },
    onClickBulkReset: async function(seat) {
      const response = await this.updateSeat(seat, null);
      if (response) {
        seat.teacherTermId = null;
        seat.teacherName = null;
      }
    },
    isDroppable: function(timetable, termTeacher) {
      return this.droppables.some((droppable) => {
        return droppable.timetableId === timetable.id && droppable.termTeacherId === termTeacher.id;
      });
    },
  },
  created: async function() {
    await this.fetchTutorialPieces();
  }
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
.position {
  height: 28px;
  width: 148px;
}
.position__droppable {
  background-color: tomato;
}
.piece {
  cursor: pointer;
  height: 100%;
  width: 100%;
}
</style>
