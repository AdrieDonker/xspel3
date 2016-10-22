module GamersHelper
  
  # def current_gamer #(game)
  #   Gamer.find_by game_id: @game.id, user_id: current_user.id
  # end
  
  def game_gamers(game)
    gg = []
    game.gamers.order(:sequence_nbr).each do |g|
      ps = play_state(game, g)
      gg << {
        # gamer_details:  'data-gamer_id="' + g.id.to_s +
        #                 '" data-user_id="' + g.user_id.to_s + '"',
        gamer_id:       g.id,
        user_id:        g.user_id,
        user_name:      g.user.name,
        play_state:     ps[0],    
        turn_details:   ps[1],       # always the last turn
        score:          g.score.to_s
      }
    end
    logger.info 'gg=' + gg.to_s
    return gg
  end
  
  def play_state(game, gamer)
    ret = []
    if game.in_play?
      if gamer.in_turn?
        ret[0] = gamer.aasm.human_state
        ret[1] = ''
      else
        turn = Turn.where(game_id: gamer.game_id, user_id: gamer.user_id).last(2)
        # 2 records then play_state is last turn
        if turn.size == 2
          ret[0] = turn[0].aasm.human_state + ': ' + turn[0].score.to_s
          turn_det = turn[1]
        # else use the only one
        else
          ret[0] = turn[0].aasm.human_state
          turn_det = turn[0]
          ret[1] = turn[0].state
        end
        ret[1] = [turn_det.id, turn_det.state]
      end
    else
      ret[0] = gamer.aasm.human_state
      ret[1] = ''
    end
    return ret
  end
  

end
