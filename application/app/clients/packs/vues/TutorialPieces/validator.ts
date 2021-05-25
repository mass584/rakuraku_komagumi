import {
  StudentOptimizationRule,
  TeacherOptimizationRule,
  Timetable,
  TermTeacher,
  TutorialPiece,
} from './model/Term';

export const validate = (
  periodCount: number,
  seatCount: number,
  positionCount: number,
  studentOptimizationRules: StudentOptimizationRule[],
  teacherOptimizationRules: TeacherOptimizationRule[],
  timetables: Timetable[],
  srcTimetable: Timetable | null,
  destTimetable: Timetable,
  termTeacher: TermTeacher,
  tutorialPiece: TutorialPiece,
) => {
  return (
    isStudentVacant(destTimetable, tutorialPiece) &&
    isTeacherVacant(destTimetable, termTeacher) &&
    isSeatVacant(seatCount, positionCount, destTimetable, tutorialPiece) &&
    isNotDuplicateStudent(destTimetable, tutorialPiece) &&
    isUnderStudentOccupationLimit(studentOptimizationRules, timetables, srcTimetable, destTimetable, tutorialPiece) &&
    isUnderTeacherOccupationLimit(teacherOptimizationRules, timetables, srcTimetable, destTimetable, tutorialPiece) &&
    isUnderStudentBlankLimit(periodCount, studentOptimizationRules, timetables, srcTimetable, destTimetable, tutorialPiece) &&
    isUnderTeacherBlankLimit(periodCount, teacherOptimizationRules, timetables, srcTimetable, destTimetable, tutorialPiece)
  );
};

export const isStudentVacant = (
  destTimetable: Timetable,
  tutorialPiece: TutorialPiece,
) => {
  return destTimetable.vacantTermStudentIds.includes(tutorialPiece.termStudentId);
};

export const isTeacherVacant = (
  destTimetable: Timetable,
  termTeacher: TermTeacher,
) => {
  return destTimetable.vacantTermTeacherIds.includes(termTeacher.id);
};

const isSeatVacant = (
  seatCount: number,
  positionCount: number,
  destTimetable: Timetable,
  tutorialPiece: TutorialPiece,
) => {
  const termTeacherSeat = destTimetable.seats.find((seat) => {
    return seat.termTeacherId === tutorialPiece.termTeacherId;
  });
  const isVacant = (() => {
    if (termTeacherSeat) {
      return termTeacherSeat.tutorialPieceIds.length < positionCount;
    } else {
      const occupiedSeatCount = destTimetable.occupiedTermTeacherIds.length;
      return occupiedSeatCount < seatCount;
    }
  })();

  return isVacant;
};

const isNotDuplicateStudent = (
  destTimetable: Timetable,
  tutorialPiece: TutorialPiece,
) => {
  return !destTimetable.occupiedTermStudentIds.includes(tutorialPiece.termStudentId);
};

const isUnderStudentOccupationLimit = (
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
  const isSameDate = srcDateIndex === destDateIndex;
  const destDateOccupation = timetables.filter((timetable) => {
    const isTutorial =
      (timetable.dateIndex === destDateIndex) &&
      timetable.occupiedTermStudentIds.includes(termStudentId);
    const isGroup =
      (timetable.dateIndex === destDateIndex) &&
      timetable.termGroupStudentIds.includes(termStudentId);
    return isTutorial || isGroup;
  }).length;
  const isUnderLimit = destDateOccupation < occupationLimit;

  return isSameDate || isUnderLimit;
};

const isUnderTeacherOccupationLimit = (
  teacherOptimizationRules: TeacherOptimizationRule[],
  timetables: Timetable[],
  srcTimetable: Timetable | null,
  destTimetable: Timetable,
  tutorialPiece: TutorialPiece,
) => {
  const termTeacherId = tutorialPiece.termTeacherId;
  const occupationLimit = teacherOptimizationRules[0].occupationLimit;
  const srcDateIndex = srcTimetable ? srcTimetable.dateIndex : null;
  const destDateIndex = destTimetable.dateIndex;
  const isSameDate = srcDateIndex === destDateIndex;
  const destDateOccupation = timetables.filter((timetable) => {
    const isTutorial =
      (timetable.dateIndex === destDateIndex) &&
      timetable.occupiedTermTeacherIds.includes(termTeacherId);
    const isGroup =
      (timetable.dateIndex === destDateIndex) &&
      timetable.termGroupTeacherIds.includes(termTeacherId);
    return isTutorial || isGroup;
  }).length;
  const isUnderLimit = destDateOccupation < occupationLimit;

  return isSameDate || isUnderLimit;
}

