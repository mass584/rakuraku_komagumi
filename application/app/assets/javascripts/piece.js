var srcSeat = null;

$(document).ready(() => {
  $('[id^=piece_]').draggable({
    start: cbDragStart,
    stop: cbDragStop,
    revert: 'invalid',
    zIndex: 50,
  });
  $('[id^=frame_]').droppable({
    drop: cbDrop,
  });
});

const cbDragStart = (event) => {
  const piece = $(event.target);
  const seat = $(event.target).parent().parent();
  srcSeat = seat;
  $('[id^=frame_]').each((_idx, frame) => {
    const isEmpty = $(frame).children().length === 0;
    const studentOk = $(frame).parent().data('students').find((studentId) => {
      return _.toNumber(studentId) === piece.data('student_term_id');
    });
    const teacherOk = $(frame).parent().data('teachers').find((teacherId) => {
      return _.toNumber(teacherId) === piece.data('teacher_term_id');
    });
    if ( studentOk && teacherOk && isEmpty ) {
      $(frame).droppable('enable');
    } else {
      $(frame).droppable('disable');
    }
  });
}

const cbDragStop = (event, ui) => {
  $('[id^=frame_]').droppable('disable');
  const piece = $(event.target);
  const seat = $(event.target).parent().parent();
  const seatTeacher = seat.children().first();
  const seatTeacherSrc = srcSeat.children().first();
  $.ajax({
    url: `/piece/${piece.data('piece_id')}`,
    type: 'put',
    data: JSON.stringify({
      piece: {
        seat_id: seat.data('seat_id'),
      },
    }),
    contentType: 'application/json',
  }).done((_res) => {
    seatTeacher.text(piece.data('teacher_name'));
    seatTeacher.data('teacher_term_id', piece.data('teacher_term_id'));
    const srcSeatHasPiece = srcSeat.children('[id^=frame_]').toArray().reduce((accu, item) => {
      return $(item).children().length ? accu + 1 : accu;
    }, 0) > 0;
    if (!srcSeatHasPiece) {
      seatTeacherSrc.text('');
      seatTeacherSrc.data('teacher_term_id', '');
    }
  }).fail((xhr) => {
    alert(xhr);
  });
}

const cbDrop = (event, ui) => {
  const frame = $(event.target);
  const piece = ui.draggable;
  const frameOffset = frame.offset();
  piece.appendTo(frame);
  piece.offset({
    top: frameOffset.top + 1,
    left: frameOffset.left + 1,
  });
}

const cb_open_button = (_event) => {
  $(".pool-body").toggleClass("pool-body__closed");
};

const cb_select_student_term_id = (event) => {
  const studentTermId = event.target.value;
  const select = $("#select_subject_term_id");
  select.val('');
  $('#holding').html('');
  gon.subject_terms.forEach(subjectTerm => {
    const disabled = !_.has(gon.pendings, [studentTermId, subjectTerm.id]);
    select.find(`[value=${subjectTerm.id}]`).prop('disabled', disabled);
  });
};

const cb_select_subject_term_id = (event) => {
  const subjectTermId = event.target.value;
  const selectStudentTermId = $("#select_student_term_id");
  const studentTermId = selectStudentTermId.val();
  const piece = _.get(gon.pendings, [studentTermId, subjectTermId, 0]);
  if (piece) {
    $('#holding').html(`
      <div class="piece" id="piece_${piece.id}" data-piece_id="${piece.id}" data-teacher_term_id="${piece.teacher_term_id}" data-teacher_name="${piece.teacher_name}" data-student_term_id="${piece.student_term_id}" data-student_name="${piece.student_name}" data-subject_term_id="${piece.subject_term_id} data-subject_name="${piece.subject_name}">
        ${piece.student_name} ${piece.subject_name}
      </div>
    `);
    $(`#piece_${piece.id}`).draggable({
      start: cbDragStart,
      stop: cbDragStop,
      containment: 'body',
      revert: 'invalid',
      scroll: 'false',
      zIndex: 100,
    });
  } else {
    $('#holding').html('');
  }
};
