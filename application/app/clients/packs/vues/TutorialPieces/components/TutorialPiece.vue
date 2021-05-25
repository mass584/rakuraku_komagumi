<template>
  <div>
    <transition name="fade">
      <div v-if="isDeletionError">
        <div class="modal" v-on:click.self="$emit('closemodal')">
          <div class="modal-dialog" role="document">
            <div class="modal-content">
              <div class="modal-header">
                <h5 class="modal-title">削除できませんでした</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                  <span aria-hidden="true">&times;</span>
                </button>
              </div>
              <div class="modal-body">
                空きコマの上限をオーバーしてしまうため、削除できません。
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-primary" v-on:click="$emit('closemodal')">OK</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </transition>
    <div
      class="px-1 d-flex align-item-center justify-content-between piece border border-white text-center bg-warning"
      v-bind:class="{ 'bg-warning-light': tutorialPiece.isFixed }"
      v-bind:draggable="!tutorialPiece.isFixed"
      v-on:dragstart="$emit('dragstart', { event: $event })"
      v-on:dragend="$emit('dragend', { event: $event })"
    >
      <div>
        <small>{{ displayText }}</small>
      </div>
      <div>
        <i v-on:click="$emit('toggle', { event: $event })" class="icon bi bi-key"></i>
        <i v-if="!tutorialPiece.isFixed" v-on:click="$emit('delete', { event: $event })" class="icon bi bi-x-circle"></i>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import Vue, { PropType } from 'vue';

import { TutorialPiece } from '../model/Term';

export default Vue.component('tutorial-piece', {
  props: {
    tutorialPiece: Object as PropType<TutorialPiece>,
    isDeletionError: Boolean as PropType<Boolean>,
  },
  computed: {
    displayText() {
      const studentName = this.tutorialPiece.termStudentName;
      const studentSchoolGrade = this.tutorialPiece.termStudentSchoolGradeI18n;
      const tutorialName = this.tutorialPiece.termTutorialName;

      return `${studentSchoolGrade} ${studentName} ${tutorialName}`;
    },
  },
}) 
</script>

<style scoped lang="scss">
.fade-enter-active, .fade-leave-active {
  transition: opacity .15s;
}
.fade-enter, .fade-leave-to {
  opacity: 0;
}
.icon:hover {
  background-color: rgba(255, 255, 255, 0.6);
}
.modal {
  display: block;
  background-color: rgba(0, 0, 0, 0.8);
}
.piece {
  cursor: pointer;
  height: 100%;
  width: 100%;
  min-width: 100%;
}
</style>
