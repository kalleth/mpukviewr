class User

  include DataMapper::Resource
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable

  ## Database authenticatable
  property :username,              String, :required => true, :default => "", :length => 255
  property :encrypted_password,    String, :required => true, :default => "", :length => 255

  ## Rememberable
  property :remember_created_at, DateTime

  ## Trackable
  property :sign_in_count,      Integer, :default => 0
  property :current_sign_in_at, DateTime
  property :last_sign_in_at,    DateTime
  property :current_sign_in_ip, String
  property :last_sign_in_ip,    String

  property :id,                 Serial
  property :is_superadmin,      Boolean

  def email_required?
    false
  end

end
