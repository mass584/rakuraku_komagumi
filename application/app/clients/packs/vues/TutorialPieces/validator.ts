import _ from 'lodash';
import {
  StudentOptimizationRule,
  TeacherOptimizationRule,
  Timetable,
  TermTeacher,
  TutorialPiece,
} from './types';

export const validate = (
  periodCount: number,
  seatCount: number,
  studentOptimizationRules: StudentOptimizationRule[],
  teacherOptimizationRules: TeacherOptimizationRule[],
  timetables: Timetable[],
  srcTimetable: Timetable | null,
  destTimetable: Timetable,
  termTeacher: TermTeacher,
  tutorialPiece: TutorialPiece,
) => {
  return (
    isValidTermTeacher(termTeacher, tutorialPiece) &&
    isValidTimetable(destTimetable) &&
    isSeatVacant(seatCount, destTimetable, tutorialPiece) &&
    isStudentVacant(destTimetable, tutorialPiece) &&
    isTeacherVacant(destTimetable, termTeacher) &&
    isNotDuplicateStudent(destTimetable, tutorialPiece) &&
    isOccupationLimitStudent(studentOptimizationRules, timetables, srcTimetable, destTimetable, tutorialPiece) &&
    isOccupationLimitTeacher(teacherOptimizationRules, timetables, srcTimetable, destTimetable, tutorialPiece) &&
    isBlankLimitStudent(periodCount, studentOptimizationRules, timetables, srcTimetable, destTimetable, tutorialPiece) &&
    isBlankLimitTeacher(periodCount, teacherOptimizationRules, timetables, srcTimetable, destTimetable, tutorialPiece)
  );
};

const isValidTermTeacher = (
  termTeacher: TermTeacher,
  tutorialPiece: TutorialPiece,
) => {
  return termTeacher.id === tutorialPiece.termTeacherId;
};

const isValidTimetable = (destTimetable: Timetable) => {
  const isClosed = destTimetable.isClosed;
  const isTermGroup = !!destTimetable.termGroupId;
  return !isClosed && !isTermGroup;
};

const isSeatVacant = (
  seatCount: number,
  destTimetable: Timetable,
  tutorialPiece: TutorialPiece,
) => {
  const occupiedSeatCount = destTimetable.occupiedTermTeacherIds.length;
  const isVacant = occupiedSeatCount < seatCount;
  const termTeacherId = tutorialPiece.termTeacherId;
  const isAssigned = destTimetable.occupiedTermTeacherIds.includes(termTeacherId);
  return isVacant || isAssigned;
};

export const isStudentVacant = (
  destTimetable: Timetable,
  tutorialPiece: TutorialPiece,
) => {
  const termStudentId = tutorialPiece.termStudentId;
  return destTimetable.vacantTermStudentIds.includes(termStudentId);
};

export const isTeacherVacant = (
  destTimetable: Timetable,
  termTeacher: TermTeacher,
) => {
  return destTimetable.vacantTermTeacherIds.includes(termTeacher.id);
};

const isNotDuplicateStudent = (
  destTimetable: Timetable,
  tutorialPiece: TutorialPiece,
) => {
  const termStudentId = tutorialPiece.termStudentId;
  return !destTimetable.occupiedTermStudentIds.includes(termStudentId);
};

const isOccupationLimitStudent = (
  studentOptimizationRules: StudentOptimizationRule[],
  timetables: Timetable[],
  srcTimetable: Timetable | null,
  destTimetable: Timetable,
  tutorialPiece: TutorialPiece,
) => {
  const termStudentId = tutorialPiece.termStudentId;
  const termStudentSchoolGrade = tutorialPiece.termStudentSchoolGrade;
  const optimizationRule = studentOptimizationRules.find((item) => {
    return item.schoolGrade === termStudentSchoolGrade;
  });
  const occupationLimit = optimizationRule ? optimizationRule.occupationLimit : 0;
  const srcDateIndex = srcTimetable ? srcTimetable.dateIndex : null;
  const destDateIndex = destTimetable.dateIndex;
  const isDifferentDate = srcDateIndex !== destDateIndex;

  const destDateOccupation = timetables.filter((timetable) => {
    const isTutorial =
      (timetable.dateIndex === destDateIndex) &&
      timetable.occupiedTermStudentIds.includes(termStudentId);
    const isGroup =
      (timetable.dateIndex === destDateIndex) &&
      timetable.termGroupStudentIds.includes(termStudentId);
    return isTutorial || isGroup;
  }).length;
  const reachedToLimit = destDateOccupation < occupationLimit;

  return isDifferentDate && reachedToLimit;
};

const isOccupationLimitTeacher = (
  teacherOptimizationRules: TeacherOptimizationRule[],
  timetables: Timetable[],
  srcTimetable: Timetable | null,
  destTimetable: Timetable,
  tutorialPiece: TutorialPiece,
) => {
  const termTeacherId = tutorialPiece.termTeacherId;
  const srcDateIndex = srcTimetable ? srcTimetable.dateIndex : null;
  const destDateIndex = destTimetable.dateIndex;
  const isDifferentDate = srcDateIndex !== destDateIndex;

  const destDateOccupation = timetables.filter((timetable) => {
    const isTutorial =
      (timetable.dateIndex === destDateIndex) &&
      timetable.occupiedTermTeacherIds.includes(termTeacherId);
    const isGroup =
      (timetable.dateIndex === destDateIndex) &&
      timetable.termGroupTeacherId === termTeacherId;
    return isTutorial || isGroup;
  }).length;
  const occupationLimit = teacherOptimizationRules[0].occupationLimit;
  const reachedToLimit = destDateOccupation < occupationLimit;

  return isDifferentDate && reachedToLimit;
}

