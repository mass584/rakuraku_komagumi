import Vue from 'vue';
import Vuex, { Store } from 'vuex';

import {
  Seat,
  StudentOptimizationRule,
  TeacherOptimizationRule,
  Term,
  TermStudent,
  TermTeacher,
  Timetable,
  TutorialPiece,
} from './model/Term';
import { Position } from './model/Position';

Vue.use(Vuex);

export const store = new Store<{
  term: Term | null;
  studentOptimizationRules: StudentOptimizationRule[];
  teacherOptimizationRules: TeacherOptimizationRule[];
  timetables: Timetable[];
  seats: Seat[];
  termTeachers: TermTeacher[];
  termStudents: TermStudent[];
  tutorialPieces: TutorialPiece[];
  isLoading: boolean;
  isLoaded: boolean;
  droppables: Position[];
  notVacants: Position[];
  selectedTermTeacherId: number | null;
}>({
  state: {
    term: null,
    studentOptimizationRules: [],
    teacherOptimizationRules: [],
    timetables: [],
    seats: [],
    termTeachers: [],
    termStudents: [],
    tutorialPieces: [],
    isLoading: false,
    isLoaded: true,
    droppables: [],
    notVacants: [],
    selectedTermTeacherId: null,
  },
  mutations: {
    setTermObject (state, termObject) {
      state.term = termObject.term
      state.studentOptimizationRules = termObject.studentOptimizationRules
      state.teacherOptimizationRules = termObject.teacherOptimizationRules
      state.timetables = termObject.timetables
      state.termTeachers = termObject.termTeachers
      state.termStudents = termObject.termStudents
      state.tutorialPieces = termObject.tutorialPieces
      state.isLoaded = true
    },
    setTermTeachers (state, termTeachers) {
      state.termTeachers = termTeachers
    },
    setTimetables (state, timetables) {
      state.timetables = timetables
    },
    setTutorialPieces (state, tutorialPieces) {
      state.tutorialPieces = tutorialPieces
    },
    setIsLoading (state, isLoading) {
      state.isLoading = isLoading
    },
    setNotVacants (state, notVacants) {
      state.notVacants = notVacants
    },
    setDroppables (state, droppables) {
      state.droppables = droppables
    },
    setSelectedTermTeacherId (state, selectedTermTeacherId) {
      state.selectedTermTeacherId = selectedTermTeacherId
    },
    resetDragState (state) {
      state.selectedTermTeacherId = null
      state.notVacants = []
      state.droppables = []
    }
  }
});
