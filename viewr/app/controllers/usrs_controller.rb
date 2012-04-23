class UsrsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :authorize_manage, :setup_title

  layout "admin"

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    params[:user][:is_superadmin] = true if params[:user].has_key?(:is_superadmin)
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "User created successfully"
      redirect_to :action => :index
    else
      flash[:error] = "Problems saving: #{@user.errors.to_a.join(", ")}"
      render :action => :new
    end
  end

  def edit
    @user = User.get(params[:id])
  end

  def update
    @user = User.get(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "User's password changed successfully"
      redirect_to :action => :index
    else
      flash[:error] = "Problems saving: #{@user.errors.to_a.join(", ")}"
      render :action => :edit
    end
  end

  def destroy
    @user = User.get(params[:id])
    if @user.destroy
      flash[:notice] = "User deleted successfully."
    else
      flash[:error] = "Could not delete user."
    end
    redirect_to :action => :index
  end

  private

  def authorize_manage
    authorize! :manage, User
  end

  def setup_title
    @title = "User Management"
  end
  
end
