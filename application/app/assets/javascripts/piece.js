$(document).ready(() => {
  $('[id^=piece_]').draggable({
    start: cbDragStart,
    stop: cbDragStop,
    containment: 'body',
    revert: 'invalid',
    scroll: 'false',
    snap: '.ui-widget-header',
    snapMode: 'inner',
    snapTolerance: '0',
    zIndex: 1000,
  });
  $('[id^=frame_]').droppable({
    drop: cbDrop,
  });
});

cbDragStart = (event) => {
  const piece = $(event.target);
  $('[id^=frame_]').each((_idx, frame) => {
    const isEmpty = $(frame).children().length === 0;
    const studentOk = $(frame).parent().data('students').find((studentId) => {
      return studentId === piece.data('student_id');
    });
    const teacherOk = $(frame).parent().data('teachers').find((teacherId) => {
      return teacherId === piece.data('teacher_id');
    });
    if ( isEmpty && teacherOk && studentOk ) {
      $(frame).droppable('enable');
    } else {
      $(frame).droppable('disable');
    }
  });
}

cbDragStop = (event) => {
  $('[id^=frame_]').droppable('disable');
  const piece = $(event.target);
  const frame = $(event.target).parent();
  $.ajax({
    url: `/piece/${piece.data('piece_id')}`,
    type: 'put',
    data: JSON.stringify({
      piece: {
        timetable_id: frame.data('timetable_id'),
      },
    }),
    contentType: 'application/json',
  }).fail((xhr) => {
    alert(xhr);
  });
}

cbDrop = (event, ui) => {
  ui.draggable.appendTo($(event.target));
  ui.draggable.offset($(event.target).offset());
}
