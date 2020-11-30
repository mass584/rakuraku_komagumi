module StudentHelper
  def gender_select
    {
      '不明': 'unknown',
      '男': 'male',
      '女': 'female',
    }
  end

  def school_grade_select
    {
      '不明': 'unknown',
      '小1': 'e1',
      '小2': 'e2',
      '小3': 'e3',
      '小4': 'e4',
      '小5': 'e5',
      '小6': 'e6',
      '中1': 'j1',
      '中2': 'j2',
      '中3': 'j3',
      '高1': 'h1',
      '高2': 'h2',
      '高3': 'h3',
    }
  end
end