const isUnderStudentBlankLimit = (
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
    return timetable.dateIndex === srcDateIndex;
  }).filter((timetable) => {
    const isTutorialBefore = timetable.occupiedTermStudentIds.includes(termStudentId);
    const isSrcTutorial = srcTimetable && timetable.id === srcTimetable.id;
    const isDestTutorial = timetable.id === destTimetable.id;
    const isTutorial = (isTutorialBefore && !isSrcTutorial) || isDestTutorial;
    const isGroup = timetable.termGroupStudentIds.includes(termStudentId);

    return isTutorial || isGroup;
  }).map((item) => item.periodIndex);
  const srcDateOk = !srcTimetable || dailyBlanksFrom(periodCount, srcDateOccupiedPeriodIndexes) <= blankLimit;
  const destDateOccupiedPeriodIndexes = timetables.filter((timetable) => {
    return timetable.dateIndex === destDateIndex;
  }).filter((timetable) => {
    const isTutorialBefore = timetable.occupiedTermStudentIds.includes(termStudentId);
    const isSrcTutorial = srcTimetable && timetable.id === srcTimetable.id;
    const isDestTutorial = timetable.id === destTimetable.id;
    const isTutorial = (isTutorialBefore && !isSrcTutorial) || isDestTutorial;
    const isGroup = timetable.termGroupStudentIds.includes(termStudentId);

    return isTutorial || isGroup;
  }).map((item) => item.periodIndex);
  const destDateOk = dailyBlanksFrom(periodCount, destDateOccupiedPeriodIndexes) <= blankLimit;

  return srcDateOk && destDateOk;
};

const isUnderTeacherBlankLimit = (
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
    return timetable.dateIndex === srcDateIndex;
  }).filter((timetable) => {
    const isTutorialBefore = timetable.occupiedTermTeacherIds.includes(termTeacherId);
    const isSrcTutorial = srcTimetable && timetable.id === srcTimetable.id;
    const isDestTutorial = timetable.id === destTimetable.id;
    const isTutorial = (isTutorialBefore && !isSrcTutorial) || isDestTutorial;
    const isGroup = timetable.termGroupTeacherIds.includes(termTeacherId);

    return isTutorial || isGroup;
  }).map((item) => item.periodIndex);
  const srcDateOk = !srcTimetable || dailyBlanksFrom(periodCount, srcDateOccupiedPeriodIndexes) <= blankLimit;
  const destDateOccupiedPeriodIndexes = timetables.filter((timetable) => {
    return timetable.dateIndex === destDateIndex;
  }).filter((timetable) => {
    const isTutorialBefore = timetable.occupiedTermTeacherIds.includes(termTeacherId);
    const isSrcTutorial = srcTimetable && timetable.id === srcTimetable.id;
    const isDestTutorial = timetable.id === destTimetable.id;
    const isTutorial = (isTutorialBefore && !isSrcTutorial) || isDestTutorial;
    const isGroup = timetable.termGroupTeacherIds.includes(termTeacherId);

    return isTutorial || isGroup;
  }).map((item) => item.periodIndex);
  const destDateOk = dailyBlanksFrom(periodCount, destDateOccupiedPeriodIndexes) <= blankLimit;

  return srcDateOk && destDateOk;
};

const dailyBlanksFrom = (periodCount: number, periodIndexes: number[]) => {
  const init = { flag: false, buffer: 0, sum: 0 };
  const result = Array.from({ length: periodCount }, (_, i) => i + 1).reduce((accu, periodIndex) => {
    const occupied = periodIndexes.includes(periodIndex);
    return {
      flag: accu.flag || occupied,
      buffer: !occupied ? accu.buffer + 1 : 0,
      sum: (accu.flag && occupied) ? accu.sum + accu.buffer : accu.sum,
    };
  }, init);
  return result.sum;
};
