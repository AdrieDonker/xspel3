$('#ajax-modal-1 .am-title').html '<%= j Game.model_name.human + ' ' + @game.id.to_s %>'
$('#ajax-modal-1 .am-errors').html ''
$('#ajax-modal-1 .am-body').html '<%= j render partial: "show" %>'
$('#ajax-modal-1').modal 'show'
