<template>
  <div class="overflow-auto">
    <table v-for="date in dateArray" v-bind:key="date" class="table table-bordered">
      <thead>
        <tr>
          <th>座席</th>
          <th v-for="period in periodArray" v-bind:key="period">{{ period }}限</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="seat in seatArray" v-bind:key="seat">
          <th>{{ seat }}番</th>
          <td v-for="period in periodArray" v-bind:key="period">
            {{ seats[date][String(period)][String(seat)]['teacher_term_id'] }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import axios from 'axios';
import Vue from "vue";

export default Vue.extend({
  name: 'pieces',
  props: ['termId'],
  data: () => ({
    term: {},
    seats: [],
    pieces: [],
  }),
  computed: {
    dateArray(vm) {
      return [vm.term.begin_at, vm.term.end_at];
    },
    periodArray(vm) {
      return Array.from({ length: vm.term.max_period }, (v, k) => k + 1);
    },
    seatArray(vm) {
      return Array.from({ length: vm.term.max_seat }, (v, k) => k + 1);
    }
  },
  methods: {
    fetchTerm: function() {
      axios.get(`term/${this.termId}.json`).then(res => {
        const term = res.data;
        this.term = term;
        this.setDateArray();
        this.setPeriodArray();
        this.setSeatArray();
      });
    },
    fetchSeats: function() {
      axios.get("seat.json").then(res => this.seats = res.data);
    },
    fetchPieces: function() {
      axios.get("piece.json").then(res => this.pieces = res.data);
    },
  },
  mounted() {
    this.fetchTerm();
    this.fetchSeats();
    this.fetchPieces();
  }
}) 
</script>

<style scoped lang="scss">
</style>