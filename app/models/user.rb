class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # create_table "users", force: :cascade do |t|
  #   t.datetime "created_at", null: false
  #   t.datetime "updated_at", null: false
  #   t.string "email", default: "", null: false
  #   t.string "encrypted_password", default: "", null: false
  #   t.string "reset_password_token"
  #   t.datetime "reset_password_sent_at"
  #   t.datetime "remember_created_at"
  #   t.index ["email"], name: "index_users_on_email", unique: true
  #   t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  # end
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable
  has_many :repos, dependent: :destroy
  has_many :subscribes, dependent: :destroy
  
  def self.from_omniauth(auth)  
    user = find_or_initialize_by(email: auth.info.email)
    unless user.persisted?
      user.provider = auth.provider
      user.uid = auth.uid
      user.password = Devise.friendly_token[0,20]
      user.save
    end
    
    user
  end
end
