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
        <th class="nospace fixed2" v-for="colObject in colObjects" v-bind:key="colObject.id">
          <div class="border h-60px">
            {{ colObject.term_teacher_name }}
          </div>
        </th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="rowObject in rowObjects" v-bind:key="rowObject.id">
        <td class="nospace fixed2">
          <div class="border w-150px h-30px d-table">
            <div class="d-table-cell align-middle">
              {{ rowObject.date_index }}日目 {{ rowObject.period_index }}限（{{ rowObject.unoccupiedSeats }}席）
            </div>
          </div>
        </td>
        <td class="nospace" v-for="colObject in colObjects" v-bind:key="colObject.id">
          <div v-if="rowObject.is_closed" class="border d-flex">
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
          <div v-else-if="rowObject.term_group_id" class="border d-flex">
            <div class="d-table">
              <div
                class="text-center d-table-cell align-middle position bg-secondary"
                v-for="positionIndex in positionIndexes"
                v-bind:key="positionIndex"
                v-bind:class="{ 'bg-warning': rowObject.term_group.term_teacher_id === colObject.id }"
              >
                {{ rowObject.term_group.term_group_name }}
              </div>
            </div>
          </div>
          <div v-else class="border d-flex">
            <div
              class="position"
              v-for="positionIndex in positionIndexes"
              v-bind:key="positionIndex"
              v-bind:class="{ position__droppable: isDroppable(rowObject, colObject) }"
              @drop="onDrop($event, rowObject, colObject, positionIndex)"
              @dragover="onDragover($event, rowObject, positionIndex)"
              @dragenter.prevent
            >
              <div
                v-if="tutorialPiece(rowObject, colObject, positionIndex)"
                class="piece border text-center bg-warning"
                v-bind:draggable="!tutorialPiece(rowObject, colObject, positionIndex).is_fixed"
                @dragstart="onDragStart($event, rowObject, colObject, positionIndex)"
              >
                {{ tutorialPieceDisplayText(tutorialPiece(rowObject, colObject, positionIndex)) }}
              </div>
            </div>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</div>
</template>

<script>
import axios from 'axios';
import Vue from 'vue';
import _ from 'lodash';
import moment from 'moment';

