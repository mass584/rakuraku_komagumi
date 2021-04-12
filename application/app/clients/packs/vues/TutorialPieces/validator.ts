import _ from 'lodash';
import {
  Term,
  StudentOptimizationRule,
  TeacherOptimizationRule,
  Timetable,
  TermTeacher,
  TutorialPiece,
} from './types';

export const isValid = (
  term: Term,
  studentOptimizationRules: StudentOptimizationRule[],
  teacherOptimizationRule: TeacherOptimizationRule,
  timetables: Timetable[],
  srcTimetable: Timetable,
  destTimetable: Timetable,
  termTeacher: TermTeacher,
  tutorialPiece: TutorialPiece,
) => {
  return (
    isValidTermTeacher(termTeacher, tutorialPiece) &&
    isValidTimetable(destTimetable) &&
    isSeatVacant(term, destTimetable, tutorialPiece) &&
    isStudentVacant(destTimetable, tutorialPiece) &&
    isTeacherVacant(destTimetable, termTeacher) &&
    isNotDuplicateStudent(destTimetable, tutorialPiece) &&
    isOccupationLimitStudent(studentOptimizationRules, timetables, srcTimetable, destTimetable, tutorialPiece) &&
    isOccupationLimitTeacher(teacherOptimizationRule, timetables, srcTimetable, destTimetable, tutorialPiece) &&
    isBlankLimitStudent(term, studentOptimizationRules, timetables, srcTimetable, destTimetable, tutorialPiece) &&
    isBlankLimitTeacher(term, teacherOptimizationRule, timetables, srcTimetable, destTimetable, tutorialPiece)
  );
};

const isValidTermTeacher = (
  termTeacher: TermTeacher,
  tutorialPiece: TutorialPiece,
) => {
  return termTeacher.id === tutorialPiece.tutorialContract.termTeacherId;
};

const isValidTimetable = (destTimetable: Timetable) => {
  const isClosed = destTimetable.isClosed;
  const isTermGroup = !!destTimetable.termGroupId;
  return !isClosed && !isTermGroup;
};

const isSeatVacant = (
  term: Term,
  destTimetable: Timetable,
  tutorialPiece: TutorialPiece,
) => {
  const occupiedSeatCount = destTimetable.occupiedTermTeacherIds.length;
  const isVacant = occupiedSeatCount < term.seatCount;
  const termTeacherId = tutorialPiece.tutorialContract.termTeacherId;
  const isAssigned = destTimetable.occupiedTermTeacherIds.includes(termTeacherId);
  return isVacant || isAssigned;
};

const isStudentVacant = (
  destTimetable: Timetable,
  tutorialPiece: TutorialPiece,
) => {
  const termStudentId = tutorialPiece.tutorialContract.termStudentId;
  return destTimetable.vacantTermStudentIds.includes(termStudentId);
};

const isTeacherVacant = (
  destTimetable: Timetable,
  termTeacher: TermTeacher,
) => {
  return destTimetable.vacantTermTeacherIds.includes(termTeacher.id);
};

const isNotDuplicateStudent = (
  destTimetable: Timetable,
  tutorialPiece: TutorialPiece,
) => {
  const termStudentId = tutorialPiece.tutorialContract.termStudentId;
  return !destTimetable.occupiedTermStudentIds.includes(termStudentId);
};

const isOccupationLimitStudent = (
  studentOptimizationRules: StudentOptimizationRule[],
  timetables: Timetable[],
  srcTimetable: Timetable,
  destTimetable: Timetable,
  tutorialPiece: TutorialPiece,
) => {
  const termStudentId = tutorialPiece.tutorialContract.termStudentId;
  const termStudentSchoolGrade = tutorialPiece.tutorialContract.termStudentSchoolGrade;
  const optimizationRule = studentOptimizationRules.find((item) => {
    return item.schoolGrade === termStudentSchoolGrade;
  });
  const occupationLimit = optimizationRule ? optimizationRule.occupationLimit : 0;
  const srcDateIndex = srcTimetable.dateIndex;
  const destDateIndex = destTimetable.dateIndex;
  const isDifferentDate = srcDateIndex !== destDateIndex;

  const destDateOccupation = timetables.filter((timetable) => {
    const isTutorial =
      (timetable.dateIndex === destDateIndex) &&
      timetable.occupiedTermStudentIds.includes(termStudentId);
    const isGroup =
      (timetable.dateIndex === destDateIndex) &&
      timetable.termGroup && timetable.termGroup.termStudentIds.includes(termStudentId);
    return isTutorial || isGroup;
  }).length;
  const reachedToLimit = destDateOccupation < occupationLimit;

  return isDifferentDate && reachedToLimit;
};

const isOccupationLimitTeacher = (
  teacherOptimizationRule: TeacherOptimizationRule,
  timetables: Timetable[],
  srcTimetable: Timetable,
  destTimetable: Timetable,
  tutorialPiece: TutorialPiece,
) => {
  const termTeacherId = tutorialPiece.tutorialContract.termTeacherId;
  const srcDateIndex = srcTimetable.dateIndex;
  const destDateIndex = destTimetable.dateIndex;
  const isDifferentDate = srcDateIndex !== destDateIndex;

  const destDateOccupation = timetables.filter((timetable) => {
    const isTutorial =
      (timetable.dateIndex === destDateIndex) &&
      timetable.occupiedTermTeacherIds.includes(termTeacherId);
    const isGroup =
      (timetable.dateIndex === destDateIndex) &&
      timetable.termGroup && timetable.termGroup.termTeacherId === termTeacherId;
    return isTutorial || isGroup;
  }).length;
  const occupationLimit = teacherOptimizationRule.occupationLimit;
  const reachedToLimit = destDateOccupation < occupationLimit;

  return isDifferentDate && reachedToLimit;
}

