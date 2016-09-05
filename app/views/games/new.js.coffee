$('#ajax-modal').on 'shown.bs.modal', ->
  $(this).find("[autofocus]:first").focus();
  return
$('#am-title').html '<%= j (t :new) + Game.model_name.human %>'
$('#am-errors').html ''
$('#am-body').html '<%= j render partial: "form" %>'
$('#ajax-modal').modal 'show'
