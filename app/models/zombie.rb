class Zombie < ActiveRecord::Base
    attr_accessible :email, :username, :password, :password_confirmation, :age, :bio, :new_password, :new_password_confirmation, :remember_me, :rotting, :gravatarurl
  attr_accessor :password, :new_password, :remember_me
  
  has_many :tweets, dependent: :destroy

  # scope variables
  scope :rotting, where(rotting:true)
  scope :fresh, where("age < 20")
  scope :recent, where("created_at desc")

  # All validations and encryption procedures.
  before_save :encrypt_password
  before_save :make_rotting
  before_save :gravatar_url

  validates_confirmation_of :password
  validates_presence_of :password, :on => :create

  validates_presence_of :email, :on => :create
  validates_uniqueness_of :email

  validates_presence_of :username, :on => :create
  validates_uniqueness_of :username

  validates_presence_of :age, :on => :create

  validates_presence_of :bio, :on => :create



  validates_confirmation_of :new_password, :if => Proc.new {|zombie| !zombie.new_password.nil? && !zombie.new_password.empty? }

  def make_rotting
    if age > 20
      self.rotting = true
    else
      self.rotting = false
      true
    end
  end

  def gravatar_url
    stripped_email = self.email.strip
    downcased_email = stripped_email.downcase
    hash = Digest::MD5.hexdigest(downcased_email)
    self.gravatarurl = "http://gravatar.com/avatar/#{hash}"    
  end


  def self.authenticate_by_email(email, password)
    zombie = find_by_email(email)
    if zombie && zombie.password_hash == BCrypt::Engine.hash_secret(password, zombie.password_salt)
      zombie
    else
      nil
    end
  end

  def self.authenticate_by_username(username, password)
    zombie = find_by_username(username)
    if zombie && zombie.password_hash == BCrypt::Engine.hash_secret(password, zombie.password_salt)
      zombie
    else
      nil
    end
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
end
