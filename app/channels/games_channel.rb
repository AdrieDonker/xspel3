# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class GamesChannel < ApplicationCable::Channel
  def subscribed
    # stop_all_streams
    stream_from "game_channel"
    # stream_from "game_#{params['game']}_channel"
    # logger.info 'params: ' + (params['game'].to_s if params)
    # logger.add_tags 'ActionCable', "class gameschannel: #{params['game']}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
