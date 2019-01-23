$(document).on('turbolinks:load', function() {
  $('#switch-teams').click(function(e){
    e.preventDefault();
    visitor_team_id = $('#match_visitor_team_id').children("option:selected").val()
    local_team_id = $('#match_local_team_id').children("option:selected").val()
    $('#match_visitor_team_id').val(local_team_id)
    $('#match_local_team_id').val(visitor_team_id)
  })
})
