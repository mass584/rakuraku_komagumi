import datetime
import itertools

begin_at = datetime.date(2021, 3, 22)
end_at = datetime.date(2021, 4, 11)
date_count = (end_at - begin_at).days + 1
period_count = 6
seat_count = 7
position_count = 2
student_count = 20
teacher_count = 5
tutorial_count = 5
group_count = 2

group_timetables = [
  [0, 5, 0],
  [4, 5, 0],
  [8, 5, 0],
  [12, 5, 0],
  [0, 5, 1],
  [4, 5, 1],
  [8, 5, 1],
  [12, 5, 1],
]

term = {
  'id': 1,
  'name': '春期講習',
  'year': 2021,
  'term_type': 1,
  'begin_at': begin_at,
  'end_at': end_at,
  'period_count': period_count,
  'seat_count': seat_count,
  'position_count': position_count,
}

teacher_optimization_rule = {
  'single_cost': 100,
  'different_pair_cost': 15,
  'occupation_limit': 6,
  'occupation_costs': [0, 30, 18, 3, 0, 6, 24],
  'blank_limit': 1,
  'blank_costs': [0, 30],
}

student_optimization_rules = [
  {
    'school_grade': school_grade,
    'occupation_limit': 3,
    'occupation_costs': [0, 0, 14, 70],
    'blank_limit': 1,
    'blank_costs': [0, 70],
    'interval_cutoff': 2,
    'interval_costs': [70, 35, 14],
  }
  for school_grade
  in [11, 12, 13, 14, 15, 16, 21, 22, 23, 31, 32, 33, 99]
]

term_teachers = [
  {
    'id': teacher_index + 1,
    'name': f"講師{teacher_index + 1}",
    'vacancy_status': 2
  }
  for teacher_index in range(teacher_count)
]

term_students = [
  {
    'id': student_index + 1,
    'name': f"生徒{student_index + 1}",
    'school_grade': 23,
    'vacancy_status': 2
  }
  for student_index in range(student_count)
]

term_tutorials = [
  {
    'id': tutorial_index + 1,
    'name': f'個別{tutorial_index + 1}'
  }
  for tutorial_index in range(tutorial_count)
]

term_groups = [
  {
    'id': group_index + 1,
    'name': f'集団{group_index + 1}'
  }
  for group_index in range(group_count)
]

student_vacancies = [
  {
    'date_index': date_index + 1,
    'period_index': period_index + 1,
    'student_term_id': student_index + 1,
    'is_vacant': True,
  }
  for student_index, date_index, period_index
  in itertools.product(range(student_count), range(date_count), range(period_count))
]

teacher_vacancies = [
  {
    'date_index': date_index + 1,
    'period_index': period_index + 1,
    'teacher_term_id': teacher_index + 1,
    'is_vacant': True,
  }
  for teacher_index, date_index, period_index
  in itertools.product(range(teacher_count), range(date_count), range(period_count))
]

tutorial_contracts = [
  {
    'term_student_id': student_index + 1,
    'term_tutorial_id': tutorial_index + 1,
    'term_teacher_id': (student_index * tutorial_count + tutorial_index) % teacher_count + 1,
    'piece_count': 4 if tutorial_index in [0, 1, 2] else 0,
  }
  for student_index, tutorial_index
  in itertools.product(range(student_count), range(tutorial_count))
]

tutorial_pieces = list(itertools.chain.from_iterable([
  [
    {
      'date_index': None,
      'period_index': None,
      'term_student_id': tutorial_contract['term_student_id'],
      'term_tutorial_id': tutorial_contract['term_tutorial_id'],
      'term_teacher_id': tutorial_contract['term_teacher_id'],
      'is_fixed': False,
    }
    for sequence in range(tutorial_contract['piece_count'])
  ]
  for tutorial_contract in tutorial_contracts
]))

teacher_group_timetables = [
  {
    'date_index': date_index + 1,
    'period_index': period_index + 1,
    'term_group_id': group_index + 1,
    'term_teacher_id': teacher_index + 1,
  }
  for [date_index, period_index, group_index], teacher_index
  in itertools.product(group_timetables, range(teacher_count))
]

student_group_timetables = [
  {
    'date_index': date_index + 1,
    'period_index': period_index + 1,
    'term_group_id': group_index + 1,
    'term_student_id': student_index + 1,
  }
  for [date_index, period_index, group_index], student_index
  in itertools.product(group_timetables, range(student_count))
]

seats = [
  {
    'id': date_index * (period_count * seat_count) + period_index * (seat_count) + seat_index + 1,
    'date_index': date_index + 1,
    'period_index': period_index + 1,
    'seat_index': seat_index + 1,
    'term_teacher_id': None,
    'position_count': position_count,
  }
  for date_index, period_index, seat_index
  in itertools.product(range(date_count), range(period_count), range(seat_count))
]
