module ApplicationCable
  class Connection < ActionCable::Connection::Base
    # identified_by :current_user
 
    # def connect
    #   self.current_user = find_verified_user
    #   logger.add_tags 'ActionCable', current_user.email
    # end
 
    # protected
    #   def find_verified_user
    #     # if current_user = User.find_by(id: cookies.signed[:user_id])
    #     if verified_user = env['warden'].user

    #       current_user
    #     else
    #       reject_unauthorized_connection
    #     end
    #   end
    # identified_by :uuid

    def connect
      # logger.add_tags 'ActionCable', "module ApplCable: #{params.to_s}"
      # logger.add_tags 'ActionCable', "module ApplCable: #{@game.id}"
      # self.uuid = SecureRandom.uuid
      # self.uuid = @game.id
    end
  end
end
