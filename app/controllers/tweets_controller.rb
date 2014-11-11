class TweetsController < ApplicationController


  def list 
    zombie = current_user.id   
    @tweet = Tweet.where(zombie_id:current_user.id)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tweet}
    end
  end

  def updatelikes
    @tweet = Tweet.find(params[:id])
    @tweet.likes += 1   
    @tweet.likedby+=current_user.id.to_s()+","    
    @tweet.save
    redirect_to :root
  end

  def updatedislikes
    @tweet = Tweet.find(params[:id])
    @tweet.likes -= 1       
    example = @tweet.likedby
    example = example.gsub(current_user.id.to_s+",","")
    @tweet.likedby = example
    @tweet.save
    redirect_to :root
  end

  def alltweets
    @tweet = Tweet.all
    @compare = true
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tweet}
    end
  end

  def new
    @tweet = Tweet.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tweet}
    end
  end

  def create
    @tweet = Tweet.new(params[:tweet])
    @tweet.zombie_id = current_user.id

    respond_to do |format|
      if @tweet.save
        format.html { redirect_to :root }
        format.json { render json: @tweet, status: :created, location: @tweet }
      else
        format.html { render action: "tweet" }
        format.json { render json: @tweet.errors, status: :unprocessable_entity }
      end
    end
  end

end


