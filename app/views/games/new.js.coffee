$('#ajax-modal-1').on 'shown.bs.modal', ->
  $(this).find("[autofocus]:first").focus();
  return
$('#ajax-modal-1 .am-title').html '<%= j (t :new) + Game.model_name.human %>'
$('#ajax-modal-1 .am-errors').html ''
$('#ajax-modal-1 .am-body').html '<%= j render partial: "form" %>'
$('#ajax-modal-1').modal 'show'
