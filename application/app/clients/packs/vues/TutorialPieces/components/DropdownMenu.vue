<template>
  <div>
    <div class="dropdown">
      <button class="btn btn-light dropdown-toggle" type="button" id="dropdown-menu" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
        <i class="bi bi-gear"></i>
      </button>
      <div class="dropdown-menu" aria-labelledby="dropdown-menu">
        <button class="dropdown-item" type="button" data-toggle="modal" data-target="#unlock-all-modal">
          全てのコマのロックを解除する
        </button>
        <button class="dropdown-item" type="button" data-toggle="modal" data-target="#lock-all-modal">
          全てのコマをロックする
        </button>
        <button class="dropdown-item" type="button" data-toggle="modal" data-target="#reset-all-modal">
          全てのコマをリセットする
        </button>
      </div>
    </div>
    <div class="modal fade" id="unlock-all-modal" tabindex="-1" role="dialog" aria-labelledby="unlock-all-modal" aria-hidden="true">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">全てのコマのロックを解除します</h5>
            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
            全てのコマのロックを解除します。よろしいですか。
            <br />
            ロックした状態では、自動コマ組みの際にコマの位置を移動しないようにできます。また、スケジュール変更の誤操作防止に繋がります。
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-dismiss="modal">閉じる</button>
            <button type="button" class="btn btn-primary" v-on:click="$emit('unlock-all')">実行</button>
          </div>
        </div>
      </div>
    </div>
    <div class="modal fade" id="lock-all-modal" tabindex="-1" role="dialog" aria-labelledby="lock-all-modal" aria-hidden="true">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">全てのコマをロックします</h5>
            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
            全てのコマをロックします。よろしいですか。
            <br />
            ロックした状態では、自動コマ組みの際にコマの位置を移動しないようにできます。また、スケジュール変更の誤操作防止に繋がります。
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-dismiss="modal">閉じる</button>
            <button type="button" class="btn btn-primary" v-on:click="$emit('lock-all')">実行</button>
          </div>
        </div>
      </div>
    </div>
    <div class="modal fade" id="reset-all-modal" tabindex="-1" role="dialog" aria-labelledby="lock-all-modal" aria-hidden="true">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">全てのコマをリセットします</h5>
            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
            全てのコマをリセットします。よろしいですか。
            <br />
            リセットしたスケジュールを元に戻すことはできません。
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-dismiss="modal">閉じる</button>
            <button type="button" class="btn btn-danger" v-on:click="$emit('reset-all')">実行</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import Vue from 'vue';

export default Vue.component('dropdown-menu', {}) 
</script>

<style scoped lang="scss">
</style>
