class RelationshipsController < ApplicationController
  before_action :signed_in_user, only: [:create, :destroy] 

  def create
    @user = User.find(params[:relationship][:followed_id]) 
    current_user.follow!(@user)
    flash[:success] = "successfully follow #{@user.name}"
    redirect_to @user
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    flash[:success] = "successfully unfollow #{@user.name}"
    redirect_to @user
  end
end