class UsrsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :authorize_manage

  def index
    @users = User.all
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def authorize_manage
    authorize! :manage, User
  end
  
end
