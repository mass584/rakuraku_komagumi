<template>
  <stand-by
    :term-teacher="termTeacher"
    :term-students="termStudents"
    :tutorial-pieces="tutorialPieces"
    v-on:pushleft="onPushLeft($event.termTeacher)"
    v-on:pushright="onPushRight($event.termTeacher)"
    v-on:dragstart="$emit('dragstart', $event)"
    v-on:dragend="$emit('dragend', $event)"
  />
</template>

<script lang="ts">
import axios from 'axios';
import Vue, { PropType } from 'vue';

import '../components/StandBy.vue';
import { TermTeacher } from '../model/Term';
import { store } from '../store';

export default Vue.component('stand-by-container', {
  props: {
    termTeacher: Object as PropType<TermTeacher>,
  },
  computed: {
    term() {
      return store.state.term;
    },
    termTeachers() {
      return store.state.termTeachers;
    },
    termStudents() {
      return store.state.termStudents;
    },
    tutorialPieces() {
      return store.state.tutorialPieces;
    },
  },
  methods: {
    updateRowOrder: async function(termTeacher: TermTeacher, rowOrderPosition: 'up' | 'down') {
      const url = `/term_teachers/${termTeacher.id}.json`;
      const reqBody = { term_teacher: { row_order_position: rowOrderPosition } };
      await axios.put(url, reqBody);
    },
    onPushLeft: async function(termTeacher: TermTeacher) {
      const termTeacherIndex = this.termTeachers.findIndex((item) => item.id === termTeacher.id);
      if (termTeacherIndex === 0) return;
      store.commit('setIsLoading', true);
      await this.updateRowOrder(termTeacher, 'up');
      const nextTermTeacherIndex = termTeacherIndex - 1;
      const newTermTeachers = this.swapTermTeachers(this.termTeachers, termTeacherIndex, nextTermTeacherIndex);
      store.commit('setTermTeachers', newTermTeachers);
      store.commit('setIsLoading', false);
    },
    onPushRight: async function(termTeacher: TermTeacher) {
      const termTeacherIndex = this.termTeachers.findIndex((item) => item.id === termTeacher.id);
      if (termTeacherIndex === this.termTeachers.length - 1) return;
      store.commit('setIsLoading', true);
      await this.updateRowOrder(termTeacher, 'down');
      const nextTermTeacherIndex = termTeacherIndex + 1;
      const newTermTeachers = this.swapTermTeachers(this.termTeachers, termTeacherIndex, nextTermTeacherIndex);
      store.commit('setTermTeachers', newTermTeachers);
      store.commit('setIsLoading', false);
    },
    swapTermTeachers: function(termTeachers: TermTeacher[], index1: number, index2: number) {
      return termTeachers.reduce(
        (resultArray, item, currentIndex, originalArray) => {
          return [
            ...resultArray,
            currentIndex === index1 ? originalArray[index2] :
            currentIndex === index2 ? originalArray[index1] :
            item,
          ]
        },
        [] as TermTeacher[]
      );
    },
  },
}) 
</script>
