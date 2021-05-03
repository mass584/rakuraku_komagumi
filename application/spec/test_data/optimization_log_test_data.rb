module OptimizationLogTestData
  module RequestHeader
    module_function

    def main
      {
        'Content-Type' => 'application/json',
      }
    end
  end

  module RequestBody
    module_function

    def create_optimization_log(term_id)
      {
        'optimization_log' => {
          'term_id' => term_id,
        },
      }
    end

    def update_optimization_log
      {
        'optimization_log' => {
          'installation_progress' => 10,
          'swapping_progress' => 10,
          'deletion_progress' => 10,
          'exit_status' => 1,
          'exit_message' => 'message',
        },
      }
    end
  end

  module ResponseBody
    module_function

    def create_optimization_log(res_body)
      {
        'optimization_log' => {
          'id' => res_body['id'],
          'term_id' => res_body['term_id'],
          'sequence_number' => 1,
          'installation_progress' => 0,
          'swapping_progress' => 0,
          'deletion_progress' => 0,
          'exit_status' => 'in_progress',
          'exit_message' => nil,
          'end_at' => nil,
          'created_at' => res_body['created_at'],
          'updated_at' => res_body['updated_at'],
        },
      }
    end

    def update_optimization_log(res_body)
      {
        'optimization_log' => {
          'id' => res_body['id'],
          'term_id' => res_body['term_id'],
          'sequence_number' => 1,
          'installation_progress' => 10,
          'swapping_progress' => 10,
          'deletion_progress' => 10,
          'exit_status' => 'succeed',
          'exit_message' => 'message',
          'end_at' => res_body['end_at'],
          'created_at' => res_body['created_at'],
          'updated_at' => res_body['updated_at'],
        },
      }
    end
  end
end