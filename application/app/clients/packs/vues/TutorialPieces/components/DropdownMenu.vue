<template>
  <div class="text-left">
    <transition name="fade">
      <div v-if="unlock_all_modal">
        <div class="modal" v-on:click.self="unlock_all_modal=false">
          <div class="modal-dialog" role="document">
            <div class="modal-content">
              <div class="modal-header">
                <h5 class="modal-title">全てのコマのロックを解除します</h5>
              </div>
              <div class="modal-body">
                全てのコマのロックを解除します。よろしいですか。
                <br />
                ロックした状態では、自動コマ組みの際にコマの位置を移動しないようにできます。また、スケジュール変更の誤操作防止に繋がります。
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" v-on:click="unlock_all_modal=false">閉じる</button>
                <button type="button" class="btn btn-primary" v-on:click="$emit('unlock-all')">実行</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </transition>
    <transition name="fade">
      <div v-if="lock_all_modal">
        <div class="modal" v-on:click.self="lock_all_modal=false">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header">
                <h5 class="modal-title">全てのコマをロックします</h5>
              </div>
              <div class="modal-body">
                全てのコマをロックします。よろしいですか。
                <br />
                ロックした状態では、自動コマ組みの際にコマの位置を移動しないようにできます。また、スケジュール変更の誤操作防止に繋がります。
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" v-on:click="lock_all_modal=false">閉じる</button>
                <button type="button" class="btn btn-primary" v-on:click="$emit('lock-all')">実行</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </transition>
    <transition name="fade">
      <div v-if="reset_all_modal">
        <div class="modal" v-on:click.self="reset_all_modal=false">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header">
                <h5 class="modal-title">全てのコマをリセットします</h5>
              </div>
              <div class="modal-body">
                全てのコマをリセットします。よろしいですか。
                <br />
                リセットしたスケジュールを元に戻すことはできません。
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" v-on:click="reset_all_modal=false">閉じる</button>
                <button type="button" class="btn btn-danger" v-on:click="$emit('reset-all')">実行</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </transition>
    <div class="dropdown">
      <button class="btn btn-light btn-sm dropdown-toggle" type="button" id="dropdown-menu" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
        <i class="bi bi-gear"></i>
      </button>
      <div class="dropdown-menu" aria-labelledby="dropdown-menu">
        <button class="dropdown-item" type="button" v-on:click="unlock_all_modal=true">
          全てのコマのロックを解除する
        </button>
        <button class="dropdown-item" type="button" v-on:click="lock_all_modal=true">
          全てのコマをロックする
        </button>
        <button class="dropdown-item" type="button" v-on:click="reset_all_modal=true">
          全てのコマをリセットする
        </button>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import Vue from 'vue';

export default Vue.component('dropdown-menu', {
  data(): {
    reset_all_modal: boolean;
    lock_all_modal: boolean;
    unlock_all_modal: boolean;
  } {
    return {
      reset_all_modal: false,
      lock_all_modal: false,
      unlock_all_modal: false,
    }
  }
}) 
</script>

<style scoped lang="scss">
.modal {
  display: block;
  background-color: rgba(0, 0, 0, 0.8);
}
.fade-enter-active, .fade-leave-active {
  transition: opacity .15s;
}
.fade-enter, .fade-leave-to {
  opacity: 0;
}
</style>
