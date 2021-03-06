class User < ActiveRecord::Base
  ratyrate_rater
  ratyrate_rateable "user_review"
  
  has_many :products
  has_many :watchlists
  has_many :productchats, dependent: :destroy
  has_many :chats, through: :productchat

  has_many :buyproducts, through: :productchats, source: :product
  has_many :watchproducts, through: :watchlists, source: :product

  has_many :user_follows, dependent: :destroy
  has_many :follows, through: :user_follows, source: :follow

  has_many :user_reviews, dependent: :destroy
  has_many :reviewers, through: :user_reviews, source: :reviewuser

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]

    def self.from_omniauth(auth)
		where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
			user.email =  auth.info.email
			user.password = Devise.friendly_token[0,20]
			user.name = auth.info.name   # assuming the user model has a name
			user.image = auth.info.image # assuming the user model has an image
		end
	end

	def self.new_with_session(params, session)
		super.tap do |user|
			if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
				user.email = data["email"] if user.email.blank?
			end
		end
	end

	acts_as_messageable

	def mailboxer_name
    	self.name
  	end

  	def mailboxer_email(object)
    	self.email
  	end

end
