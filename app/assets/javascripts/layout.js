$( document ).ready(function() {
  if ($(".alert-success").length > 0){
    window.setTimeout(function() { $(".alert-success").slideToggle('slow'); }, 3000);
  }
});


$(document).on('turbolinks:load', function() {
  $('[data-toggle="tooltip"]').tooltip();
});

$(document).ready(function() {
  /* Activating Best In Place */
  jQuery(".best_in_place").best_in_place();
});