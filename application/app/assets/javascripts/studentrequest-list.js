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
    url: `/studentrequest/update_master`,
    type: 'put',
    data: data,
  });
}

load_all = () => {
  let defer = new $.Deferred().resolve();
  $.each(gon.students, (idx, val) => {
    const data = {
      student_id: val.id,
    };
    defer = defer.then(() => {
      return $.ajax({
        url:  'studentrequest/occupation_and_matching',
        type: 'get',
        data: data,
      }).done((res) => {
        render(val.id, res);
      });
    });
  });
  defer;
}

render = (student_id, res) => {
  _renderRequired($(`[id=required-${student_id}]`), res.required);
  _renderOccupation($(`[id=occupation-${student_id}]`), res.occupation);
  _renderMatching($(`[id=matching-${student_id}]`), res.matching);
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
      const rowText = `${curr.teacher_fullname}（授業数${curr.required}コマ/マッチ数${curr.matched}コマ）`;
      return `${prev}${rowText}`;
    }, '');
    item.text(text).addClass('alert');
  }
}
