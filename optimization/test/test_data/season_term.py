import datetime
from generate_term_test_data import generate_term_test_data

season_term = generate_term_test_data(
  name='春期講習',
  year=2021,
  term_type=1,
  begin_at=datetime.date(2021, 3, 30),
  end_at=datetime.date(2021, 4, 12),
  period_count=6,
  seat_count=7,
  position_count=2,
  student_count=20,
  teacher_count=5,
  tutorial_count=5,
  group_count=2,
  tutorials=[0, 1, 2],
  group_timetables=[
    [0, 4, 0],
    [4, 4, 0],
    [8, 4, 0],
    [12, 4, 0],
    [0, 5, 1],
    [4, 5, 1],
    [8, 5, 1],
    [12, 5, 1],
  ],
  piece_count=4,
)
