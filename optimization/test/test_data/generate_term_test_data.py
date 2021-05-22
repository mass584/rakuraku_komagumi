import datetime
import itertools


def generate_term_test_data(
    term_type,
    begin_at,
    end_at,
    period_count,
    seat_count,
    student_count,
    teacher_count,
    tutorial_count,
    group_count,
    tutorials,
    group_timetables,
    piece_count,
):
    begin_at_datetime = datetime.datetime.strptime(begin_at, '%Y-%m-%d')
    end_at_datetime = datetime.datetime.strptime(end_at, '%Y-%m-%d')
    date_count = 7 if term_type == 0 else (
        end_at_datetime - begin_at_datetime).days + 1
    term = {
        'term_type': term_type,
        'date_count': date_count,
        'period_count': period_count,
        'seat_count': seat_count,
        'begin_at': begin_at,
        'end_at': end_at,
    }
    timetables = [
        {
            'date_index': date_index + 1,
            'period_index': period_index + 1,
            'term_group_id': next((
                item[2] for item in group_timetables
                if item[0] == date_index and item[1] == period_index), None),
            'is_closed': False,
        }
        for date_index, period_index
        in itertools.product(range(date_count), range(period_count))
    ]
    seats = [
        {
            'id': date_index * (period_count * seat_count) +
            period_index * (seat_count) + seat_index + 1,
            'date_index': date_index + 1,
            'period_index': period_index + 1,
            'seat_index': seat_index + 1,
            'term_teacher_id': None,
        }
        for date_index, period_index, seat_index
        in itertools.product(
            range(date_count), range(period_count), range(seat_count))
    ]
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
        in ['e1', 'e2', 'e3', 'e4', 'e5', 'e6', 'j1', 'j2', 'j3', 'h1', 'h2', 'h3', 'other']
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
            'school_grade': 'j3',
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
            'term_student_id': student_index + 1,
            'is_vacant': True,
        }
        for student_index, date_index, period_index
        in itertools.product(
            range(student_count), range(date_count), range(period_count))
    ]
    teacher_vacancies = [
        {
            'date_index': date_index + 1,
            'period_index': period_index + 1,
            'term_teacher_id': teacher_index + 1,
            'is_vacant': True,
        }
        for teacher_index, date_index, period_index
        in itertools.product(
            range(teacher_count), range(date_count), range(period_count))
    ]
    tutorial_contracts = [
        {
            'term_student_id': student_index + 1,
            'term_tutorial_id': tutorial_index + 1,
            'term_teacher_id':
                (student_index * tutorial_count +
                 tutorial_index) % teacher_count + 1,
            'piece_count': piece_count if tutorial_index in tutorials else 0,
        }
        for student_index, tutorial_index
        in itertools.product(range(student_count), range(tutorial_count))
    ]
    tutorial_pieces = list(itertools.chain.from_iterable([
        [
            {
                'id': (tutorial_contract['term_student_id'] - 1) * tutorial_count * tutorial_contract['piece_count']
                + (tutorial_contract['term_tutorial_id'] - 1) * tutorial_contract['piece_count']
                + piece_number + 1,
                'seat_id': None,
                'date_index': None,
                'period_index': None,
                'term_student_id': tutorial_contract['term_student_id'],
                'term_tutorial_id': tutorial_contract['term_tutorial_id'],
                'term_teacher_id': tutorial_contract['term_teacher_id'],
                'is_fixed': False,
            }
            for piece_number in range(tutorial_contract['piece_count'])
        ]
        for tutorial_contract in tutorial_contracts
    ]))
    teacher_group_timetables = [
        {
            'date_index': date_index + 1,
            'period_index': period_index + 1,
            'term_group_id': group_index + 1,
            'term_teacher_id': 1,
        }
        for date_index, period_index, group_index
        in group_timetables
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
    return {
        'term': term,
        'timetables': timetables,
        'seats': seats,
        'teacher_optimization_rules': [teacher_optimization_rule],
        'student_optimization_rules': student_optimization_rules,
        'term_teachers': term_teachers,
        'term_students': term_students,
        'term_tutorials': term_tutorials,
        'term_groups': term_groups,
        'student_vacancies': student_vacancies,
        'teacher_vacancies': teacher_vacancies,
        'tutorial_contracts': tutorial_contracts,
        'tutorial_pieces': tutorial_pieces,
        'teacher_group_timetables': teacher_group_timetables,
        'student_group_timetables': student_group_timetables,
    }