export default Vue.extend({
  name: 'tutorial_pieces',
  data: () => ({
    fetched: {},
    droppables: [],
  }),
  computed: {
    positionIndexes() {
      return _.range(1, this.fetched.term.position_count + 1);
    },
    colObjects() {
      const termTeachers = this.fetched?.term?.term_teachers || [];
      return termTeachers;
    },
    rowObjects() {
      const timetables = this.fetched?.term?.timetables || [];
      const ordered = _.orderBy(timetables, ['date_index', 'period_index']);
      const rowObjects = ordered.map((item) => {
        const occupied = item.seats.filter((seat) => seat.tutorial_piece_ids.length > 0).length;
        const unoccupiedSeats = this.fetched.term.seat_count - occupied;
        return {
          ...item,
          unoccupiedSeats,
        }
      });
      return rowObjects;
    },
  },
  methods: {
    fetchTutorialPieces: async function() {
      const url = '/tutorial_pieces.json';
      const response = await axios.get(url);
      this.fetched = response.data;
    },
    updateTutorialPiece: async function(tutorial_piece, seat) {
      const url = `/tutorial_pieces/${tutorial_piece.id}`;
      const reqBody = { seat_id: seat.id };
      const response = await axios.put(url, reqBody);
      return response.status === 200;
    },
    tutorialPiece: function(rowObject, colObject, positionIndex) {
      const seat = rowObject.seats.find((seat) => seat.term_teacher_id === colObject.id);
      const tutorialPieceId = seat && seat.tutorial_piece_ids[positionIndex - 1];
      const tutorialPiece = tutorialPieceId && this.fetched.term.tutorial_pieces.find((tutorialPiece) => {
        return tutorialPiece.id === tutorialPieceId;
      });
      return tutorialPiece;
    },
    tutorialPieceDisplayText: function(tutorialPiece) {
      const studentName = tutorialPiece.tutorial_contract.term_student_name;
      const studentSchoolGrade = tutorialPiece.tutorial_contract.term_student_school_grade;
      const tutorialName = tutorialPiece.tutorial_contract.term_tutorial_name.charAt(0);
      return `${studentSchoolGrade} ${studentName} ${tutorialName}`;
    },
    onDragStart: function(event, sourceRowObject, sourceColObject, positionIndex) {
      const tutorialPiece = this.tutorialPiece(rowObject, colObject, positionIndex);
      event.dataTransfer.effectAllowed = 'move';
      event.dataTransfer.dropEffect = 'move';
      event.dataTransfer.setData('tutorialPieceId', tutorialPiece.id);
      const droppables = this.colObjects.reduce((accu1, targetColObject) => {
        return accu1.concat(this.rowObjects.reduce((accu2, targetRowObject) => {
          const item = { rowObjectId: targetRowObject.id, colObjectId: targetColObject.id };
          const isValid = this.isValid(sourceRowObject, sourceColObject, targetRowObject, targetColObject, tutorialPiece);
          return isValid ? accu2.concat([item]) : accu2;
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
        seat.teacher_term_id = null;
        seat.teacher_name = null;
      }
    },
    // validation functions
    isValid: function(sourceRowObject, sourceColObject, targetRowObject, targetColObject, tutorialPiece) {
      return (
        this.isValidTermTeacher(targetColObject, tutorialPiece) &&
        this.isValidTimetable(targetRowObject) &&
        this.isSeatVacant(targetRowObject, tutorialPiece) &&
        this.isStudentVacant(targetRowObject, tutorialPiece) &&
        this.isTeacherVacant(targetRowObject, targetColObject) &&
        this.isNotDuplicateStudent(targetRowObject, tutorialPiece) &&
        this.isOccupationLimitStudent(sourceRowObject, targetRowObject, tutorialPiece) &&
        this.isOccupationLimitTeacher(sourceRowObject, targetRowObject, tutorialPiece) &&
        this.isBlankLimitStudent(sourceRowObject, targetRowObject, tutorialPiece) &&
        this.isBlankLimitTeacher(sourceRowObject, targetRowObject, tutorialPiece)
      );
    },
    isValidTermTeacher: function(colObject, tutorialPiece) {
      const colTermTeacherId = colObject.id;
      const pieceTermTeacherId = tutorialPiece.tutorial_contract.term_teacher_id;
      return colTermTeacherId === pieceTermTeacherId;
    },
    isValidTimetable: function(rowObject) {
      const isClosed = rowObject.is_closed;
      const isTermGroup = !!rowObject.term_group_id;
      return !isClosed && !isTermGroup;
    },
    isSeatVacant: function(rowObject, tutorialPiece) {
      const filled = rowObject.unoccupiedSeats === 0;
      const termTeacherId = tutorialPiece.tutorial_contract.term_teacher_id;
      const termTeacherAssigned = rowObject.occupied_term_teacher_ids.includes(termTeacherId);
      return filled && termTeacherAssigned;
    },
    isStudentVacant: function(rowObject, tutorialPiece) {
      const termStudentId = tutorialPiece.tutorial_contract.term_student_id;
      return rowObject.vacant_term_student_ids.includes(termStudentId);
    },
    isTeacherVacant: function(rowObject, colObject) {
      const termTeacherId = colObject.id;
      return rowObject.vacant_term_teacher_ids.includes(termTeacherId);
    },
    isNotDuplicateStudent: function(rowObject, tutorialPiece) {
      const termStudentId = tutorialPiece.tutorial_contract.term_student_id;
      return !rowObject.occupied_term_student_ids.includes(termStudentId);
    },
    isOccupationLimitStudent: function(sourceRowObject, targetRowObject, tutorialPiece) {
      const termStudentId = tutorialPiece.tutorial_contract.term_student_id;
      const termStudentSchoolGrade = tutorialPiece.tutorial_contract.term_student_school_grade;
      const optimizationRule = this.fetched.term.student_optimization_rules.find((item) => {
        item.school_grade === termStudentSchoolGrade;
      });
      const sourceDateIndex = sourceRowObject.date_index;
      const targetDateIndex = targetRowObject.date_index;
      const differentDate = sourceDateIndex !== targetDateIndex;
      const targetDateTutorialOccupation = targetRowObject.filter((item) => {
        item.date_index === targetDateIndex && item.occupated_term_student_ids.includes(termStudentId);
      }).length;
      const targetDateGroupOccupation = targetRowObject.filter((item) => {
        item.date_index === targetDateIndex && item.term_group && item.term_group.term_student_ids.includes(termStudentId);
      }).length;
      const targetDateOccupation = targetDateTutorialOccupation + targetDateGroupOccupation; 
      const occupationLimit = optimizationRule ? optimizationRule.occupation_limit : 0;
      const reachedToLimit = targetDateOccupation >= occupationLimit;
      return differentDate && reachedToLimit;
    },
    isOccupationLimitTeacher: function(sourceRowObject, targetRowObject, tutorialPiece) {
      const termTeacherId = tutorialPiece.tutorial_contract.term_teacher_id;
      const optimizationRule = this.fetched.term.teacher_optimization_rules[0];
      const sourceDateIndex = sourceRowObject.date_index;
      const targetDateIndex = targetRowObject.date_index;
      const differentDate = sourceDateIndex !== targetDateIndex;
      const targetDateTutorialOccupation = targetRowObject.filter((item) => {
        item.date_index === targetDateIndex && item.occupated_term_teacher_ids.includes(termTeacherId);
      }).length;
      const targetDateGroupOccupation = targetRowObject.filter((item) => {
        item.date_index === targetDateIndex && item.term_group && item.term_group.term_teacher_id === termTeacherId;
      }).length;
      const targetDateOccupation = targetDateTutorialOccupation + targetDateGroupOccupation; 
      const occupationLimit = optimizationRule ? optimizationRule.occupation_limit : 0;
      const reachedToLimit = targetDateOccupation >= occupationLimit;
      return differentDate && reachedToLimit;
    },
    isBlankLimitStudent: function(sourceRowObject, targetRowObject, tutorialPiece) {
      const termStudentId = tutorialPiece.tutorial_contract.term_student_id;
      const termStudentSchoolGrade = tutorialPiece.tutorial_contract.term_student_school_grade;
      const optimizationRule = this.fetched.term.student_optimization_rules.find((item) => {
        item.school_grade === termStudentSchoolGrade;
      });
      const blankLimit = optimizationRule ? optimizationRule.blank_limit : 0;
      const sourceDateIndex = sourceRowObject.date_index;
      const sourceDateTutorialPeriodIndexes = this.rowObjects.filter((item) => {
        item.date_index === sourceDateIndex && item.occupated_term_student_ids.includes(termStudentId);
      }).map((item) => item.period_index);
      const sourceDateGroupPeriodIndexes = this.rowObjects.filter((item) => {
        item.date_index === sourceDateIndex && item.term_group && item.term_group.term_student_ids.includes(termStudentId);
      }).map((item) => item.period_index);
      const sourcePeriodIndex = sourceRowObject.period_index;
      // TODO : FIX
      const sourceDatePeriodIndexes = (sourceDateTutorialPeriodIndexes + sourceDateGroupPeriodIndexes - [sourcePeriodIndex]);
      // TODO : FIX
      const sourceDateBlank = getBlank(sourceDatePeriodIndexes);
      const reachedToLimitOnSourceDate = sourceDateBlank > blankLimit;
      const targetDateIndex = targetRowObject.date_index;
      const targetDateTutorialPeriodIndexes = this.rowObjects.filter((item) => {
        item.date_index === targetDateIndex && item.occupated_term_student_ids.includes(termStudentId);
      }).map((item) => item.period_index);
      const targetDateGroupPeriodIndexes = this.rowObjects.filter((item) => {
        item.date_index === targetDateIndex && item.term_group && item.term_group.term_student_ids.includes(termStudentId);
      }).map((item) => item.period_index);
      const targetPeriodIndex = targetRowObject.period_index;
      // TODO : FIX
      const targetDatePeriodIndexes = (targetDateTutorialPeriodIndexes + targetDateGroupPeriodIndexes + [targetPeriodIndex]);
      // TODO : FIX
      const targetDateBlank = getBlank(targetDatePeriodIndexes);
      const reachedToLimitOnTargetDate = targetDateBlank > blankLimit;
      return !reachedToLimitOnSourceDate && !reachedToLimitOnTargetDate;
    },
    isBlankLimitTeacher: function(sourceRowObject, targetRowObject, tutorialPiece) {
      const termTeacherId = tutorialPiece.tutorial_contract.term_teacher_id;
      const optimizationRule = this.fetched.term.teacher_optimization_rules[0];
      const blankLimit = optimizationRule ? optimizationRule.blank_limit : 0;
      const sourceDateIndex = sourceRowObject.date_index;
      const sourceDateTutorialPeriodIndexes = this.rowObjects.filter((item) => {
        item.date_index === sourceDateIndex && item.occupated_term_teacher_ids.includes(termTeacherId);
      }).map((item) => item.period_index);
      const sourceDateGroupPeriodIndexes = this.rowObjects.filter((item) => {
        item.date_index === sourceDateIndex && item.term_group && item.term_group.term_teacher_id === termTeacherId;
      }).map((item) => item.period_index);
      const sourcePeriodIndex = sourceRowObject.period_index;
      // TODO : FIX
      const sourceDatePeriodIndexes = (sourceDateTutorialPeriodIndexes + sourceDateGroupPeriodIndexes - [sourcePeriodIndex]);
      // TODO : FIX
      const sourceDateBlank = getBlank(sourceDatePeriodIndexes);
      const reachedToLimitOnSourceDate = sourceDateBlank > blankLimit;
      const targetDateIndex = targetRowObject.date_index;
      const targetDateTutorialPeriodIndexes = this.rowObjects.filter((item) => {
        item.date_index === targetDateIndex && item.occupated_term_teacher_ids.includes(termTeacherId);
      }).map((item) => item.period_index);
      const targetDateGroupPeriodIndexes = this.rowObjects.filter((item) => {
        item.date_index === targetDateIndex && item.term_group && item.term_group.term_teacher_id === termTeacherId;
      }).map((item) => item.period_index);
      const targetPeriodIndex = targetRowObject.period_index;
      // TODO : FIX
      const targetDatePeriodIndexes = (targetDateTutorialPeriodIndexes + targetDateGroupPeriodIndexes + [targetPeriodIndex]);
      // TODO : FIX
      const targetDateBlank = getBlank(targetDatePeriodIndexes);
      const reachedToLimitOnTargetDate = targetDateBlank > blankLimit;
      return !reachedToLimitOnSourceDate && !reachedToLimitOnTargetDate;
    },
    isDroppable: function(rowObject, colObject) {
      return this.droppables.some((droppable) => {
        return droppable.rowObjectId === rowObject.id && droppable.colObjectId === colObject.id;
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
