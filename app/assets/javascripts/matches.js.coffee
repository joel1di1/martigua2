# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $('.form_datetime.pick_datetime').datetimepicker({format: 'yyyy-mm-dd hh:ii'});
  $('.form_datetime.pick_date').datetimepicker({format: 'yyyy-mm-dd'});
