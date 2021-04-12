export type Term = {
  id: number,
  name: string,
  year: number,
  dateCount: number,
  periodCount: number,
  seatCount: number,
  positionCount: number;
  studentOptimitzationRules: StudentOptimizationRule[];
  teacherOptimizationRules: TeacherOptimizationRule[];
  termTeachers: TermTeacher[];
  timetables: Timetable[];
  tutorialPieces: TutorialPiece[];
};

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
  termGroupId: number;
  termGroup: TermGroup | null;
  isClosed: boolean;
  vacantTermTeacherIds: number[];
  vacantTermStudentIds: number[];
  occupiedTermTeacherIds: number[];
  occupiedTermStudentIds: number[];
  seats: Seat[];
};

export type TermGroup = {
  id: number;
  termTeacherId: number;
  termGroupName: string;
  termStudentIds: number[];
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

export type VacancyStatus = 'draft' | 'submitted' | 'fixed';

export type TutorialPiece = {
  id: number;
  tutorialContractId: number;
  tutorialContract: TutorialContract;
  seatId: number | null;
  isFixed: boolean;
};

export type TutorialContract = {
  id: number;
  termTutorialId: number;
  termStudentId: number;
  termTeacherId: number;
  pieceCount: number;
  termTutorialName: string;
  termStudentName: string;
  termStudentSchoolGrade: SchoolGrade;
};

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

export type Droppable = {
  termTeacherId: number;
  timetableId: number;
};
