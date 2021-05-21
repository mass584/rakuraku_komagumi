module OptimizationTermTestData
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

    def update_optimization_term
      {
        'term' => {
          'seats' => [],
          'tutorial_pieces' => [],
        },
      }
    end
  end
end
