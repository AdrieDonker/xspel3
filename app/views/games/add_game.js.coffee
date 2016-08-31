$('#games-list').prepend "<%= j render partial: 'game', locals: {game: @game} %>"
$('#messages').html "<%= j render partial: 'layouts/messages' %>"
$('#ajax-modal').modal 'hide'