$(document).ready(() => {
  let hsize = $(window).height() - $('.header').height() - $('.subheader').height() - $('.footer').height();
  if (hsize < 650) hsize = 650;
  $('.content').css('height', `${hsize}px`);
});

$(window).resize(() => {
  let hsize = $(window).height() - $('.header').height() - $('.subheader').height() - $('.footer').height();
  if (hsize < 650) hsize = 650;
  $('.content').css('height', `${hsize}px`);
});
