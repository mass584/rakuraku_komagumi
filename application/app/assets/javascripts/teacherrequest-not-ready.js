$(document).ready(() => {
  $('[id=button_maru]').on('click', cb_button_maru);
  $('[id=button_batsu]').on('click', cb_button_batsu);
  $('[id=button_maru_day]').on('click', cb_button_maru_day);
  $('[id=button_batsu_day]').on('click', cb_button_batsu_day);
  $('[id=button_maru_all]').on('click', cb_button_maru_all);
  $('[id=button_batsu_all]').on('click', cb_button_batsu_all);
});

cb_button_maru = (event) => {
  const div = $(event.target).parent();
  const button_maru = div.children('#button_maru');
  const button_batsu = div.children('#button_batsu');
  const data = {
    scheduledate: div.data('scheduledate'),
    classnumber: div.data('classnumber'),
    teacher_id: div.data('teacher_id'),
  };
  $.ajax({
    url: '/teacherrequest/delete',
    type: 'delete',
    data: data,
  }).done(() => {
    button_maru.css('display', 'none');
    button_batsu.css('display', 'inline');
  }).fail((xhr) => {
    alert(xhr.responseJSON.message);
  });
}

cb_button_batsu = (event) => {
  const div = $(event.target).parent();
  const button_maru = div.children('#button_maru');
  const button_batsu = div.children('#button_batsu');
  const data = {
    scheduledate: div.data('scheduledate'),
    classnumber: div.data('classnumber'),
    teacher_id: div.data('teacher_id'),
  };
  $.ajax({
    url: '/teacherrequest',
    type: 'post',
    data: data,
  }).done(() => {
    button_maru.css('display', 'inline');
    button_batsu.css('display', 'none');
  });
}

cb_button_maru_day = (event) => {
  const div = $(event.target).parent();
  const data = {
    scheduledate: div.data('scheduledate'),
    teacher_id: div.data('teacher_id'),
  };
  return $.ajax({
    url: '/teacherrequest/bulk_create',
    type: 'post',
    data: data,
  }).done(() => {
    $('[id=button_maru]').filter((idx, item) => {
      return $(item).parent().data('scheduledate') === div.data('scheduledate');
    }).css('display', 'inline');
    $('[id=button_batsu]').filter((idx, item) => {
      return $(item).parent().data('scheduledate') === div.data('scheduledate');
  }).css('display', 'none');
  });
}

cb_button_batsu_day = (event) => {
  const div = $(event.target).parent();
  const data = {
    scheduledate: div.data('scheduledate'),
    teacher_id: div.data('teacher_id'),
  };
  return $.ajax({
    url: '/teacherrequest/bulk_delete',
    type: 'delete',
    data: data,
  }).done((ret) => {
    $('[id=button_maru]').filter((idx, item) => {
      return $(item).parent().data('scheduledate') === div.data('scheduledate');
    }).css('display', 'none');
    $('[id=button_batsu]').filter((idx, item) => {
      return $(item).parent().data('scheduledate') === div.data('scheduledate');
    }).css('display', 'inline');
    $.each(ret.fail_list, (idx, val) => {
      $('[id=button_maru]').filter((idx, item) => {
        return $(item).parent().data('scheduledate') === val.scheduledate &&
          $(item).parent().data('classnumber') === val.classnumber;
      }).css('display', 'inline');
      $('[id=button_batsu]').filter((idx, item) => {
        return $(item).parent().data('scheduledate') === val.scheduledate &&
          $(item).parent().data('classnumber') === val.classnumber;
      }).css('display', 'none');
    });
    if (ret.fail_list.length > 0) {
      alert("既に授業が割り当てられている場所は削除できません。");
    }
  });
}

cb_button_maru_all = (event) => {
  const div = $(event.target).parent();
  const data = {
    teacher_id: div.data('teacher_id'),
  };
  return $.ajax({
    url: '/teacherrequest/bulk_create',
    type: 'post',
    data: data,
  }).done(() => {
    $('[id=button_maru]').css('display', 'inline');
    $('[id=button_batsu]').css('display', 'none');
  });
}

cb_button_batsu_all = (event) => {
  const div = $(event.target).parent();
  const data = {
    teacher_id: div.data('teacher_id'),
  };
  return $.ajax({
    url: '/teacherrequest/bulk_delete',
    type: 'delete',
    data: data,
  }).done((ret) => {
    $('[id=button_maru]').css('display', 'none');
    $('[id=button_batsu]').css('display', 'inline');
    $.each(ret.fail_list, (idx, val) => {
      $('[id=button_maru]').filter((idx, item) => {
        return $(item).parent().data('scheduledate') === val.scheduledate &&
          $(item).parent().data('classnumber') === val.classnumber;
      }).css('display', 'inline');
      $('[id=button_batsu]').filter((idx, item) => {
        return $(item).parent().data('scheduledate') === val.scheduledate &&
          $(item).parent().data('classnumber') === val.classnumber;
      }).css('display', 'none');
    });
    if (ret.fail_list.length > 0) {
      alert("既に授業が割り当てられている場所は削除できませんでした。");
    }
  });
}
