# document ready actions
$ ->

  # Make elem with .click-this clickable to data-href
  $(document).on 'click', '.click-this', ->
    window.document.location = $(this).data('href')
    return

  # Load games in play
  # document.addEventListener 'turbolinks:load', ->
  $.ajax(url:"/games").done (html) ->
    $("#games-list").html html
    # return
  return
 