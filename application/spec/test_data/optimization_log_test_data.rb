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
end
