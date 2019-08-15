$(document).on('turbolinks:load', function() {
  $(".auto-submit").on("click", function (){
    $(this).closest('form').submit();
  });
})
