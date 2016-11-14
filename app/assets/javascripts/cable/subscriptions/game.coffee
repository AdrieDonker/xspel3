# jQuery(document).on 'turbolinks:load', ->
  # game_data = $('#game_data')
  # # console.log 'game_data.length: ' + game_data.length.toString()
  # console.log 'game_data game_id: ' + game_data.attr('data-game_id')
  # if game_data.length > 0

    # App.game = App.cable.subscriptions.create channel: "GamesChannel",
    # App.game = App.cable.subscriptions.create {
    #     channel: "GamesChannel",
    #     game: game_data.attr('data-game_id')
    #   },
# gamer_user_id = ""
App.game = App.cable.subscriptions.create "GamesChannel",

  connected: ->
    console.log 'connected'
    # Called when the subscription is ready for use on the server

  disconnected: ->
    console.log 'disconnected'
    # Called when the subscription has been terminated by the server

  received: (data) ->
    game_data = $('#game_data')

    console.log 'received data for game: ' + data.game_id
    console.log 'actual game is: ' + game_data.attr('data-game_id')

    # in the game
    if game_data.attr('data-game_id') == data.game_id
      
      if data.board?
        console.log 'upd_board'
        @letters2board data.board
      
      if data.gamers?
        console.log 'upd_gamers'
        console.log 'game started_at: ' + game_data.attr 'data-game_started_at'
        $('#gamers').html data.gamers
        
        # check/run turn timer
        turn_timer()
      
      if data.shelf?
        console.log 'upd_shelf'
        console.log 'data.gamer_user_id:' + data.gamer_user_id
        console.log 'user_id:' + user_id 
        if data.gamer_user_id == user_id
          console.log 'upd_shelf'
          @letters2shelf data.shelf
          
      # Set buttons
      init_buttons()
      $('#ajax-modal-1').modal 'hide'
    
    # all the games
    # else if $('#all_game_id_' +  data.game_id)
      
    # other page
    else
      console.log 'upd_nothing'
      
  letters2board: (letters) ->
    @to_board letter for letter in letters
    game_resize()

  to_board: (ltr) ->
    console.log 'ltr= ' + ltr.join '-'
    pos = $('#board_pos_' + ltr[0] + '_' + ltr[1])
    
    # remove letters from board if in use as laid_letters
    if pos.children() # and game_data.attr('data-user_id') != user_id
      board_ltr = $(pos.children().first())
      # console.log 'board_ltr: ' + board_ltr
      to_shelf board_ltr
    new_ltr = '<div class="letter">' + ltr[2] + '<div class="points">' + ltr[3] + '</div></div>'
    pos.html(new_ltr)
    
  letters2shelf: (letters) ->
    @to_shelf ltr, letter for letter, ltr in letters
    if letters.length < 7
      @to_shelf num for num in [letters.length..6]
    game_resize_shelf()
    
  to_shelf: (idx, ltr) ->
    pos = $('#play_letters_pos_' + idx)
    # console.log 'idx: ' + idx
    # console.log 'ltr: ' + ltr
    if ltr?
      letter = if ltr[0] == '?' then ' ' else ltr[0]
      new_ltr = '<div class="play_letter"' + ' id="letter_' + idx + 
        '" data-letter="' + letter + '" data-points="' + ltr[1] + '" draggable="true">' + letter +
        '<div class="play_points">' + ltr[1] + '</div></div>'
    else
      new_ltr = ''
    pos.html(new_ltr)
  
@turn_timer = ->
  console.log 'turn_timer started at: ' + new Date()
  gamer = $('.gamer_details[data-turn_state="play"]')
  # console.log 'gamer: '  + JSON.stringify(gamer)
  
  # there is a gamer in play
  if gamer.length > 0
    seq_nbr = gamer.attr 'data-turn_sequence_nbr'
    turn_started = gamer.attr 'data-turn_started'
    play_seconds = $('#game_data').attr 'data-game_play_time'
    gone_seconds = (Date.now() - parseInt(turn_started)) / 1000
    rest_perc = 100 - (100 * gone_seconds / play_seconds)
    done = 100 - rest_perc
    time_lane = $('#timer')
    time_lane.css 'width', '0%'
    step = 0.1
  
    if done > 0 and done < 100
      timing = setInterval (->
        time_lane.css 'width', done.toString() + '%'
        done += step
    
        # end at 100% 
        if done >= 100
          clearInterval timing
          console.log 'turn_timer ended(100) at: ' + new Date()
          $.get 'turns/' + gamer.attr('data-turn_id') + '/too_late', {js_time: Date.now()}, null, 'script'

        # or next_turn started (seq-nr changed)
        if $('.gamer_details[data-turn_state="play"]').attr('data-turn_sequence_nbr') != seq_nbr
          clearInterval timing
          console.log 'new seq nbr: ' + $('.gamer_details[data-turn_state="play"]').attr('data-turn_sequence_nbr')
          console.log 'turn_timer ended(next) at: ' + new Date()

      ), (play_seconds*10)*step     # this is <step> %
      
