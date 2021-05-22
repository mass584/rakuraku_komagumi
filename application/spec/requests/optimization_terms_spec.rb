# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OptimizationTerms API', type: :request do
  describe 'GET /optimization/terms/:id' do
    before :each do
      @term = create_season_term_with_teacher_and_student(2, 4)
      stub_basic_auth
    end

    it 'スケジュール情報を取得する' do
      get "/optimization/terms/#{@term.id}"
      res_body = JSON.parse(response.body)
      expect(res_body['term']['teacher_group_timetables'].length).to eq(0)
      expect(res_body['term']['student_group_timetables'].length).to eq(0)
      expect(res_body['term']['teacher_optimization_rules'].length).to eq(1)
      expect(res_body['term']['student_optimization_rules'].length).to eq(13)
      expect(res_body['term']['timetables'].length).to eq(84)
      expect(res_body['term']['seats'].length).to eq(588)
      expect(res_body['term']['term_teachers'].length).to eq(2)
      expect(res_body['term']['term_students'].length).to eq(4)
      expect(res_body['term']['term_tutorials'].length).to eq(5)
      expect(res_body['term']['term_groups'].length).to eq(2)
      expect(res_body['term']['teacher_vacancies'].length).to eq(84 * 2)
      expect(res_body['term']['student_vacancies'].length).to eq(84 * 4)
      expect(res_body['term']['tutorial_contracts'].length).to eq(20)
      expect(res_body['term']['tutorial_pieces'].length).to eq(0)
      expect(response.status).to eq(200)
    end
  end

  describe 'PUT /optimization/terms/:id' do
    before :each do
      @term = FactoryBot.create(:spring_term)
      stub_basic_auth
    end

    it 'スケジュール情報が更新される' do
      put "/optimization/terms/#{@term.id}",
          headers: OptimizationTermTestData::RequestHeader.main,
          params: OptimizationTermTestData::RequestBody.update_optimization_term.to_json
      expect(response.status).to eq(204)
    end
  end
end
