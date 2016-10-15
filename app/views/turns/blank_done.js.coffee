
$('#ajax-modal-1 .am-title').html '<%= j (t :exchange_blank) %>'
$('#ajax-modal-1 .am-errors').html ''
$('#ajax-modal-1 .am-body').html '<%= j render partial: "blank" %>'
$('#ajax-modal-1').modal 'show'
set_swap_blank()