const isBlankLimitStudent = (
  term: Term,
  studentOptimizationRules: StudentOptimizationRule[],
  timetables: Timetable[],
  srcTimetable: Timetable,
  destTimetable: Timetable,
  tutorialPiece: TutorialPiece,
) => {
  const termStudentId = tutorialPiece.tutorialContract.termStudentId;
  const termStudentSchoolGrade = tutorialPiece.tutorialContract.termStudentSchoolGrade;
  const optimizationRule = studentOptimizationRules.find((item) => {
    return item.schoolGrade === termStudentSchoolGrade;
  });
  const blankLimit = optimizationRule ? optimizationRule.blankLimit : 0;
  const srcDateIndex = srcTimetable.dateIndex;
  const destDateIndex = destTimetable.dateIndex;

  const srcDateOccupiedPeriodIndexes = timetables.filter((timetable) => {
    const isTutorial =
      timetable.id !== srcTimetable.id &&
      timetable.dateIndex === srcDateIndex &&
      timetable.occupiedTermStudentIds.includes(termStudentId);
    const isDestTutorial = timetable.id === destTimetable.id;
    const isGroup =
      timetable.dateIndex === srcDateIndex &&
      timetable.termGroup && timetable.termGroup.termStudentIds.includes(termStudentId);
    return isTutorial || isDestTutorial || isGroup;
  }).map((item) => item.periodIndex);
  const srcDateOk = dailyBlanksFrom(term, srcDateOccupiedPeriodIndexes) <= blankLimit;

  const destDateOccupiedPeriodIndexes = timetables.filter((timetable) => {
    const isTutorial =
      timetable.id !== srcTimetable.id &&
      timetable.dateIndex === destDateIndex &&
      timetable.occupiedTermStudentIds.includes(termStudentId);
    const isDestTutorial = timetable.id === destTimetable.id;
    const isGroup =
      timetable.dateIndex === destDateIndex &&
      timetable.termGroup && timetable.termGroup.termStudentIds.includes(termStudentId);
    return isTutorial || isDestTutorial || isGroup;
  }).map((item) => item.periodIndex);
  const destDateOk = dailyBlanksFrom(term, destDateOccupiedPeriodIndexes) <= blankLimit;

  return srcDateOk && destDateOk;
};

const isBlankLimitTeacher = (
  term: Term,
  teacherOptimizationRule: TeacherOptimizationRule,
  timetables: Timetable[],
  srcTimetable: Timetable,
  destTimetable: Timetable,
  tutorialPiece: TutorialPiece,
) => {
  const termTeacherId = tutorialPiece.tutorialContract.termTeacherId;
  const blankLimit = teacherOptimizationRule.blankLimit;
  const srcDateIndex = srcTimetable.dateIndex;
  const destDateIndex = destTimetable.dateIndex;

  const srcDateOccupiedPeriodIndexes = timetables.filter((timetable) => {
    const isTutorial =
      timetable.id !== srcTimetable.id &&
      timetable.dateIndex === srcDateIndex &&
      timetable.occupiedTermTeacherIds.includes(termTeacherId);
    const isDestTutorial = timetable.id === destTimetable.id;
    const isGroup =
      timetable.dateIndex === srcDateIndex &&
      timetable.termGroup && timetable.termGroup.termTeacherId === termTeacherId;
    return isTutorial || isDestTutorial || isGroup;
  }).map((item) => item.periodIndex);
  const srcDateOk = dailyBlanksFrom(term, srcDateOccupiedPeriodIndexes) <= blankLimit;

  const destDateOccupiedPeriodIndexes = timetables.filter((timetable) => {
    const isTutorial =
      timetable.id !== srcTimetable.id &&
      timetable.dateIndex === destDateIndex &&
      timetable.occupiedTermStudentIds.includes(termTeacherId);
    const isDestTutorial = timetable.id === destTimetable.id;
    const isGroup =
      timetable.dateIndex === destDateIndex &&
      timetable.termGroup && timetable.termGroup.termTeacherId === termTeacherId;
    return isTutorial || isDestTutorial || isGroup;
  }).map((item) => item.periodIndex);
  const destDateOk = dailyBlanksFrom(term, destDateOccupiedPeriodIndexes) <= blankLimit;

  return srcDateOk && destDateOk;
};

const dailyBlanksFrom = (term: Term, periodIndexes: number[]) => {
  const init = { flag: false, buffer: 0, sum: 0 };
  const result = _.range(1, term.periodCount + 1).reduce((accu, periodIndex) => {
    const occupied = periodIndexes.includes(periodIndex);
    return {
      flag: accu.flag || occupied,
      buffer: !occupied ? accu.buffer + 1 : 0,
      sum: (accu.flag && occupied) ? accu.sum + accu.buffer : accu.sum,
    };
  }, init);
  return result.sum;
};
