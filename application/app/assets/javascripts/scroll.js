$(document).ready(() => {
  const height = $(window).height() - 200;
  const width = $(window).width() - 60;
  $('table').fixedTblHdrLftCol({
    scroll: {
      height: height,
      width: width,
    }
  });
});
