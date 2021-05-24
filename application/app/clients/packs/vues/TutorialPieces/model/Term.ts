export type TermType = 'normal' | 'season' | 'exam_planning';

export type SchoolGrade =
  'e1' |
  'e2' |
  'e3' |
  'e4' |
  'e5' |
  'e6' |
  'j1' |
  'j2' |
  'j3' |
  'h1' |
  'h2' |
  'h3' |
  'other';

export type VacancyStatus = 'draft' | 'submitted' | 'fixed';

export type StudentOptimizationRule = {
  id: number,
  schoolGrade: SchoolGrade,
  occupationLimit: number,
  blankLimit: number,
};

export type TeacherOptimizationRule = {
  id: number,
  occupationLimit: number,
  blankLimit: number,
};

export type Timetable = {
  id: number;
  dateIndex: number;
  periodIndex: number;
  termGroupId: number | null;
  termGroupName: string | null;
  termGroupTeacherIds: number[];
  termGroupStudentIds: number[];
  isClosed: boolean;
  vacantTermTeacherIds: number[];
  vacantTermStudentIds: number[];
  occupiedTermTeacherIds: number[];
  occupiedTermStudentIds: number[];
  seats: Seat[];
};

export type Seat = {
  id: number;
  seatIndex: number;
  termTeacherId: number;
  positionCount: number;
  tutorialPieceIds: number[];
};

export type TermTeacher = {
  id: number;
  vacancyStatus: VacancyStatus;
  termTeacherName: string;
};

export type TermStudent = {
  id: number;
  vacancyStatus: VacancyStatus;
  termTeacherName: string;
};

export type TutorialPiece = {
  id: number;
  seatId: number | null;
  isFixed: boolean;
  termStudentId: number;
  termStudentName: string;
  termStudentSchoolGrade: SchoolGrade;
  termStudentSchoolGradeI18n: string;
  termTutorialId: number;
  termTutorialName: string;
  termTeacherId: number;
};

export type Term = {
  termType: TermType;
  dateCount: number;
  periodCount: number;
  seatCount: number;
  positionCount: number;
  beginAt: string;
  endAt: string;
  teacherOptimizationRules: TeacherOptimizationRule[];
  studentOptimizationRules: StudentOptimizationRule[];
  termTeachers: TermTeacher[];
  termStudents: TermStudent[];
  timetables: Timetable[];
  tutorialPieces: TutorialPiece[];
}
