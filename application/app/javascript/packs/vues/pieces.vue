<template>
<div class="container wrapper">
  <div class="overflow-auto">
    <table
      v-for="date in dateArray"
      v-bind:key="date"
      class="table table-bordered"
    >
      <caption>{{ date }}</caption>
      <thead>
        <tr>
          <th>座席</th>
          <th v-for="period in periodArray" v-bind:key="period">
            {{ period }}限
          </th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="seat in seatArray" v-bind:key="seat">
          <th>{{ seat }}番</th>
          <td v-for="period in periodArray" v-bind:key="period">
            <div
              v-if="getSeat(date, period, seat)"
              v-bind:class="seatClass(date, period, seat)"
            >
              <div class="frame-teacher">
                {{ getSeat(date, period, seat).teacher_name }}
              </div>
              <div
                v-for="frame in frameArray"
                v-bind:key="frame"
                class="frame-student"
                @drop="drop($event, date, period, seat, frame)"
                @dragover="dragover($event, date, period, seat, frame)"
                @dragenter.prevent
              >
                <div
                  v-if="getPiece(date, period, seat, frame)"
                  class="piece"
                  v-bind:draggable="!getPiece(date, period, seat, frame).is_fixed"
                  @dragstart="dragstart($event, date, period, seat, frame)"
                >
                  {{ getPiece(date, period, seat, frame).student_name }}
                  {{ getPiece(date, period, seat, frame).subject_name }}
                </div>
              </div>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
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
    },
    frameArray(vm) {
      return Array.from({ length: vm.term.max_frame }, (v, k) => k + 1);
    },
  },
  methods: {
    fetchTerm: function() {
      axios.get(`term/${this.termId}.json`).then(res => this.term = res.data);
    },
    fetchSeats: function() {
      axios.get("seat.json").then(res => this.seats = res.data);
    },
    fetchPieces: function() {
      axios.get("piece.json").then(res => this.pieces = res.data);
    },
    updatePiece: async function(piece, seat) {
      const response = await axios.put(
        `piece/${piece.id}`, { seat_id: seat.id }
      ).catch(
        (error) => error.response,
      );
      return response.status === 200;
    },
    getSeat: function(date, period, number) {
      return this.seats.find(item => {
        return item.date === date && item.period === period && item.number === number;
      });
    },
    getSeatById: function(id) {
      return this.seats.find(item => {
        return item.id === id;
      });
    },
    getPiece: function(date, period, number, frame) {
      return this.pieces.filter(item => {
        return item.date === date && item.period === period && item.number === number;
      })[frame - 1];
    },
    getPieces: function(date, period, number) {
      return this.pieces.filter(item => {
        return item.date === date && item.period === period && item.number === number;
      });
    },
    getPieceById: function(id) {
      return this.pieces.find(item => {
        return item.id === id;
      });
    },
    dragstart: function(event, date, period, seatNumber, frame) {
      const piece = this.getPiece(date, period, seatNumber, frame);
      event.dataTransfer.effectAllowed = 'move';
      event.dataTransfer.dropEffect = 'move';
      event.dataTransfer.setData('pieceId', piece.id);
      this.seats = this.seats.map(seat => {
        const droppable = this.studentVacant(seat, piece) &&
          this.teacherVacant(seat, piece) &&
          this.tannin(seat, piece);
        return { ...seat, droppable };
      });
    },
    dragover: function(event, date, period, seatNumber, frame) {
      const pieceId = Number(event.dataTransfer.getData('pieceId'));
      const piece = this.getPieceById(pieceId);
      const seat = this.getSeat(date, period, seatNumber);
      if (seat.droppable) event.preventDefault();
    },
    drop: async function(event, date, period, seatNumber, frame) {
      const pieceId = Number(event.dataTransfer.getData('pieceId'));
      const piece = this.getPieceById(pieceId);
      const seat = this.getSeat(date, period, seatNumber);
      const res = await this.updatePiece(piece, seat);
      this.seats = this.seats.map(seat => {
        return { ...seat, droppable: false };
      });
      if (res) {
        piece.seat_id = seat.id;
        piece.date = date;
        piece.period = period;
        piece.number = seatNumber;
        seat.teacher_term_id = piece.teacher_term_id
        seat.teacher_name = piece.teacher_name
      }
    },
    studentVacant: function(seat, piece) {
      return !this.pieces.find(item => {
        return item.student_term_id === piece.student_term_id &&
          item.date === seat.date &&
          item.period === seat.period;
      });
    },
    teacherVacant: function(seat, piece) {
      return !this.seats.find(item => {
        return item.teacher_term_id === piece.teacher_term_id &&
          item.date === seat.date &&
          item.period === seat.period &&
          item.id !== seat.id;
      });
    },
    tannin: function(seat, piece) {
      return seat.teacher_term_id === null ||
        seat.teacher_term_id === piece.teacher_term_id;
    },
    seatClass: function(date, period, seatNumber) {
      const seat = this.getSeat(date, period, seatNumber);
      return seat.droppable ? "seat seat__droppable" : "seat";
    }
  },
  created() {
    this.fetchTerm();
    this.fetchSeats();
    this.fetchPieces();
  }
}) 
</script>

<style scoped lang="scss">
.wrapper {
  caption {
    caption-side: top;
    color: #212529;
    text-align: center;
  }
  .table td {
    background-color: white;
    margin: 0;
    padding: 0;
    width: 150px;
  }
  .seat__droppable {
    background-color: tomato;
  }
  .frame-teacher {
    background-color: #eee;
    height: 25px;
    text-align: center;
  }
  .frame-student {
    box-sizing: border-box;
    border: 1px solid #eee;
    height: 30px;
  }
  .piece {
    background-color: #f0ad4e;
    border: 1px solid #444;
    cursor: pointer;
    display: inline-block;
    height: 100%;
    width: 100%;
  }
}

</style>
