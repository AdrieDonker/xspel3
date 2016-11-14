class User < ActiveRecord::Base
  enum role: [:user, :vip, :admin]
  has_one :language, primary_key: :locale, foreign_key: :abbreviation
  
  has_many :gamers
  has_many :games, through: :gamers
  
  serialize :knows_users
  
  after_initialize :set_default_role, :if => :new_record?
  validates :name, :email,  presence: true, uniqueness: true

  def set_default_role
    self.role ||= :user
  end
  
  def knows_users_names
    self.knows_users ||= []
    User.find(knows_users).map(&:name).join(', ')
  end
  
  def knows_users_objects
    if role == 'admin'
      User.where("id != #{id}").sort_by(&:name)
    else
      if knows_users
        User.find(knows_users).sort_by(&:name)
      else
        []
      end
    end
  end
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :timeoutable   #, :confirmable
         
  # Allowing Unconfirmed Access
  protected
  # def confirmation_required?
  #   false
  # end
  
  before_create do
    self.knows_users ||= []
  end
end
