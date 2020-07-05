$(document).ready(() => {
  $('[id^=draggable]').draggable({
    start: cbDraggableStart,
    stop: cbDraggableStop,
    containment: 'body',
    revert: 'invalid',
    scroll: 'false',
    snap: '.ui-widget-header',
    snapMode: 'inner',
    snapTolerance: '0',
    zIndex: 1000,
  });
  $('[id^=droppable]').droppable({
    drop: cbDroppableDrop,
  });
});

cbDraggableStart = (event) => {
  const draggable = $(event.target);
  $('[id^=droppable]').forEach((droppable) => {
    const isEmpty = $(droppable).children().length === 0;
    const studentRequestOk = $(droppable).data('students').find((studentId) => {
      return studentId === dragbox.data('student_id');
    });
    const teacherRequestOk = $(droppable).data('teachers').find((teacherId) => {
      return teacherId === dragbox.data('student_id');
    });
    const teacherIdOk = $(droppable).data('teacher_id') === draggable.data('teacher_id');
    const doubleBookingOk = (() => {
      const droppables_at_same_time = $(`[id^=droppable_${$(droppable).data('timetable_id')}]`);
      return !droppables_at_same_time.some((droppable_at_same_time) => {
        return $(droppable_at_same_time).children().data('student_id') === draggable.data('student_id');
      });
    })();
    if ( isEmpty || teacherRequestOk || studentRequestOk || teacherIdOk || doubleBookingOk ) {
      $(droppable).droppable('enable');
    } else {
      $(droppable).droppable('disable');
    }
  });
}

cbDraggableStop = (event) => {
  $('[id^=droppable]').droppable('enable');
  const draggable = $(event.target);
  const droppable = $(event.target).parent();
  const pieceId = draggable.data('piece_id');
  const timetableId = droppable.data('timetable_id');
  $.ajax({
    url: `/piece/${pieceId}`,
    type: 'put',
    data: JSON.stringify({
      timetable_id: timetableId,
    }),
    contentType: 'application/json',
  }).fail((xhr) => {
    alert(xhr.responseJSON.message);
  });
}

cbDroppableDrop = (event, ui) => {
  ui.draggable.appendTo($(event.target));
  ui.draggable.offset($(event.target).offset());
}




cbBulkUpdate = (event) => {
  const id = $(event.target).attr('id');
  const newStatus = (id === 'button_all_lock') ? 1 : 0;
  const url = '/schedule/bulk_update';
  const data = {
    status: newStatus,
  };
  $.ajax({
    url: url,
    type: 'put',
    data: data,
  }).done(() => {
    $('[id^=dragbox_]').filter((idx, item) => {
      return $(item).data('timetable_id') !== 0;
    }).each((idx, item) => {
      $(item).data('status', newStatus);
      switch (newStatus) {
        case 0:
          $(item).addClass('unfixed');
          $(item).removeClass('fixed');
          $(item).draggable('enable');
          break;
        case 1:
          $(item).addClass('fixed');
          $(item).removeClass('unfixed');
          $(item).draggable('disable');
          break;
      }
    })
  });
}

cbBulkReset = () => {
  const url = '/schedule/bulk_reset';
  if (!window.confirm('全ての予定を未決定に戻しますがよろしいですか？')) {
    return;
  }
  $.ajax({
    url: url,
    type: 'put',
  }).done(() => {
    $('[id^=dragbox_]').filter((idx, item) => {
      return $(item).data('timetable_id') !== 0;
    }).each((idx, item) => {
      $(item).data('status', 0);
      $(item).data('timetable_id', 0);
      $(item).addClass('unfixed');
      $(item).removeClass('fixed');
      $(item).draggable('enable');
      $('#background').append($(item));
      addOptionToSelect($(item));
    });
  });
}

cbButtonKomaSelect = (event) => {
  const div = $(event.target).parent();
  const teacherId = div.data('teacher_id');
  const select = div.children('#select_koma');
  const scheduleId = select.val();
  const dragbox = $(`#dragbox_${scheduleId}`);
  const dropbox = $(`#dropbox_waiting_${teacherId}`);
  if (dropbox.children('[id^=dragbox]').length > 0) {
    const dragboxReplace = dropbox.children('[id^=dragbox]');
    dragboxReplace.appendTo('#background');
    addOptionToSelect(dragboxReplace);
  }
  dropbox.append(dragbox);
  removeOptionFromSelect(dragbox);
}

