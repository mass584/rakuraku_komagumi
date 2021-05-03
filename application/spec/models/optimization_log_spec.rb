require 'rails_helper'

RSpec.describe OptimizationLog, type: :model do
  describe 'ログの作成（１回目）' do
    before :each do
      @optimization_log = FactoryBot.create(:optimization_log)
      @term = @optimization_log.term
    end

    context '作成時' do
      it 'Termの最適化実行中フラグがONになる' do
        expect(@term.is_optimizing).to eq(true)
      end
    end

    context '終了ステータス更新時' do
      it 'Termの最適化実行中フラグがOFFになる' do
        Timecop.freeze(Time.zone.now)
        expect(@optimization_log.succeed!).to eq(true)
        expect(@term.is_optimizing).to eq(false)
        expect(@optimization_log.reload.end_at).not_to eq(nil)
        Timecop.return
      end
    end
  end

  describe 'ログの作成（２回目以降）' do
    before :each do
      optimization_log = FactoryBot.create(:optimization_log)
      @term = optimization_log.term
    end

    context '作成時' do
      it 'シーケンス番号が繰り越される' do
        @optimization_log = OptimizationLog.create(term_id: @term.id)
        expect(@optimization_log.sequence_number).to eq(2)
      end
    end
  end
end
