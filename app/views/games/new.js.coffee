$('#ajax-modal').on 'shown.bs.modal', ->
  $(this).find("[autofocus]:first").focus();
  return
$('#amTitle').html '<%= j (t :new) + Game.model_name.human %>'
$('#amBody').html '<%= j render partial: "form" %>'
$('#ajax-modal').modal 'show'
# $('#games-list').dropdown 'toggle'
