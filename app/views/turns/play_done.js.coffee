# Update board, shelf, gamers and game-data
$('#controls .shelf').html "<%= j render partial: 'games/shelf' %>"
$('#board .sized').html "<%= j render partial: 'games/board' %>"
$('#gamers').html "<%= j render partial: 'games/gamers' %>"
$('#js_data').html "<%= j render partial: 'games/game_data' %>"
game_resize()
