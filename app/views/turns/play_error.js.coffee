$('#ajax-modal-1 .am-title').html '<%= j (t :illegal) %>'
$('#ajax-modal-1 .am-errors').html ''
$('#ajax-modal-1 .am-body').html '<%= j render partial: "play_error" %>'
$('#ajax-modal-1').modal 'show'
