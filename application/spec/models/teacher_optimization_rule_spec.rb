require 'rails_helper'

RSpec.describe TeacherOptimizationRule, type: :model do
  describe '講師の違反・コスト設定の作成' do
    before :each do
      term = FactoryBot.create(:first_term)
      @teacher_optimization_rule = term.teacher_optimization_rules.first
    end

    context 'occupation_limitの更新時' do
      it '更新に成功する' do
        expect(@teacher_optimization_rule.update({
          serialized_occupation_costs: '1 2 3',
          occupation_limit: 3,
        })).to eq(true)
        @teacher_optimization_rule.reload
        expect(@teacher_optimization_rule.occupation_limit).to eq(3)
        expect(@teacher_optimization_rule.occupation_costs).to eq([0, 1, 2, 3])
      end

      it '0を指定するとエラー' do
        expect(@teacher_optimization_rule.update(occupation_limit: 0)).to eq(false)
        expect(@teacher_optimization_rule.errors.full_messages).to include(
          '１日の最大コマ数は1以上の値にしてください',
        )
      end
    end

    context 'occupation_costsの更新時' do
      it '設定数が誤っている時にエラー' do
        expect(@teacher_optimization_rule.update(serialized_occupation_costs: '1 2 3 4 5')).to eq(false)
        expect(@teacher_optimization_rule.errors.full_messages).to include(
          '１日のコマ数コストの設定数が間違えています',
        )
      end

      it '文字列が入力された際にエラー' do
        expect(@teacher_optimization_rule.update(serialized_occupation_costs: 'a b c d e f')).to eq(false)
        expect(@teacher_optimization_rule.errors.full_messages).to include(
          '１日のコマ数コストは整数で入力してください',
        )
      end

      it '小数が入力された際にエラー' do
        expect(@teacher_optimization_rule.update(serialized_occupation_costs: '1 2 3 4 5 6.1')).to eq(false)
        expect(@teacher_optimization_rule.errors.full_messages).to include(
          '１日のコマ数コストは整数で入力してください',
        )
      end

      it '範囲外の整数（０〜１００意外）が入力された際にエラー' do
        expect(@teacher_optimization_rule.update(serialized_occupation_costs: '1 2 3 4 5 101')).to eq(false)
        expect(@teacher_optimization_rule.errors.full_messages).to include(
          '１日のコマ数コストは０〜１００を指定してください',
        )
      end
    end

    context 'blank_limitの更新時' do
      it '更新に成功する' do
        expect(@teacher_optimization_rule.update({ serialized_blank_costs: '1 2', blank_limit: 2 })).to eq(true)
        @teacher_optimization_rule.reload
        expect(@teacher_optimization_rule.blank_limit).to eq(2)
        expect(@teacher_optimization_rule.blank_costs).to eq([0, 1, 2])
      end
    end

    context 'blank_costsの更新時' do
      it '設定数が誤っている時にエラー' do
        expect(@teacher_optimization_rule.update(serialized_blank_costs: '1 2')).to eq(false)
        expect(@teacher_optimization_rule.errors.full_messages).to include(
          '１日の空きコマ数コストの設定数が間違えています',
        )
      end

      it '文字列が入力された際にエラー' do
        expect(@teacher_optimization_rule.update(serialized_blank_costs: 'a')).to eq(false)
        expect(@teacher_optimization_rule.errors.full_messages).to include(
          '１日の空きコマ数コストは整数で入力してください',
        )
      end

      it '小数が入力された際にエラー' do
        expect(@teacher_optimization_rule.update(serialized_blank_costs: '1.1')).to eq(false)
        expect(@teacher_optimization_rule.errors.full_messages).to include(
          '１日の空きコマ数コストは整数で入力してください',
        )
      end

      it '範囲外の整数（０〜１００意外）が入力された際にエラー' do
        expect(@teacher_optimization_rule.update(serialized_blank_costs: '101')).to eq(false)
        expect(@teacher_optimization_rule.errors.full_messages).to include(
          '１日の空きコマ数コストは０〜１００を指定してください',
        )
      end
    end
  end
end
