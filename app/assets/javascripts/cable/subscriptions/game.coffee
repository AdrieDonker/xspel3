jQuery(document).on 'turbolinks:load', ->
  game_data = $('#game_data')
  # console.log 'game_data.length: ' + game_data.length.toString()
  # console.log 'game_data game_id: ' + game_data.data('game_id')
  if game_data.length > 0

    App.game = App.cable.subscriptions.create channel: "GamesChannel",
    
      # App.game = App.cable.subscriptions.create "GameChannel",
      connected: ->
        # alert 'connected'
        # Called when the subscription is ready for use on the server
    
      disconnected: ->
        # alert 'disconnected'
        # Called when the subscription has been terminated by the server
    
      received: (data) ->
        if game_data.data('game_id') == data.game_id
          
          if data.board != undefined
            console.log 'upd_board'
            @letters2board data.board
          
          if data.gamers != undefined
            console.log 'upd_gamers'
            $('#gamers').html data.gamers
          
          if data.shelf != undefined
            console.log 'upd_shelf'
            @letters2shelf data.shelf
            # $('#shelf').html data.shelf
          
        else
          console.log 'upd_nothing'
          
      letters2board: (letters) ->
        @to_board letter for letter in letters
        game_resize()
  
      to_board: (ltr) ->
        # console.log 'ltr= ' + ltr.join '-'
        pos = $('#board_pos_' + ltr[0] + '_' + ltr[1])
        new_ltr = '<div class="letter">' + ltr[2] + '<div class="points">' + ltr[3] + '</div></div>'
        pos.html(new_ltr)
        
      letters2shelf: (letters) ->
        @to_shelf ltr, letter for letter, ltr in letters
        game_resize_shelf()
        
      to_shelf: (idx, ltr) ->
        console.log 'idx= ' + idx
        console.log 'ltr= ' + ltr
        pos = $('#play_letters_pos_' + idx)
        new_ltr = '<div class="play_letter"' + ' id="letter_' + idx + 
          '" data-letter=' + ltr[0] + '" data-points=' + ltr[1] + '" draggable="true">' + ltr[0] +
          '<div class="play_points">' + ltr[1] + '</div></div>'
        console.log 'new_ltr= ' + new_ltr
        pos.html(new_ltr)
        


