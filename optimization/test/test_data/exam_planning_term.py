import datetime
from .generate_term_test_data import generate_term_test_data

exam_planning_term = generate_term_test_data(
    name='テスト対策',
    year=2021,
    term_type=2,
    begin_at=datetime.date(2021, 1, 1),
    end_at=datetime.date(2021, 1, 3),
    period_count=4,
    seat_count=7,
    position_count=2,
    student_count=10,
    teacher_count=5,
    tutorial_count=5,
    group_count=2,
    tutorials=[1, 2],
    group_timetables=[[1, 2, 0], [1, 3, 1]],
    piece_count=1,
)
