class User < ActiveRecord::Base
  enum role: [:user, :vip, :admin]
  has_one :language, primary_key: :locale, foreign_key: :abbreviation
  
  has_many :gamers
  has_many :games, through: :gamers
  
  after_initialize :set_default_role, :if => :new_record?
  validates :name, :email,  presence: true, uniqueness: true

  
  def set_default_role
    self.role ||= :user
  end
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :timeoutable #, :confirmable
end
