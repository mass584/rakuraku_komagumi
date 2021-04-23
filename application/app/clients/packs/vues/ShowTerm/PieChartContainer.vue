<template>
  <div v-if="term" class="row mt-3 mb-3">
    <div class="col-md-4 col-lg-4">
      <div class="card bg-light mt-2 mb-2">
        <div class="card-header">
          講師のマルバツ表
        </div>
        <div class="card-body">
          <PieChart :data="termTeacherChartData" />
        </div>
      </div>
    </div>
    <div class="col-md-4 col-lg-4">
      <div class="card bg-light mt-2 mb-2">
        <div class="card-header">
          生徒のマルバツ表
        </div>
        <div class="card-body">
          <PieChart :data="termStudentChartData" />
        </div>
      </div>
    </div>
    <div class="col-md-4 col-lg-4">
      <div class="card bg-light mt-2 mb-2">
        <div class="card-header">
          コマ組みの進捗
        </div>
        <div class="card-body">
          <PieChart :data="tutorialPieceChartData" />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import Vue from "vue";

import PieChart from "./components/PieChart";

export default Vue.extend({
  name: 'pie_chart_container',
  components: { PieChart },
  data: () => ({
    isLoading: false,
    term: null,
  }),
  methods: {
    fetchTutorialPieces: async function() {
      const url = '/tutorial_pieces.json';
      const response = await axios.get(url);
      const { term } = response.data;
      this.term = term;
      return response;
    },
    onCreate: async function() {
      this.isLoading = true;
      await this.fetchTutorialPieces();
      this.isLoading = false;
    },
  },
  computed: {
    tutorialPieceChartData() {
      return {
        labels: ['未決定', '仮決定', '決定'],
        datasets: [
          {
            backgroundColor: ['#ddd', '#aaa', '#777'],
            data: [
              this.term.tutorialPieces.filter(item => !item.isFixed && item.seatId === null).length,
              this.term.tutorialPieces.filter(item => !item.isFixed && item.seatId !== null).length,
              this.term.tutorialPieces.filter(item => item.isFixed).length,
            ],
          }
        ],
      }
    },
    termTeacherChartData() {
      return {
        labels: ['編集中', '提出済み', '確定'],
        datasets: [
          {
            backgroundColor: ['#ddd', '#aaa', '#777'],
            data: [
              this.term.termTeachers.filter(item => item.vacancyStatus === 'draft').length,
              this.term.termTeachers.filter(item => item.vacancyStatus === 'submitted').length,
              this.term.termTeachers.filter(item => item.vacancyStatus === 'fixed').length,
            ],
          }
        ],
      }
    },
    termStudentChartData() {
      return {
        labels: ['編集中', '提出済み', '確定'],
        datasets: [
          {
            backgroundColor: ['#ddd', '#aaa', '#777'],
            data: [
              this.term.termStudents.filter(item => item.vacancyStatus === 'draft').length,
              this.term.termStudents.filter(item => item.vacancyStatus === 'submitted').length,
              this.term.termStudents.filter(item => item.vacancyStatus === 'fixed').length,
            ],
          }
        ],
      }
    }
  },
  created: async function() {
    await this.onCreate();
  },
})
</script>

<style scoped lang="scss">
</style>