cbButtonKomaFix = (event) => {
  const div = $(event.target).parent().parent();
  const scheduleId = div.data('schedule_id');
  const dragbox = $(`#dragbox_${scheduleId}`);
  const dropbox = dragbox.parent();
  const newStatus = !dragbox.data('status') ? 1 : 0;
  const isWaiting = dropbox.attr('id').slice(0, 15) === 'dropbox_waiting';
  const url = `/schedule/${scheduleId}`;
  const data = {
    status: newStatus,
  };
  if (isWaiting) {
    return;
  }
  $.ajax({
    url: url,
    type: 'put',
    data: data,
  }).done(() => {
    dragbox.data('status', newStatus);
    switch (newStatus) {
      case 0:
        dragbox.addClass('unfixed');
        dragbox.removeClass('fixed');
        dragbox.draggable('enable');
        break;
      case 1:
        dragbox.addClass('fixed');
        dragbox.removeClass('unfixed');
        dragbox.draggable('disable');
        break;
    }
  });
}

cbButtonKomaReset = (event) => {
  const div = $(event.target).parent().parent();
  const scheduleId = div.data('schedule_id');
  const dragbox = $(`#dragbox_${scheduleId}`);
  const dropbox = dragbox.parent();
  const isWaiting = dropbox.attr('id').slice(0, 15) === 'dropbox_waiting';
  const studentPatternCheck = studentClassPatternCheck(dropbox, dragbox, 'delete');
  const teacherPatternCheck = teacherClassPatternCheck(dropbox, dragbox, 'delete');
  const url = `/schedule/${scheduleId}`;
  const data = {
    timetable_id: 0,
    status: 0,
  };
  if (isWaiting) {
    return;
  }
  if (!studentPatternCheck || !teacherPatternCheck) {
    alert('空きコマ違反が発生してしまうため、未決定に戻すことはできません。');
    return;
  }
  if (!window.confirm('予定を未決定に戻しますがよろしいですか？')) {
    return;
  }
  $.ajax({
    url: url,
    type: 'put',
    data: data,
  }).done(() => {
    dragbox.addClass('unfixed');
    dragbox.removeClass('fixed');
    dragbox.draggable('enable');
    dragbox.data('timetable_id', 0);
    $('#background').append(dragbox);
    addOptionToSelect(dragbox);
  });
  return;
}

addOptionToSelect = (dragbox) => {
  const teacherId = dragbox.data('teacher_id');
  const studentId = dragbox.data('student_id');
  const subjectId = dragbox.data('subject_id');
  const scheduleId = dragbox.data('schedule_id');
  const student = gon.students.find((student) => {
    return student.id === studentId;
  });
  const subject = gon.subjects.find((subject) => {
    return subject.id === subjectId;
  });
  const target = $('[id=select_koma]').filter((idx, item) => {
    return $(item).parent().data('teacher_id') === teacherId;
  });
  const text = `${student.grade} ${student.fullname} ${subject.name.slice(0, 1)}`;
  target.addClass('candidate-exist');
  target.append($('<option>').html(text).val(scheduleId));
}

removeOptionFromSelect = (dragbox) => {
  const scheduleId = dragbox.data('schedule_id');
  const targetOption = $(`option[value=${scheduleId}]`);
  const targetSelect = targetOption.parent();
  targetOption.remove();
  if (targetSelect.children().length === 1) {
    targetSelect.removeClass('candidate-exist');
  }
}

moveDraggableToInitialPosition = (dragbox) => {
  const teacherId = dragbox.data('teacher_id');
  const timetableId = dragbox.data('timetable_id');
  if (!teacherId || !timetableId) {
    addOptionToSelect(dragbox);
    return false;
  }
  const dropbox0 = `#dropbox_koma_${timetableId}_${teacherId}_0`;
  if ($(dropbox0).children().length === 0) {
    $(dropbox0).append(dragbox);
    return true;
  }
  const dropbox1 = `#dropbox_koma_${timetableId}_${teacherId}_1`;
  if ($(dropbox1).children().length === 0) {
    $(dropbox1).append(dragbox);
    return true;
  }
  addOptionToSelect(dragbox);
  return false;
}

