@send_pass = ->
  $.get 'turns/' + turn_id + '/pass', {answer: 'yes', js_time: Date.now()} , null, 'script'
  return 
    
@send_swap_letters = ->
  sl = []
  $('#swap_area div.play_letter').each ->
    if $(this).css('opacity') < 1
      # sl.push [ $(this).attr('data-letter'), $(this).attr('data-points') ]
      sl.push [ $(this).attr('data-letter'), $(this).data('points') ]
      
  $.get 'turns/' + turn_id + '/swap', {letters: sl, answer: 'yes', js_time: Date.now()} , null, 'script'
  return 
  
@set_swap_letters = ->
  # wait till modal shown, to resize
  $('#ajax-modal-1').on 'shown.bs.modal', ->
    elems = $('#swap_area div.play_letter')
    elems.css {
      'width': ($('#controls div.play_letter').css 'width'),
      'height': ($('#controls div.play_letter').css 'height'),
      'line-height': ($('#controls div.play_letter').css 'line-height'),
      'font-size': ($('#controls div.play_letter').css 'font-size'),
    }
    $('#swap_area div.play_points').css 'font-size': $('#controls div.play_points').css 'font-size'
    # and make swappable
    elems.on 'click', ->
      if $(this).css('opacity') == '1'
        $(this).css 'opacity', '.5'
      else
        $(this).css 'opacity', '1'
  return

# Resize letters for swap with blank
@set_swap_blank = ->
  # wait till modal shown, to resize
  $('#ajax-modal-1').on 'shown.bs.modal', ->
    new_size = $('#controls td').cssInt 'width'
    font_size = (new_size * 0.7).toString() + 'px';
    size_new = (new_size-2).toString() + 'px';
    elems = $('#blank_area td')
    elems.css { 'width': size_new, 'height': size_new, 'line-height': size_new, 'font-size': font_size }
    # and make letters selectable
    elems.off('click').on 'click', ->
      swap_blank($(this).text())
  return

# Replace blank with chosen letter
@swap_blank = (letter) ->

  # not chosen or back: back to shelf
  if letter == '' 
    to_shelf(dragged)
  
  # chosen and oke
  else
    pos = $('#game_data').attr 'data-drop_pos'
    $('#' + pos + ' div.play_letter').attr 'data-letter', letter
    $('#' + pos + ' div.play_letter').prepend letter
  $('#ajax-modal-1').modal 'hide'
  return 

# Get letters to swap with blank
@init_swap_blank = (drop_target) ->
  # Save drop positie in #game_data
  console.log 'init_swap_blank'
  $('#game_data').attr 'data-drop_pos', drop_target.attr('id')
  $.get 'turns/' + turn_id + '/blank', '', null, 'script'
  return