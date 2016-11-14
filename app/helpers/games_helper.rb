module GamesHelper
  
  # set path and format for click on all-games page
  def from_all_games_start(game)
    
    remote = true
    if game.startable?
      path = ( game.owner_id == current_user.id ? edit_game_path(game) : game_path(game) )
    elsif game.waits_for_you(current_user)
      gamer = game.gamers.find_by(user_id: current_user.id)
      path = game_gamer_invite_path(game, gamer)
    else
      path = play_game_path(game)
      remote = false
    end
    return path, remote
  end

  # return gamer-names, comma separated
  def gamer_names(game)
    gn = []
    # game.gamers.sort_by(&:sequence_nbr).each do |g|
    game.gamers.order(:sequence_nbr).each do |g|
      gn << g.user.name
    end
    return gn.join(', ')
  end

  # set last line for game in alle-games page
  def current_state(game, cur_user)
    if game.startable?
      game.aasm.human_state + ' ' + (I18n.t :by) +' ' + game.owner.name
    elsif game.in_play?
      last_played(game)
    elsif game.waits_for_you(cur_user)
      I18n.t :waits_for_you
    elsif game.ended?
      result = game.gamers.order(:position).map{ |g| g.position.to_s + '. ' + g.user.name + '(' + g.score.to_s + ')' }
      '<span>' + (I18n.t :result) + ': </span>'+ result.join(', ')
    else
      game.aasm.human_state
    end
  end

  # Return last completed turn
  def last_played(game)
    lp = game.turns.last(2)[0]
    
    # not yet played
    if lp.wait?
      I18n.t :waits_for_play
    
    # played
    elsif lp.played?
      wrds = lp.words.collect{|w| w[0]}.join(', ')
      lp.user.name + ' ' + (I18n.t :played) + ' [' + wrds + ']: ' + 
        lp.score.to_s + ' ' + (I18n.t :points)
    
    #other
    else
      lp.user.name + ': ' + lp.aasm.human_state
    end
  end

  # 
  def gamer_in_play(game)
    if game
      turn = Turn.find_by game_id: game.id, state: 'play'
      turn.nil? ? game.aasm.human_state : turn.user.name + ' ' + t(:plays_now)
    else
      'unknown error'
    end
  end
end
