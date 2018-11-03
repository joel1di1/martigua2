jQuery.fn.selectText = function(){
    var doc = document;
    var element = this[0];
    var range, selection;
    if (doc.body.createTextRange) {
        range = document.body.createTextRange();
        range.moveToElementText(element);
        range.select();
    } else if (window.getSelection) {
        selection = window.getSelection();
        range = document.createRange();
        range.selectNodeContents(element);
        selection.removeAllRanges();
        selection.addRange(range);
    }
};

$(document).on('turbolinks:load', function(){
  $("#mail-compo").click(function() {
    $('#mail-compo').selectText();
  });

  $('.player-draggable').draggable({
    revert: true,
    revertDuration: 200,
    zIndex: 100,
  });

  $('.team-droppable').droppable({
    activate: function(event, ui) {},
    drop: function( event, ui ) {
        let playerId = ui.draggable.data('player_id');
        let matchId = $(this).data('match_id');
        let teamId = $(this).data('team_id');
        console.log(playerId);
        console.log(matchId);
        console.log(teamId);

        $('form#mtp-' + matchId + '-' + teamId + '-' + playerId).submit();
    },
  });
});