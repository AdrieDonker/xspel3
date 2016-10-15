$('#ajax-modal-1 .am-title').html '<%= j (t :play) %>'
$('#ajax-modal-1 .am-errors').html ''
$('#ajax-modal-1 .am-body').html '<%= j render partial: "invite" %>'
$('#ajax-modal-1').modal 'show'
