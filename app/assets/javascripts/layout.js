$( document ).ready(function() {
  if ($(".alert-success").length > 0){
    window.setTimeout(function() { $(".alert-success").slideToggle('slow'); }, 3000);
  }
});

$(document).ready(function() {
    $('[data-toggle=tooltip]').tooltip();
}); 