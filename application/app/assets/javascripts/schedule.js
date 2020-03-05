$(document).ready(() => {
  $('[id=button_all_lock]').on('click', cbBulkUpdate);
  $('[id=button_all_unlock]').on('click', cbBulkUpdate);
  $('[id=button_all_reset]').on('click', cbBulkReset);
  $('[id=button_koma_select]').on('click', cbButtonKomaSelect);
  $('[id=button_koma_fix]').on('click', cbButtonKomaFix);
  $('[id=button_koma_reset]').on('click', cbButtonKomaReset);
  $('[id^=dragbox]').draggable({
    create: cbDragboxCreate,
    start: cbDragboxStart,
    stop: cbDragboxStop,
    containment: 'body',
    revert: 'invalid',
    scroll: 'false',
    snap: '.ui-widget-header',
    snapMode: 'inner',
    snapTolerance: '0',
    zIndex: 1000,
  });
  $('[id^=dropbox_koma]').droppable({
    drop: cbDropboxDrop,
  });
  $('[id^=dropbox_waiting]').droppable({
    drop: cbDropboxDrop,
  });
  getOccupation();
  const height = $(window).height() - 260;
  const width = $(window).width() - 60;
  $('table').fixedTblHdrLftCol({
    scroll: {
      height: height,
      width: width,
      leftCol: {
        fixedSpan: 3,
      },
    },
  });
});

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

cbDragboxCreate = (event) => {
  const dragbox = $(event.target);
  moveDragboxToInitialPosition(dragbox);
  switch ($(dragbox).data('status')) {
    case 0:
      dragbox.draggable('enable');
      dragbox.addClass('unfixed');
      break;
    case 1:
      dragbox.draggable('disable');
      dragbox.addClass('fixed');
      break;
  }
}

cbDragboxStart = (event) => {
  const dragbox = $(event.target);
  const dropbox = $(event.target).parent();
  const validationType = (() => {
    const isDecided = $(dropbox).attr('id').slice(0, 12) === 'dropbox_koma';
    const willViolate = !studentClassPatternCheck(dropbox, dragbox, 'delete') ||
      !teacherClassPatternCheck(dropbox, dragbox, 'delete');
    if (isDecided && willViolate) {
      return 'addOnlySameDay';
    } else {
      return 'add';
    }
  })();
  $('[id^=dropbox_koma]').each((index, item) => {
    const dropboxIsEmpty = $(item).children().length === 0;
    if ( !dropboxIsEmpty ) {
      $(item).droppable('disable');
      return;
    }
    const requestCheck = $(item).data('studentrequest').find((studentId) => {
      return studentId === dragbox.data('student_id');
    });
    const tanninCheck = $(item).data('teacher_id') === dragbox.data('teacher_id');
    if ( !requestCheck || !tanninCheck ) {
      $(item).addClass('unputtable');
      $(item).droppable('disable');
      return;
    }
    const occupationCheck = (() => {
      const seatId = `#seat_${$(item).data('timetable_id')}`;
      const seatnumber = Number($(seatId).text());
      if (seatnumber > 0) {
        return true;
      }
      const dropboxes_sameseat = `[id^=dropbox_koma_${$(item).data('timetable_id')}_${$(item).data('teacher_id')}]`;
      return $(dropboxes_sameseat).filter((index, item1) => {
        return $(item1).children().length > 0;
      }).length > 0;
    })();
    const doubleBookingCheck = (() => {
      const dropboxes_sametime = `[id^=dropbox_koma_${$(item).data('timetable_id')}]`;
      return $(dropboxes_sametime).filter((index, item1) => {
        return $(item1).children().data('student_id') === dragbox.data('student_id');
      }).length === 0;
    })();
    const teacherPatternCheck = teacherClassPatternCheck($(item), $(event.target), validationType);
    const studentPatternCheck = studentClassPatternCheck($(item), $(event.target), validationType);
    if ( !occupationCheck || !doubleBookingCheck || !teacherPatternCheck || !studentPatternCheck ) {
      $(item).droppable('disable');
    } else {
      $(item).addClass('puttable');
      $(item).droppable('enable');
    }
  });
}

cbDragboxStop = (event) => {
  const dragbox = $(event.target);
  const dropbox = $(event.target).parent();
  const scheduleId = dragbox.data('schedule_id');
  const timetableId = dropbox.data('timetable_id');
  const url = `/schedule/${scheduleId}`;
  const data = {
    timetable_id: timetableId,
  };
  dragbox.data('timetable_id', timetableId);
  $('[id^=dropbox_koma_]').removeClass('puttable');
  $('[id^=dropbox_koma_]').removeClass('unputtable');
  $('[id^=dropbox_koma_]').droppable('enable');
  getOccupation();
  $.ajax({
    url: url,
    type: 'put',
    data: data,
  }).fail((xhr) => {
    alert(xhr.responseJSON.message);
  });
}

cbDropboxDrop = (event, ui) => {
  ui.draggable.appendTo($(event.target));
  ui.draggable.offset($(event.target).offset());
}

getOccupation = () => {
  let occupation = {};
  for (let i in gon.timetables) {
    const key1 = gon.timetables[i].id;
    occupation[key1] = {};
    for (let j in gon.teachers) {
      const key2 = gon.teachers[j].id;
      occupation[key1][key2] = 0;
    }
  }
  $('[id^=dropbox_koma_]').each((index, item) => {
    if ($(item).children().length > 0) {
      occupation[$(item).data('timetable_id')][$(item).data('teacher_id')] = 1;
    }
  });
  $('[id^=seat_]').each((index, item) => {
    const occupationEachTimetable = occupation[$(item).data('id')];
    const occupied = Object.keys(occupationEachTimetable).reduce((accu, key) => {
      return accu + occupationEachTimetable[key];
    }, 0);
    const number = gon.seatnum - occupied;
    $(item).text(number);
  });
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

moveDragboxToInitialPosition = (dragbox) => {
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
