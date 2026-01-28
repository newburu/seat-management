class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2, :twitter2]

  has_many :events, dependent: :destroy


  def email_required?
    provider != 'guest' && super
  end

  def password_required?
    provider != 'guest' && super
  end
end
