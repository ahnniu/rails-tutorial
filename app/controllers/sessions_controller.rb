class SessionsController < ApplicationController
  def new
    
  end

  def create
    email = params[:session][:email].downcase
    password = params[:session][:password]
    
    user = User.find_by(email: email)
    if user && user.authenticate(password)
      sign_in user
      redirect_back_or user_path(user)
    else
      flash.now[:error] = 'Invalid email/password cobination'
      render :new
    end

  end

  def destroy
    sign_out
    redirect_to root_path    
  end
  
end
