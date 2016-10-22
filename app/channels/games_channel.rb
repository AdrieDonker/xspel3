# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class GamesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_channel"
    # stream_from "games_#{params['game_id']}_channel"
    # logger.info 'stream from: ' + "games_#{params['game_id']}_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
