change_bg = (i) ->
  setTimeout (->
    imgs = [
      "cri.jpg"
      "equipe_royan_2014.jpg"
      "martigua_sam.jpg"
      "martigua_tip.jpg"
      "martigua2_echauffement.jpg"
      "martigua2.jpg"
    ]
    $(".img_bg").fadeTo(1000, 0, ->
      $(this).css "background-image", "url(/assets/home/" + imgs[i % imgs.length] + ")"
    ).fadeTo "slow", 1
    change_bg i + 1
  ), 8000

$(document).ready ->
  change_bg 0  if $(".img_bg").length > 0
