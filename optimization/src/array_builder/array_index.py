def get_student_index(term_students, term_student_id):
    term_student = next(
        term_student for term_student in term_students
        if term_student['id'] == term_student_id)
    return term_students.index(term_student)


def get_teacher_index(term_teachers, term_teacher_id):
    term_teacher = next(
        term_teacher for term_teacher in term_teachers
        if term_teacher['id'] == term_teacher_id)
    return term_teachers.index(term_teacher)


def get_tutorial_index(term_tutorials, term_tutorial_id):
    term_tutorial = next(
        term_tutorial for term_tutorial in term_tutorials
        if term_tutorial['id'] == term_tutorial_id)
    return term_tutorials.index(term_tutorial)


def get_group_index(term_groups, term_group_id):
    term_group = next(
        term_group for term_group in term_groups
        if term_group['id'] == term_group_id)
    return term_groups.index(term_group)


def get_date_index(date_index):
    return date_index - 1


def get_period_index(period_index):
    return period_index - 1
