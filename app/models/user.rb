class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2, :twitter2]

  has_many :events, dependent: :destroy


  def self.from_omniauth(auth)
    # 1. Try to find user by provider and uid
    user = find_by(provider: auth.provider, uid: auth.uid)
    return user if user

    # 2. If not found, try to find by email
    email = auth.info.email
    if email.present?
      user = find_by(email: email)
      if user
        # Update user with new provider info to link the account
        user.update(provider: auth.provider, uid: auth.uid)
        return user
      end
    end

    # 3. If still not found, create a new user
    create do |u|
      u.provider = auth.provider
      u.uid = auth.uid
      u.email = email || "#{auth.uid}-#{auth.provider}@example.com"
      u.password = Devise.friendly_token[0, 20]
      u.name = auth.info.name
    end
  end

  def guest?
    provider == 'guest'
  end

  def email_required?
    provider != 'guest' && super
  end

  def password_required?
    provider != 'guest' && super
  end
end
