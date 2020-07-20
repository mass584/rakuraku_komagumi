$(document).ready(() => {
  $('[id^=piece_]').draggable({
    start: cbDragStart,
    stop: cbDragStop,
    containment: 'body',
    revert: 'invalid',
    scroll: 'false',
    zIndex: 100,
  });
  $('[id^=frame_]').droppable({
    drop: cbDrop,
  });
});

const cbDragStart = (event) => {
  const piece = $(event.target);
  $('[id^=frame_]').each((_idx, frame) => {
    const isEmpty = $(frame).children().length === 0;
    const studentOk = $(frame).parent().data('students').find((studentId) => {
      return _.toNumber(studentId) === piece.data('student_id');
    });
    const teacherOk = $(frame).parent().data('teachers').find((teacherId) => {
      return _.toNumber(teacherId) === piece.data('teacher_id');
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
  const frame = $(event.target).parent();
  const seat = $(event.target).parent().parent();
  $.ajax({
    url: `/piece/${piece.data('piece_id')}`,
    type: 'put',
    data: JSON.stringify({
      piece: {
        timetable_id: seat.data('timetable_id') || null,
      },
    }),
    contentType: 'application/json',
  }).done((data) => {
  }).fail((xhr) => {
    alert(xhr);
  });
}

const cbDrop = (event, ui) => {
  const frame = $(event.target);
  const frameOffset = frame.offset();
  const pieceOffset = {
    top: frameOffset.top + 1,
    left: frameOffset.left + 1,
  };
  ui.draggable.appendTo(frame);
  ui.draggable.offset(pieceOffset);
}

const cb_open_button = (_event) => {
  $(".pool-body").toggleClass("pool-body__closed");
};

const cb_select_student_id = (event) => {
  const studentId = event.target.value;
  const selectSubjectId = $("#select_subject_id");
  selectSubjectId.val('');
  $('#holding').html('');
  gon.subjects.forEach(subject => {
    const disabled = !_.has(gon.pendings, [studentId, subject.id]);
    selectSubjectId.find(`[value=${subject.id}]`).prop('disabled', disabled);
  });
};

const cb_select_subject_id = (event) => {
  const subjectId = event.target.value;
  const selectStudentId = $("#select_student_id");
  const studentId = selectStudentId.val();
  const piece = _.get(gon.pendings, [studentId, subjectId, 0]);
  if (piece) {
    $('#holding').html(`
      <div class="piece" id="piece_${piece.id}" data-piece_id="${piece.id}" data-teacher_id="${piece.teacher_id}" data-student_id="${piece.student_id}" data-subject_id="${piece.subject_id}">
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
