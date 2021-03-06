# ISK - A web controllable slideshow system
#
# Author::		Vesa-Pekka Palmu
# Copyright:: Copyright (c) 2012-2013 Vesa-Pekka Palmu
# License::		Licensed under GPL v3, see LICENSE.md


class GroupsController < ApplicationController
	before_filter :require_create, :only => [:new, :create]
	before_filter :require_admin, :only => [:publish_all, :hide_all]
	
	def index
		@groups = MasterGroup.current.defined_groups.all
		@new_group = MasterGroup.new
	end
	
	def show
		@group = MasterGroup.find(params[:id])
	end
	
	def edit
		@group = MasterGroup.find(params[:id])
		
		if @group.internal
			#Do not allow editing of internal groups
			flash[:error] = "Can't edit internal groups"
			redirect_to group_path(@group) and return
		end
		require_edit @group
			
	end
	
	def update
		@group =MasterGroup.find(params[:id])

		if @group.internal
			#Do not allow editing of internal groups
			flash[:error] = "Can't edit internal groups"
			redirect_to group_path(@group) and return
		end


		require_edit @group
		
		if @group.is_a? PrizeGroup
			data = Array.new
			params[:data].each_key do |k|
				data << {
					:name => params[:data][k][:name], 
					:by => params[:data][k][:by],
					:pts => params[:data][k][:pts]
				}
			end
			@group.data = data
		end
		
		
		if @group.update_attributes(params[:master_group])
			flash[:notice] = 'Group was successfully updated.'
			redirect_to :action => 'show', :id => @group.id
		else
			render :action => 'edit'
		end
		
	end
	
	#Set all slides in the groups to public
	def publish_all
		@group = MasterGroup.find(params[:id])
		@group.publish_slides
		redirect_to :action => :show, :id => @group.id
	end
	
	#Hide all slides in the group
	def hide_all
		@group = MasterGroup.find(params[:id])
		@group.hide_slides
		redirect_to :action => :show, :id => @group.id
	end
	
	#Change the order of slides in the group, used with jquerry sortable widget.
	def sort
		MasterGroup.transaction do
			group = MasterGroup.find(params[:id])
			require_edit group
			if params[:slide].count == group.slides.count
				MasterGroup.transaction do
					group.slides.each do |slide|
						slide.position = params['slide'].index(slide.id.to_s) + 1
						slide.save
					end
				end
				group.reload
				@group = group
				respond_to do |format|
					format.js {render :sortable_items}
				end
			else
				render :text => "Invalid slide count, try refreshing", :status => 400
			end
		end
	end

	#Delete a group, all contained slides will become ungrouped
	def destroy
		@group = MasterGroup.find(params[:id])
		require_edit @group
		@group.destroy
		
		redirect_to :action => :index
	end
	
	#Add multiple slides to group, render the selection form for all ungrouped slides
	def add_slides
		@group = MasterGroup.find(params[:id])
		require_edit @group
		
		@slides = current_event.ungrouped.slides.current.all
	end
	
	#Add multiple slides to group
	def adopt_slides
		@group = MasterGroup.find(params[:id])
		require_edit @group
		MasterGroup.transaction do
			notice = String.new 
			params[:slides].each_value do |s|
				if s[:add] == "1"
					s = current_event.ungrouped.slides.find(s[:id])
					flash[:notice]
					notice << 'Adding slide ' << s.name << "\n"
					s.master_group_id = @group.id
					s.save!
				end
			end
			flash[:notice] = notice
		end
		
		redirect_to :action => :show, :id => @group.id
	end
	
	def new
		@group = MasterGroup.new
	end
	
	# FIXME: move creation logic to models
	def create
		if params[:prize]
			#Create new prize ceremony group
			@group = PrizeGroup.new(params[:master_group])
			@group.event = current_event
			data = Array.new
			params[:data].each_key do |k|
				data << {
					:name => params[:data][k][:name], 
					:by => params[:data][k][:by],
					:pts => params[:data][k][:pts]
				}
			end
			@group.data = data
			
			
		else
			@group = MasterGroup.new(params[:master_group])
			@group.event = current_event
		end
		if @group.save
			flash[:notice] = "Group created."
			@group.authorized_users << current_user unless MasterGroup.admin? current_user
			redirect_to :action => :show, :id => @group.id
		else
			flash[:error] = "Error saving group"
			render :new and return
		end 
			
	end
	
	def deny
		group = MasterGroup.find(params[:id])
		user = User.find(params[:user_id])
		group.authorized_users.delete(user)
		redirect_to :back
	end
	
	def grant
		group = MasterGroup.find(params[:id])
		user = User.find(params[:grant][:user_id])
		group.authorized_users << user
		redirect_to :back		 
	end
	
	#Add all slides on this group to override on a display
	def add_to_override
		group = MasterGroup.find(params[:id])
		display = Display.find(params[:override][:display_id])
		duration = params[:override][:duration].to_i
		
		if display.can_override?(current_user)
			group.slides.each do |s|
				display.add_to_override(s, duration)
			end
			flash[:notice] = "Added group " + group.name + " to override on display " + display.name
		else
			flash[:error] = "You can't add slides to the override queue on display " + display.name
		end
		redirect_to :action => :show, :id => group.id
		
	end
	
	private
	
	def require_create
		raise ApplicationController::PermissionDenied unless MasterGroup.can_create?(current_user)
	end
		
	def require_admin
		raise ApplicationController::PermissionDenied unless MasterGroup.admin?(current_user)
	end
	
end
