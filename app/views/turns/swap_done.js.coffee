# Update the shelf
$('#controls .shelf').html "<%= j render partial: 'games/shelf' %>"
$('#ajax-modal-1').modal 'hide'
game_resize_shelf()