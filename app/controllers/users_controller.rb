class UsersController < ApplicationController
  
  before_filter :require_admin
  
  def index
    @users = User.all
  end
  
  def roles
    @user = User.find(params[:id])
    @roles = Role.find(:all)
  end
  
  #Grant roles to a user
  def grant
    user=User.find(params[:id])
    params[:roles].each_pair do |request_role, value|
      if value.to_i == 1
        unless user.has_role?(request_role.to_s)
          r = Role.find(:first, :conditions=>{:role => request_role.to_s})
          user.roles << r
        end
      else
        if user.has_role?(request_role.to_s)
          remove = user.roles.find(:first, :conditions=>{:role => request_role.to_s})
          user.roles.delete(remove)
        end
      end
    end
    user.save!
    flash[:notice] = "User roles changed"
    redirect_to :action=>'list'
    
  end
  
  def list
    @users = User.find(:all)
  end
  
  def new
    @edituser=User.new
  end
  
  def create
    @edituser=User.new(params[:edituser])
    if params[:password][:password] == params[:password][:verify] then
      @edituser.password=params[:password][:password]
      if @edituser.save then
        flash[:notice]="User created"
        redirect_to :controller=>"users",:action=>"list"
      else
        render :action=>"new"
      end
    else
      flash[:error]="Passwords don't match"
      @edituser.errors.add "Passwords don't match",""
      render :action=>"new"
    end
  end
    
  def show
    @user=User.find(params[:id])
  end
  
  def edit
    @edituser=User.find(params[:id])
  end
  
  def update
    @edituser=User.find(params[:id])
    @edituser.attributes=params[:user]
    unless params[:password][:password].empty? then
      if params[:password][:password] == params[:password][:verify] then
        @edituser.password=params[:password][:password]
      else
        @edituser.errors.add('', "Passwords don't match")
        render :action => 'edit'
        return
      end
    end
    if @edituser.save
      flash[:notice]="User updated"
      redirect_to :action => 'list'
    else
      render :action=>"edit"
    end
  end
  
  private
  
  def require_admin
    unless current_user.has_role?('admin')
      raise ApplicationController::PermissionDenied
    end
  end
    
  
end