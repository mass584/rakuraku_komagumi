<template>
<div class="container wrapper">
  <div class="row mt-3 mb-3">
    <div class="col-md-3 col-lg-3">
      <div class="card bg-light mt-2 mb-2">
        <div class="card-header">
          生徒数
        </div>
        <div class="card-body">
          <p class="card-text">
            紐付け済み : {{ students.length }} 人
            <br>
            予定入力済 : {{ decidedStudentTerms.length }} 人
            <br>
          </p>
          <button class="btn btn-sm btn-primary" data-toggle="modal" data-target="#student_term_new">
            新しい生徒の紐付け
          </button>
        </div>
      </div>
      <div class="card bg-light mt-2 mb-2">
        <div class="card-header">
          講師数
        </div>
        <div class="card-body">
          <p class="card-text">
            紐付け済み : {{ teachers.length }} 人
            <br>
            予定入力済 : {{ decidedTeacherTerms.length }} 人
            <br>
          </p>
          <button class="btn btn-sm btn-primary" data-toggle="modal" data-target="#teacher_term_new">
            新しい講師の紐付け
          </button>
        </div>
      </div>
    </div>
    <div class="col-md-6 col-lg-6">
      <div class="card bg-light mt-2 mb-2">
        <div class="card-header">
          授業の確定状態
        </div>
        <div class="card-body">
          <PieChart :data="chartdata" :options="{}" />
        </div>
      </div>
    </div>
    <div class="col-md-3 col-lg-3">
      <div class="card bg-light mt-2 mb-2">
        <div class="card-header">
          操作
        </div>
        <div class="card-body">
          <button class="btn btn-sm btn-danger">
            自動コマ組み
          </button>
        </div>
      </div>
      <div class="card bg-light mt-2 mb-2">
        <div class="card-header">
          科目数
        </div>
        <div class="card-body">
          <p class="card-text">
            紐付け済み : {{ subjects.length }} 科目
          </p>
          <button class="btn btn-sm btn-primary" data-toggle="modal" data-target="#teacher_term_new">
            新しい科目の紐付け
          </button>
        </div>
      </div>
    </div>
  </div>
</div>
</template>

<script>
import axios from 'axios';
import Vue from "vue";
import PieChart from "./PieChart";

export default Vue.extend({
  name: 'term',
  components: {
    PieChart,
  },
  data: () => ({
    loaded: false,
    terms: {},
    students: [],
    studentTerms: [],
    teachers: [],
    teacherTerms: [],
    subjects: [],
    subjectTerms: [],
    pieces: [],
  }),
  computed: {
    decidedTeacherTerms(vm) {
      return vm.teacherTerms.filter(item => item.is_decided);
    },
    decidedStudentTerms(vm) {
      return vm.studentTerms.filter(item => item.is_decided);
    },
    chartdata(vm) {
      return {
        labels: ['未決定', '仮決定', '決定'],
        datasets: [
          {
            backgroundColor: ['#ddd', '#aaa', '#777'],
            data: [
              vm.pieces.filter(item => !item.is_fixed && item.seat_id === null).length,
              vm.pieces.filter(item => !item.is_fixed && item.seat_id !== null).length,
              vm.pieces.filter(item => item.is_fixed).length,
            ],
          }
        ],
      }
    },
  },
  methods: {
    fetchTeachers: async function() {
      await axios.get(`/teacher.json`).then(res => this.teachers = res.data);
    },
    fetchTeacherTerms: async function() {
      await axios.get(`/teacher_term.json`).then(res => this.teacherTerms = res.data);
    },
    fetchStudents: async function() {
      await axios.get(`/student.json`).then(res => this.students = res.data);
    },
    fetchStudentTerms: async function() {
      await axios.get(`/student_term.json`).then(res => this.studentTerms = res.data);
    },
    fetchSubjects: async function() {
      await axios.get(`/subject.json`).then(res => this.subjects = res.data);
    },
    fetchSubjectTerms: async function() {
      await axios.get(`/subject_term.json`).then(res => this.subjectTerms = res.data);
    },
    fetchPieces: async function() {
      await axios.get("/piece.json").then(res => this.pieces = res.data);
    },
  },
  async created() {
    await this.fetchStudentTerms();
    await this.fetchStudents();
    await this.fetchTeacherTerms();
    await this.fetchTeachers();
    await this.fetchSubjectTerms();
    await this.fetchSubjects();
    await this.fetchPieces();
    this.loaded = true;
  },
}) 
</script>

<style scoped lang="scss">
</style>
