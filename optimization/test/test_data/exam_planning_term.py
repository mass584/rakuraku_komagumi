from .generate_term_test_data import generate_term_test_data

exam_planning_term = generate_term_test_data(
    term_type='exam_planning',
    begin_at="2021-01-01",
    end_at="2021-01-03",
    period_count=4,
    seat_count=7,
    student_count=10,
    teacher_count=5,
    tutorial_count=5,
    group_count=2,
    tutorials=[1, 2],
    group_timetables=[[1, 2, 0], [1, 3, 1]],
    piece_count=1,
)
