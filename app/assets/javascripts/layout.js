$(document).on('turbolinks:load', function() {
  $('[data-toggle="tooltip"]').tooltip();

  if ($(".alert-success").length > 0){
    window.setTimeout(function() { $(".alert-success").slideToggle('slow'); }, 3000);
  }

  jQuery(".best_in_place").best_in_place();
  $('.best_in_place').bind("ajax:success", function () { $(this).effect('highlight'); } );

  $.datepicker.setDefaults( $.datepicker.regional[ "fr" ] );
  $( "input.datepicker" ).datepicker();
});
