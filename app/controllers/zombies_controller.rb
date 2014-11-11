class ZombiesController < ApplicationController
  # GET /zombies
  # GET /zombies.json
  def index
    @zombies = Zombie.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @zombies }
    end
  end

  def listing
    @zombies = Zombie.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @zombies }
    end
  end
 
  def signin
    @zombie = Zombie.new
  end

  def signedout
    zombie = Zombie.find_by_id(session[:zombie_id])

    if zombie
      update_authentication_token(zombie, nil)
      zombie.save
      session[:zombie_id] = nil      
      redirect_to :root
    else
      redirect_to :signin
    end
  end

  def login
    username_or_email = params[:zombie][:username]
    password = params[:zombie][:password]

    if username_or_email.rindex('@')
      email=username_or_email
      zombie = Zombie.authenticate_by_email(email, password)
    else
      username=username_or_email
      zombie = Zombie.authenticate_by_username(username, password)
    end

    if zombie      
      update_authentication_token(zombie, params[:zombie][:remember_me])
      zombie.save
      session[:zombie_id] = zombie.id
      flash[:notice] = 'Welcome.'
      redirect_to :root
    else
      render :action => "signin"
    end
  end

  # GET /zombies/1
  # GET /zombies/1.json
  def show
    @zombie = Zombie.find(params[:id])
    example = @zombie.following
    example = example[0,example.length-1]
    @tweet = Tweet.where("zombie_id in (#{example})")
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @zombie }
    end
  end


  # GET /zombies/new
  # GET /zombies/new.json
  def new
    @zombie = Zombie.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @zombie }
    end
  end

  # GET /zombies/1/edit
  def edit
    @zombie = Zombie.find(params[:id])
  end

  # POST /zombies
  # POST /zombies.json
  def create
    @zombie = Zombie.new(params[:zombie])

    respond_to do |format|
      if @zombie.save
        # ZombieMailer.welcome_email(@zombie).deliver
        session[:zombie_id] = @zombie.id
        format.html { redirect_to @zombie, notice: 'Zombie was successfully created.' }
        format.json { render json: @zombie, status: :created, location: @zombie }
      else
        format.html { render action: "new" }
        format.json { render json: @zombie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /zombies/1
  # PUT /zombies/1.json
  def update
    @zombie = Zombie.find(params[:id])

    respond_to do |format|
      if @zombie.update_attributes(params[:zombie])
        format.html { redirect_to @zombie, notice: 'Zombie was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @zombie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /zombies/1
  # DELETE /zombies/1.json
  def destroy
    @zombie = Zombie.find(params[:id])
    @zombie.destroy

    respond_to do |format|
      format.html { redirect_to zombies_url }
      format.json { head :ok }
    end
  end
  
  def following
    example = params[:id]
    @zombie = current_user
    @zombie.following+=example.to_s()+","
    @zombie.save 
    redirect_to :root
  end

  def unfollowing
    example = params[:id]
    @zombie = current_user
    @zombie.following = @zombie.following.gsub(example.to_s()+",","")
    @zombie.save
    redirect_to :root
  end

# HTTP get
def forgot_password
  @zombie = Zombie.new
end

# HTTP put
def send_password_reset_instructions
  username_or_email = params[:zombie][:username]

  if username_or_email.rindex('@')
    zombie = Zombie.find_by_email(username_or_email)
  else
    zombie = Zombie.find_by_username(username_or_email)
  end

  if zombie
    zombie.password_reset_token = SecureRandom.urlsafe_base64
    zombie.password_expires_after = 24.hours.from_now
    zombie.save
    ZombieMailer.reset_password_email(zombie).deliver
    #flash[:notice] = 'Password instructions have been mailed to you. Please check your inbox.'
    redirect_to :signin
  else
    @zombie = Zombie.new
    # put the previous value back.
    @zombie.username = params[:zombie][:username]
    @zombie.errors[:username] = 'is not a registered user.'
    render :action => "forgot_password"
  end
end


def password_reset
  token = params.first[0]
  @zombie = Zombie.find_by_password_reset_token(token)

  if @zombie.nil?
    flash[:error] = 'You have not requested a password reset.'
    redirect_to :root
    return
  end

  if @zombie.password_expires_after < DateTime.now
    clear_password_reset(@zombie)
    @zombie.save
    flash[:error] = 'Password reset has expired. Please request a new password reset.'
    redirect_to :forgot_password
  end
end

def new_password
  username = params[:zombie][:username]
  @zombie = Zombie.find_by_username(username)

  if verify_new_password(params[:zombie])
    @zombie.update_attributes(params[:zombie])
    @zombie.password = @zombie.new_password

    if @zombie.valid?
      clear_password_reset(@zombie)
      @zombie.save
      flash[:notice] = 'Your password has been reset. Please sign in with your new password.'
      redirect_to :signin
    else
      render :action => "password_reset"
    end
  else
    @zombie.errors[:new_password] = 'Cannot be blank and must match the password verification.'
    render :action => "password_reset"
  end
end

private

	def clear_password_reset(zombie)
 	 zombie.password_expires_after = nil
  	zombie.password_reset_token = nil
	end

  def verify_new_password(passwords)
    result = true

    if passwords[:new_password].blank? || (passwords[:new_password] != passwords[:new_password_confirmation])
      result = false
    end

    result
  end

  def update_authentication_token(zombie, remember_me)
    if remember_me == 1
      # create an authentication token if the user has clicked on remember me
      auth_token = SecureRandom.urlsafe_base64
      zombie.authentication_token = auth_token
      cookies.permanent[:auth_token] = auth_token
    else              # nil or 0
      # if not, clear the token, as the user doesn't want to be remembered.
      zombie.authentication_token = nil
      cookies.permanent[:auth_token] = nil
    end
  end


end
