# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OptimizationLogs API', type: :request do
  describe 'PUT /optimization/logs/:id' do
    before :each do
      @optimization_log = FactoryBot.create(:optimization_log)
      stub_basic_auth
    end

    it '最適化ログが更新される' do
      put "/optimization/logs/#{@optimization_log.id}",
          headers: OptimizationLogTestData::RequestHeader.main,
          params: OptimizationLogTestData::RequestBody.update_optimization_log.to_json
      expect(response.status).to eq(204)
    end
  end
end