teacherClassPatternCheck = (dropbox, dragbox, type) => {
  const isDecided = dropbox.attr('id').slice(0, 12) === 'dropbox_koma';
  if (!isDecided) return true;
  const teacherId = dropbox.data('teacher_id');
  const timetableId = dropbox.data('timetable_id');
  const timetableIdOld = dragbox.data('timetable_id');
  const studentId = dragbox.data('student_id');
  const subjectId = dragbox.data('subject_id');
  const scheduleId = dragbox.data('schedule_id');
  const scheduledate = gon.timetables.find((timetable) => {
    return timetable.id === timetableId;
  }).scheduledate;
  const scheduledateOld = timetableIdOld ? gon.timetables.find((timetable) => {
    return timetable.id === timetableIdOld;
  }).scheduledate : 0;
  const timetables = gon.timetables.filter((timetable) => {
    return timetable.scheduledate === scheduledate
  });
  const teacherClassMax = gon.teacher_class_max;
  const teacherBlankMax = gon.teacher_blank_max;
  let classBegin = false;
  let totalClass = 0;
  let blankClass = 0;
  let blankClassTmp = 0;
  timetables.sort((a, b) => {
    if(a.classnumber < b.classnumber) return -1;
    if(a.classnumber > b.classnumber) return 1;
    return 0;
  }).forEach((timetable) => {
    const hasChild0 = $(`#dropbox_koma_${timetable.id}_${teacherId}_0`)
      .children(`div[data-schedule_id!=${scheduleId}]`).length > 0;
    const hasChild1 = $(`#dropbox_koma_${timetable.id}_${teacherId}_1`)
      .children(`div[data-schedule_id!=${scheduleId}]`).length > 0;
    const groupExist = gon.teacher_groups.filter((element, index) => {
      return (timetable.status > 0) && (element.teacher_id === teacherId) && (element.subject_id === timetable.status);
    }).length > 0;
    const isCandidate = ( type === 'add' | type === 'addOnlySameDay' ) && (timetable.id === timetableId);
    if (hasChild0 || hasChild1 || groupExist || isCandidate) {
      totalClass += 1;
      if (classBegin) blankClass += blankClassTmp;
      blankClassTmp = 0;
      classBegin = true;
    } else {
      blankClassTmp += 1;
    }
  });
  const hasChild0 = $(`#dropbox_koma_${timetableId}_${teacherId}_0`)
    .children(`div[data-schedule_id!=${scheduleId}]`).length > 0;
  const hasChild1 = $(`#dropbox_koma_${timetableId}_${teacherId}_1`)
    .children(`div[data-schedule_id!=${scheduleId}]`).length > 0;
  const hasBlank = (hasChild0 & !hasChild1) || (!hasChild0 & hasChild1);
  if (type === 'addOnlySameDay' && scheduledate !== scheduledateOld) {
    return false;
  } else if ((totalClass > teacherClassMax) && !hasBlank) {
    return false;
  } else if (blankClass > teacherBlankMax) {
    return false;
  } else {
    return true;
  }
}

studentClassPatternCheck = (dropbox, dragbox, type) => {
  const isDecided = dropbox.attr('id').slice(0, 12) === 'dropbox_koma';
  if (!isDecided) return true;
  const timetableId = dropbox.data('timetable_id');
  const timetableIdOld = dragbox.data('timetable_id');
  const studentId = dragbox.data('student_id');
  const subjectId = dragbox.data('subject_id');
  const scheduleId = dragbox.data('schedule_id');
  const scheduledate = gon.timetables.find((timetable) => {
    return timetable.id === timetableId;
  }).scheduledate;
  const scheduledateOld = timetableIdOld ? gon.timetables.find((timetable) => {
    return timetable.id === timetableIdOld;
  }).scheduledate : null;
  const timetables = gon.timetables.filter(timetable => timetable.scheduledate === scheduledate);
  const thirdGrade = gon.students.find((student) => {
    return student.id === studentId;
  }).grade === '中3';
  const studentClassMax = thirdGrade ? gon.student3g_class_max : gon.student_class_max;
  const studentBlankMax = thirdGrade ? gon.student3g_blank_max : gon.student_blank_max;
  let classBegin = false;
  let totalClass = 0;
  let blankClassTmp = 0;
  let blankClass = 0;
  timetables.sort((a, b) => {
    if(a.classnumber < b.classnumber) return -1;
    if(a.classnumber > b.classnumber) return 1;
    return 0;
  }).forEach((timetable) => {
    const classExist = $(`div[id^=dropbox_koma_][data-timetable_id=${timetable.id}]`)
      .children(`div[data-student_id=${studentId}][data-schedule_id!=${scheduleId}]`).length > 0;
    const groupExist = gon.student_groups.filter((element, index) => {
      return (timetable.status > 0) && (element.student_id === studentId) &&
        (element.subject_id === timetable.status) && (element.number === 1);
    }).length > 0;
    const isCandidate = (type == 'add' || type == 'addOnlySameDay') && (timetable.id === timetableId);
    if (classExist || isCandidate || groupExist) {
      totalClass += 1;
      if (classBegin) blankClass += blankClassTmp;
      blankClassTmp = 0;
      classBegin = true;
    } else {
      blankClassTmp += 1;
    }
  });
  if ( type === 'addOnlySameDay' && scheduledate !== scheduledateOld) {
    return false;
  } else if (totalClass > studentClassMax) {
    return false;
  } else if (blankClass > studentBlankMax) {
    return false;
  } else {
    return true;
  }
}
