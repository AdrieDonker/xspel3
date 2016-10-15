$('#ajax-modal-1 .am-title').html '<%= j (t :pass) %>'
$('#ajax-modal-1 .am-errors').html ''
$('#ajax-modal-1 .am-body').html '<%= j render partial: "pass" %>'
$('#ajax-modal-1').modal 'show'
