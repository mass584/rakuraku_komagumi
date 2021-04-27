import logging

logger = logging.getLogger('ArrayIndex')

def term_student_index(term_students, term_student_id):
    term_student = term_student for term_student in term_students if term_student['id'] == term_student_id
    return term_students.index(term_student)

def term_teacher_index(term_teachers, term_teacher_id):
    term_teacher = term_teacher for term_teacher in term_teachers if term_teacher['id'] == term_teacher_id
    return term_teachers.index(term_teacher)

def term_tutorial_index(term_tutorials, term_tutorial_id):
    term_tutorial = term_tutorial for term_tutorial in term_tutorials if term_tutorial['id'] == term_tutorial_id
    return term_tutorials.index(term_tutorial)

def term_group_index(term_groups, term_group_id):
    term_group = term_group for term_group in term_groups if term_group['id'] == term_group_id
    return term_groups.index(term_group)

def date_index(date_index)
    return date_index - 1

def period_index(period_index)
    return period_index - 1
