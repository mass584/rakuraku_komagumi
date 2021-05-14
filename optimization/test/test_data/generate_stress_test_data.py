import json


def generate_stress_test_data():
    term_json = open('stress/term.json', 'r')
    timetables_json = open('stress/timetables.json', 'r')
    teacher_optimization_rule_json = open(
        'stress/teacher_optimization_rule.json', 'r')
    student_optimization_rules_json = open(
        'stress/student_optimization_rules.json', 'r')
    term_teachers_json = open('stress/term_teachers.json', 'r')
    term_students_json = open('stress/term_students.json', 'r')
    term_tutorials_json = open('stress/term_tutorials.json', 'r')
    term_groups_json = open('stress/term_groups.json', 'r')
    teacher_vacancies_json = open('stress/teacher_vacancies.json', 'r')
    student_vacancies_json = open('stress/student_vacancies.json', 'r')
    tutorial_contracts_json = open('stress/tutorial_contracts.json', 'r')
    tutorial_pieces_json = open('stress/tutorial_pieces.json', 'r')
    teacher_group_timetables_json = open(
        'stress/teacher_group_timetables.json', 'r')
    student_group_timetables_json = open(
        'stress/student_group_timetables.json', 'r')
    seats_json = open('stress/seats.json', 'r')

    return {
        'term': json.load(term_json),
        'timetables': json.load(timetables_json),
        'teacher_optimization_rule': json.load(teacher_optimization_rule_json),
        'student_optimization_rules': json.load(student_optimization_rules_json),
        'term_teachers': json.load(term_teachers_json),
        'term_students': json.load(term_students_json),
        'term_tutorials': json.load(term_tutorials_json),
        'term_groups': json.load(term_groups_json),
        'student_vacancies': json.load(student_vacancies_json),
        'teacher_vacancies': json.load(teacher_vacancies_json),
        'tutorial_contracts': json.load(tutorial_contracts_json),
        'tutorial_pieces': json.load(tutorial_pieces_json),
        'teacher_group_timetables': json.load(teacher_group_timetables_json),
        'student_group_timetables': json.load(student_group_timetables_json),
        'seats': json.load(seats_json),
    }