const isBlankLimitStudent = (
  periodCount: number,
  studentOptimizationRules: StudentOptimizationRule[],
  timetables: Timetable[],
  srcTimetable: Timetable | null,
  destTimetable: Timetable,
  tutorialPiece: TutorialPiece,
) => {
  const termStudentId = tutorialPiece.termStudentId;
  const termStudentSchoolGrade = tutorialPiece.termStudentSchoolGrade;
  const optimizationRule = studentOptimizationRules.find((item) => {
    return item.schoolGrade === termStudentSchoolGrade;
  });
  const blankLimit = optimizationRule ? optimizationRule.blankLimit : 0;
  const srcDateIndex = srcTimetable ? srcTimetable.dateIndex : null;
  const destDateIndex = destTimetable.dateIndex;

  const srcDateOccupiedPeriodIndexes = timetables.filter((timetable) => {
    const isTutorial =
      srcTimetable &&
      timetable.id !== srcTimetable.id &&
      timetable.dateIndex === srcDateIndex &&
      timetable.occupiedTermStudentIds.includes(termStudentId);
    const isDestTutorial = timetable.id === destTimetable.id;
    const isGroup =
      timetable.dateIndex === srcDateIndex &&
      timetable.termGroupStudentIds.includes(termStudentId);
    return isTutorial || isDestTutorial || isGroup;
  }).map((item) => item.periodIndex);
  const srcDateOk = dailyBlanksFrom(periodCount, srcDateOccupiedPeriodIndexes) <= blankLimit;

  const destDateOccupiedPeriodIndexes = timetables.filter((timetable) => {
    const isTutorial =
      timetable.id !== destTimetable.id &&
      timetable.dateIndex === destDateIndex &&
      timetable.occupiedTermStudentIds.includes(termStudentId);
    const isDestTutorial = timetable.id === destTimetable.id;
    const isGroup =
      timetable.dateIndex === destDateIndex &&
      timetable.termGroupStudentIds.includes(termStudentId);
    return isTutorial || isDestTutorial || isGroup;
  }).map((item) => item.periodIndex);
  const destDateOk = dailyBlanksFrom(periodCount, destDateOccupiedPeriodIndexes) <= blankLimit;

  return srcDateOk && destDateOk;
};

const isBlankLimitTeacher = (
  periodCount: number,
  teacherOptimizationRules: TeacherOptimizationRule[],
  timetables: Timetable[],
  srcTimetable: Timetable | null,
  destTimetable: Timetable,
  tutorialPiece: TutorialPiece,
) => {
  const termTeacherId = tutorialPiece.termTeacherId;
  const blankLimit = teacherOptimizationRules[0].blankLimit;
  const srcDateIndex = srcTimetable ? srcTimetable.dateIndex : null;
  const destDateIndex = destTimetable.dateIndex;

  const srcDateOccupiedPeriodIndexes = timetables.filter((timetable) => {
    const isTutorial =
      srcTimetable &&
      timetable.id !== srcTimetable.id &&
      timetable.dateIndex === srcDateIndex &&
      timetable.occupiedTermTeacherIds.includes(termTeacherId);
    const isDestTutorial = timetable.id === destTimetable.id;
    const isGroup =
      timetable.dateIndex === srcDateIndex &&
      timetable.termGroupTeacherId === termTeacherId;
    return isTutorial || isDestTutorial || isGroup;
  }).map((item) => item.periodIndex);
  const srcDateOk = dailyBlanksFrom(periodCount, srcDateOccupiedPeriodIndexes) <= blankLimit;

  const destDateOccupiedPeriodIndexes = timetables.filter((timetable) => {
    const isTutorial =
      timetable.id !== destTimetable.id &&
      timetable.dateIndex === destDateIndex &&
      timetable.occupiedTermStudentIds.includes(termTeacherId);
    const isDestTutorial = timetable.id === destTimetable.id;
    const isGroup =
      timetable.dateIndex === destDateIndex &&
      timetable.termGroupTeacherId === termTeacherId;
    return isTutorial || isDestTutorial || isGroup;
  }).map((item) => item.periodIndex);
  const destDateOk = dailyBlanksFrom(periodCount, destDateOccupiedPeriodIndexes) <= blankLimit;

  return srcDateOk && destDateOk;
};

const dailyBlanksFrom = (periodCount: number, periodIndexes: number[]) => {
  const init = { flag: false, buffer: 0, sum: 0 };
  const result = _.range(1, periodCount + 1).reduce((accu, periodIndex) => {
    const occupied = periodIndexes.includes(periodIndex);
    return {
      flag: accu.flag || occupied,
      buffer: !occupied ? accu.buffer + 1 : 0,
      sum: (accu.flag && occupied) ? accu.sum + accu.buffer : accu.sum,
    };
  }, init);
  return result.sum;
};
