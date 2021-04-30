require 'rails_helper'

RSpec.describe StudentOptimizationRule, type: :model do
  describe '生徒の違反・コスト設定の作成' do
    before :each do
      term = FactoryBot.create(:first_term)
      @student_optimization_rule = term.student_optimization_rules.first
    end

    context 'occupation_limitの更新時' do
      it '更新に成功する' do
        expect(@student_optimization_rule.update({
          serialized_occupation_costs: '1 2 3 4',
          occupation_limit: 4,
        })).to eq(true)
        @student_optimization_rule.reload
        expect(@student_optimization_rule.occupation_limit).to eq(4)
        expect(@student_optimization_rule.occupation_costs).to eq([0, 1, 2, 3, 4])
      end

      it '0を指定するとエラー' do
        expect(@student_optimization_rule.update(occupation_limit: 0)).to eq(false)
        expect(@student_optimization_rule.errors.full_messages).to include(
          '１日の最大コマ数は1以上の値にしてください',
        )
      end
    end

    context 'occupation_costsの更新時' do
      it '設定数が誤っている時にエラー' do
        expect(@student_optimization_rule.update(serialized_occupation_costs: '1 2 3 4')).to eq(false)
        expect(@student_optimization_rule.errors.full_messages).to include(
          '１日のコマ数に対するコスト値の設定数が間違えています',
        )
      end

      it '文字列が入力された際にエラー' do
        expect(@student_optimization_rule.update(serialized_occupation_costs: 'a b c')).to eq(false)
        expect(@student_optimization_rule.errors.full_messages).to include(
          '１日のコマ数に対するコスト値は整数で入力してください',
        )
      end

      it '小数が入力された際にエラー' do
        expect(@student_optimization_rule.update(serialized_occupation_costs: '1 2 3.1')).to eq(false)
        expect(@student_optimization_rule.errors.full_messages).to include(
          '１日のコマ数に対するコスト値は整数で入力してください',
        )
      end

      it '範囲外の整数（０〜１００意外）が入力された際にエラー' do
        expect(@student_optimization_rule.update(serialized_occupation_costs: '1 2 101')).to eq(false)
        expect(@student_optimization_rule.errors.full_messages).to include(
          '１日のコマ数に対するコスト値は０〜１００を指定してください',
        )
      end
    end

    context 'blank_limitの更新時' do
      it '更新に成功する' do
        expect(@student_optimization_rule.update({ serialized_blank_costs: '1 2', blank_limit: 2 })).to eq(true)
        @student_optimization_rule.reload
        expect(@student_optimization_rule.blank_limit).to eq(2)
        expect(@student_optimization_rule.blank_costs).to eq([0, 1, 2])
      end
    end

    context 'blank_costsの更新時' do
      it '設定数が誤っている時にエラー' do
        expect(@student_optimization_rule.update(serialized_blank_costs: '1 2')).to eq(false)
        expect(@student_optimization_rule.errors.full_messages).to include(
          '１日の空きコマ数に対するコスト値の設定数が間違えています',
        )
      end

      it '文字列が入力された際にエラー' do
        expect(@student_optimization_rule.update(serialized_blank_costs: 'a')).to eq(false)
        expect(@student_optimization_rule.errors.full_messages).to include(
          '１日の空きコマ数に対するコスト値は整数で入力してください',
        )
      end

      it '小数が入力された際にエラー' do
        expect(@student_optimization_rule.update(serialized_blank_costs: '1.1')).to eq(false)
        expect(@student_optimization_rule.errors.full_messages).to include(
          '１日の空きコマ数に対するコスト値は整数で入力してください',
        )
      end

      it '範囲外の整数（０〜１００意外）が入力された際にエラー' do
        expect(@student_optimization_rule.update(serialized_blank_costs: '101')).to eq(false)
        expect(@student_optimization_rule.errors.full_messages).to include(
          '１日の空きコマ数に対するコスト値は０〜１００を指定してください',
        )
      end
    end

    context 'interval_cutoffの更新時' do
      it '更新に成功する' do
        expect(@student_optimization_rule.update({
          serialized_interval_costs: '1 2 3 4',
          interval_cutoff: 3,
        })).to eq(true)
        @student_optimization_rule.reload
        expect(@student_optimization_rule.interval_cutoff).to eq(3)
        expect(@student_optimization_rule.interval_costs).to eq([1, 2, 3, 4])
      end
    end

    context 'interval_costsの更新時' do
      it '設定数が誤っている時にエラー' do
        expect(@student_optimization_rule.update(serialized_interval_costs: '1 2')).to eq(false)
        expect(@student_optimization_rule.errors.full_messages).to include(
          '受講間隔に対するコスト値の設定数が間違えています',
        )
      end

      it '文字列が入力された際にエラー' do
        expect(@student_optimization_rule.update(serialized_interval_costs: 'a 2 3')).to eq(false)
        expect(@student_optimization_rule.errors.full_messages).to include(
          '受講間隔に対するコスト値は整数で入力してください',
        )
      end

      it '小数が入力された際にエラー' do
        expect(@student_optimization_rule.update(serialized_interval_costs: '1.1 2 3')).to eq(false)
        expect(@student_optimization_rule.errors.full_messages).to include(
          '受講間隔に対するコスト値は整数で入力してください',
        )
      end

      it '範囲外の整数（０〜１００意外）が入力された際にエラー' do
        expect(@student_optimization_rule.update(serialized_interval_costs: '101 2 3')).to eq(false)
        expect(@student_optimization_rule.errors.full_messages).to include(
          '受講間隔に対するコスト値は０〜１００を指定してください',
        )
      end
    end
  end
end
