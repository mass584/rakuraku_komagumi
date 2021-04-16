import $ from 'jquery';

$.ajaxSetup({
  headers: { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

$(() => $('[id^=select_term_teacher_id]').on('change', (event) => onChangeSelectTutorialContract(event)));
$(() => $('[id^=select_piece_count]').on('change', (event) => onChangeSelectTutorialContract(event)));
$(() => $('[id^=button_delete]').on('click', (event) => onClickDelete(event)));
$(() => $('[id^=select_is_contracted]').on('change', (event) => onChangeSelectGroupContract(event)));

const onChangeSelectTutorialContract = (event) => {
  const tdElement = $(event.target).parent().parent().parent();
  const tdInnerElement = $(event.target).parent().parent();
  const selectWrapperElement = $(event.target).parent();
  const selectTermTeacherIdElement = selectWrapperElement.children('[id^=select_term_teacher_id]');
  const selectPieceCountElement = selectWrapperElement.children('[id^=select_piece_count]');
  const tutorialContractId = Number(tdInnerElement.data('id'));
  const termTeacherId = Number(tdInnerElement.data('term_teacher_id'));
  const newTermTeacherId = Number(selectTermTeacherIdElement.val());
  const pieceCount = Number(tdInnerElement.data('piece_count'));
  const newPieceCount = Number(selectPieceCountElement.val());
  $.ajax({
    type: 'put',
    url: `/tutorial_contracts/${tutorialContractId}`,
    data: JSON.stringify({
      tutorial_contract: {
        term_teacher_id: newTermTeacherId === 0 ? null : newTermTeacherId,
        piece_count: newPieceCount,
      },
    }),
    contentType: 'application/json',
  }).done(() => {
    tdInnerElement.data('term_teacher_id', newTermTeacherId);
    tdInnerElement.data('piece_count', newPieceCount);
    if ( newPieceCount === 0 && newTermTeacherId === 0 ) {
      tdElement.removeClass('bg-warning');
    } else {
      tdElement.addClass('bg-warning');
    }
  }).fail(({ responseJSON }) => {
    selectTermTeacherIdElement.val(termTeacherId);
    selectPieceCountElement.val(pieceCount);
    alert(responseJSON.message);
  });
}

const onChangeSelectGroupContract = (event) => {
  const tdElement = $(event.target).parent().parent().parent();
  const tdInnerElement = $(event.target).parent().parent();
  const selectElement = $(event.target);
  const groupContractId = Number(tdInnerElement.data('id'));
  const isContracted = tdInnerElement.data('is_contracted') === 'true';
  const newIsContracted = selectElement.val() === 'true';
  $.ajax({
    type: 'put',
    url: `/group_contracts/${groupContractId}`,
    data: JSON.stringify({
      group_contract: {
        is_contracted: newIsContracted,
      },
    }),
    contentType: 'application/json',
  }).done(() => {
    tdInnerElement.data('is_contracted', newIsContracted);
    if ( newIsContracted ) {
      tdElement.addClass('bg-warning');
    } else {
      tdElement.removeClass('bg-warning');
    }
  }).fail(({ responseJSON }) => {
    selectElement.val(isContracted);
    alert(responseJSON.message);
  });
}

const onClickDelete = (event) => {
  if (!window.confirm('削除してよろしいですか。')) return;
  const tdElement = $(event.target).parent().parent().parent();
  const tdInnerElement = $(event.target).parent().parent();
  const selectWrapperElement = tdInnerElement.children(':first');
  const selectPieceCountElement = selectWrapperElement.children('[id^=select_piece_count]');
  const selectTermTeacherIdElement = selectWrapperElement.children('[id^=select_term_teacher_id]');
  const tutorialContractId = Number(tdInnerElement.data('id'));
  $.ajax({
    url: `/tutorial_contracts/${tutorialContractId}`,
    type: 'put',
    data: JSON.stringify({
      tutorial_contract: {
        term_teacher_id: null,
        piece_count: 0,
      },
    }),
    contentType: 'application/json',
  }).done(() => {
    tdInnerElement.data('term_teacher_id', null);
    tdInnerElement.data('piece_count', 0);
    selectTermTeacherIdElement.val(null);
    selectPieceCountElement.val(0);
    tdElement.removeClass('bg-warning');
  }).fail(({ responseJSON }) => {
    alert(responseJSON.message);
  });
}
