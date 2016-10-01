# document ready actions
$ ->
  # Make elem with .click-this clickable to data-href
  $(document).on 'click', '.click-this', ->
    window.document.location = $(this).data('href')
    return
  return

# document all loads
$(document).on 'turbolinks:load', ->
  board_resize()
  # controls_resize()
  return

# window resize corrections 
$(window).resize ->
  board_resize()
  # controls_resize()
  return
  
# make the board squared and adjust shelf
board_resize = ->
  
  # the board
  td_width = Math.floor(($('#board .sized').cssInt('width') - 16) / 15)
  td_size = td_width.toString() + 'px'
  $('#board table td').css({'width': td_size, 'height': td_size})
  
  # letters on the board
  tile_size = (td_width - 2).toString() + 'px';
  letter_size = (td_width * .7).toString() + 'px'
  $('#board div.play_letter').css {
    'height': tile_size,
    'width': tile_size, 
    'line-height': tile_size
    'font-size': letter_size
  }
  points_size = (td_width * 0.3).toString() + 'px'
  $('#board div.play_points').css 'font-size', points_size

  # the shelf
  td_width = Math.floor(($('#controls .shelf').cssInt('width') - 12) / 7 )
  td_size = td_width.toString() + 'px'
  $('#controls table td').css {'width': td_size, 'height': td_size}

  # letters on the shelf
  tile_size = (td_width - 2).toString() + 'px';
  letter_size = (td_width * .7).toString() + 'px'
  $('#controls div.play_letter').css {
    'height': tile_size,
    'width': tile_size, 
    'line-height': tile_size
    'font-size': letter_size
  }
  points_size = (td_width * 0.3).toString() + 'px'
  $('#controls div.play_points').css 'font-size', points_size
  
  # play buttons
  # line_size = letter_size = (td_width * .7).toString() + 'px'
  $('#controls .play_btn').css {
    'height': tile_size, 
    'line-height': letter_size,
    'font-size': letter_size
  }
  return

# extend jQuery's css to nums
jQuery.fn.cssInt = (prop) ->
  parseInt(@css(prop), 10) or 0

jQuery.fn.cssFloat = (prop) ->
  parseFloat(@css(prop)) or 0
