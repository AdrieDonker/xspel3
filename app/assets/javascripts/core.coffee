# document ready actions
$ ->
  # Make elem with .click-this clickable to data-href
  $(document).on 'click', '.click-this', ->
    window.document.location = $(this).data('href')
    return
  board_resize()
  return

# document all loads
$(document).on 'turbolinks:load', ->
  board_resize()

  # keep the board sqaure 
  $(window).resize ->
    board_resize()
    return
    
  return
  
# make the board squared
board_resize = ->
  $('#board table').css 'height', $('#board table').css('width')
  return

# select_picker = ->
#   $('.selectpicker').each ->
#     $selectpicker = $(this)
#     Plugin.call $selectpicker, $selectpicker.data()
#   return
  