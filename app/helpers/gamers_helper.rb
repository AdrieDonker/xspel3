module GamersHelper
  
  # def current_gamer #(game)
  #   Gamer.find_by game_id: @game.id, user_id: current_user.id
  # end
  
  def game_gamers(game)
    gg = []
    game.gamers.order(:sequence_nbr).each do |g|    # where.not(sequence_nbr: 0).
      t_d = turn_details(game, g)
      gg << {
        gamer_id:         g.id,
        user_id:          g.user_id,
        dsp_user_name:    (game.ended? ? g.position.to_s + '. ' : '') + g.user.name,
        dsp_play_state:   t_d[0],        
        dsp_score:        g.score.to_s,
        turn_id:          t_d[1],        # always the last turn
        turn_state:       t_d[2],
        turn_started:     t_d[3],          # miliseconds from js via js_time
        turn_sequence_nbr: t_d[4]
      }
    end
    # logger.info 'gg=' + gg.to_s
    gg.sort_by!{ |hsh| hsh[:dsp_user_name] } if game.ended?
    return gg
  end
  
  # collect details
  def turn_details(game, gamer)
    ret = []
    
    # waiting to start
    if game.playable?
      turn = Turn.where(game_id: game.id, user_id: gamer.user_id).order(:sequence_nbr).last
      
      if turn
        ret[0] = turn.aasm.human_state
        ret[1] = turn.id
        ret[2] = turn.state
        ret[3] = turn.started.to_f * 1000 # to milliseconds
        ret[4] = turn.sequence_nbr
      
      # not yet reacted on invite
      else
        ret[0] = gamer.aasm.human_state
        ret[1] = 0
        ret[2] = ''
        ret[3] = ''
        ret[4] = ''
        
      end
      
    # in play now
    elsif game.in_play?
      turn = Turn.where(game_id: game.id, user_id: gamer.user_id).order(:sequence_nbr).last(2)

      # gamer has a turn
      if turn.size > 0
        
        # if gamer.in_turn?
        #   ret[0] = gamer.aasm.human_state
        # else
  
          # 2 records then actual play_state is last turn
          # previous [0] is to display last played turn
          if turn.size == 2
            ret[0] = turn[0].aasm.human_state + ': ' + turn[0].score.to_s
  
          # else use the only one (start of game)
          else
            ret[0] = turn[0].aasm.human_state
          end
        # end
        ret[1] = turn.last.id
        ret[2] = turn.last.state
        ret[3] = turn.last.started.to_f * 1000 # to milliseconds
        ret[4] = turn.last.sequence_nbr
      
      # gamer without turns
      else
        ret[0] = gamer.aasm.human_state
        ret[1] = 0
        ret[2] = ''
        ret[3] = '' 
        ret[4] = ''
        
      end
    
    # ended normally
    elsif game.ended?
      
      # played-out gamer
      if gamer.played_out?
        turn = Turn.where(game_id: game.id, user_id: gamer.user_id).order(:sequence_nbr).last(2)
        ret[0] = gamer.aasm.human_state + ': ' + turn[0].score.to_s # dsp_play_state
        ret[1] = turn[0].id                                         # turn_id
        ret[2] = turn[0].state
        ret[3] = turn[0].started.to_f * 1000 # to milliseconds
        ret[4] = turn[0].sequence_nbr
        
      else
        turn = Turn.where(game_id: game.id, user_id: gamer.user_id).order(:sequence_nbr).last
        if turn
          ret[0] = turn.score
          ret[1] = turn.id
          ret[2] = turn.state
          ret[3] = turn.started.to_f * 1000 # to milliseconds
          ret[4] = turn.sequence_nbr
          
        # not played gamer
        else
          ret[0] = gamer.aasm.human_state
          ret[1] = 0
          ret[2] = ''
          ret[3] = ''
          ret[4] = ''
        end
      end
    
    # ended not normal
    end
    return ret
  end

end
