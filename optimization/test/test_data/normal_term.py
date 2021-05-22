from .generate_term_test_data import generate_term_test_data

normal_term = generate_term_test_data(
    term_type='normal',
    begin_at='2021-04-13',
    end_at='2021-07-26',
    period_count=6,
    seat_count=7,
    student_count=20,
    teacher_count=5,
    tutorial_count=5,
    group_count=2,
    tutorials=[0, 1, 2],
    group_timetables=[[1, 4, 0], [1, 5, 1]],
    piece_count=1,
)
