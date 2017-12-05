$(document).on('turbolinks:load', function() {
  var closeButton = document.getElementById('starburst-close');
  if (closeButton !== null) {
    closeButton.addEventListener('click', function() {
      document.getElementById('starburst-announcement').style.display = 'none';
    });
  }
});
