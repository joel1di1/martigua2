$(document).on('turbolinks:load', function() {
  $( "input.newday-psd" ).datepicker({
    onSelect: function() {
      var day_name = $('#day_name');
      var format_date = $.datepicker.formatDate( 'dd M', $(this).datepicker( "getDate" ) );
      var default_value = day_name.data('default-name') + ' - ' + format_date;
      day_name.val(default_value);
    }
  });
});


