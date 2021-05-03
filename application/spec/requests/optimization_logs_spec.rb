# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OptimizationLogs API', type: :request do
  describe 'POST /optimization_log' do
    before :each do
      @term = FactoryBot.create(:spring_term)
      stub_basic_auth
    end

    it '最適化ログが作成される' do
      post '/optimization_logs',
           headers: OptimizationLogTestData::RequestHeader.main,
           params: OptimizationLogTestData::RequestBody.create_optimization_log(@term.id).to_json
      res_body = JSON.parse(response.body)
      expect(response.status).to eq(201)
      expect(res_body).to eq(OptimizationLogTestData::ResponseBody.create_optimization_log(res_body['optimization_log']))
    end
  end

  describe 'PUT /optimization_log' do
    before :each do
      @optimization_log = FactoryBot.create(:optimization_log)
      stub_basic_auth
    end

    it '最適化ログが更新される' do
      put "/optimization_logs/#{@optimization_log.id}",
          headers: OptimizationLogTestData::RequestHeader.main,
          params: OptimizationLogTestData::RequestBody.update_optimization_log.to_json
      res_body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(res_body).to eq(OptimizationLogTestData::ResponseBody.update_optimization_log(res_body['optimization_log']))
    end
  end
end
