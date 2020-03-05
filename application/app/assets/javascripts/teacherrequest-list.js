$(document).ready(() => {
  $('[id=checkbox_status]').on('click', cb_checkbox_status);
  load_all();
});

cb_checkbox_status = (event) => {
  const checkbox = $(event.target);
  const div = checkbox.parent();
  const id = div.data('id');
  const data = {
    id: id,
    status: checkbox.prop('checked') ? 1 : 0,
  };
  if (checkbox.prop('checked')) {
    checkbox.prop('checked', true);
  } else {
    checkbox.prop('checked', false);
  }
  $.ajax({
    url: `/teacherrequest/update_master`,
    type: 'put',
    data: data,
  });
}

load_all = () => {
  let defer = new $.Deferred().resolve();
  $.each(gon.teachers, (idx, val) => {
    const data = {
      teacher_id: val.id,
    };
    defer = defer.then(() => {
      return $.ajax({
        url:  'teacherrequest/occupation_and_matching',
        type: 'get',
        data: data,
      }).done((res) => {
        render(val.id, res);
      });
    });
  });
  defer;
}

render = (teacher_id, res) => {
  _renderRequired($(`[id=required-${teacher_id}]`), res.required);
  _renderOccupation($(`[id=occupation-${teacher_id}]`), res.occupation);
  _renderMatching($(`[id=matching-${teacher_id}]`), res.matching);
}

_renderRequired = (item, val) => {
  item.text(`${val}コマ`);
}

_renderOccupation = (item, val) => {
  const percent = Math.round(val*100);
  switch(true) {
    case Number(val) === -1:
      item.text('-');
      break;
    case Number(val) < 0.85:
      item.text(`${percent}%`);
      break;
    case Number(val) < 1:
      item.text(`${percent}%`).addClass("alert");
      break;
    default:
      item.text(`${percent}%`).addClass("error");
      break;
  }
}

_renderMatching = (item, val) => {
  if (val.length === 0) {
    item.text('');
  } else {
    const text = val.reduce((prev, curr) => {
      const rowText = `${curr.student_fullname}（授業数${curr.required}コマ/マッチ数${curr.matched}コマ）`;
      return `${prev}${rowText}`;
    }, '');
    item.text(text).addClass('alert');
  }
}
