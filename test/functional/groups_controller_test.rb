require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
	def setup
		@adminsession = {user_id: users(:admin).id, username: users(:admin).username}
		@update_data = {
			id: master_groups(:ten_slides).id,
			master_group: {
				name: "I have been updated"
			}
		}
		@create_data = {
			master_group: {
				name: "New test group"
			}
		}
		#We don't want to generate slides into the normal place
		Slide.send(:remove_const, :FilePath)
		Slide.const_set(:FilePath, Rails.root.join('tmp','test'))
	end
	
	test "get index" do
		get :index, nil, @adminsession
		
		assert_response :success, "Error getting index page"
	end
	
	test "get group info" do
		[
			:one_slide, 
			:ten_slides,
			:no_slides, 
			:inactive_event, 
			:event1_thrashed
		].each do |g|
			get :show, {id: master_groups(g).id}, @adminsession
			assert_response :success, "Error getting :show for master group: " + g.to_s
		end  
	end
	
	test "get create form" do
		get :new, nil, @adminsession
		assert_response :success
	end
	
	test "get edit form" do
		[
			:one_slide, 
			:ten_slides,
			:no_slides, 
			:inactive_event
		].each do |g|
			get :edit, {id: master_groups(g).id}, @adminsession
			assert_response :success
		end
	end
	
	test "shouldn't be able to edit internal groups" do
		get :edit, {id: master_groups(:event1_thrashed)}, @adminsession
		assert_redirected_to group_path(assigns(:group).id), "Should redirect to show page"
		assert !flash[:error].empty?, "Should set a error"
	end

	test "update group" do
		put :update, @update_data, @adminsession
		
		assert_redirected_to group_path(assigns(:group)), "Should redirect back to show"
		assert_equal "I have been updated", assigns(:group).name, "Should have updated name"
	end
	
	test "create normal group" do
		assert_difference "MasterGroup.count" do
			post :create, @create_data, @adminsession
		end
		assert_redirected_to group_path(assigns(:group))
	end
	
	test "add group to override" do
		override_data = {
			id: master_groups(:ten_slides).id,
			override: {
				display_id: displays(:normal).id,
				duration: 60
			}
		}
		assert_difference "Display.find(displays(:normal)).override_queues.count", 10 do
			post :add_to_override, override_data, @adminsession
		end
		assert_redirected_to group_path(master_groups(:ten_slides)), "Should redirect to show"
	end
	
	test "hide all slides in group" do
		assert master_groups(:ten_slides).slides.where(public: true).count != 0
		post :hide_all, {id: master_groups(:ten_slides).id}, @adminsession
		assert_redirected_to group_path(assigns(:group))
		assert assigns(:group).slides.where(public: true).count == 0
	end
	
	test "publish all slides in grou" do
		assert master_groups(:hidden_slide).slides.where(public: false).count != 0
		post :publish_all, {id: master_groups(:hidden_slide).id}, @adminsession
		
		assert_redirected_to group_path(assigns(:group))
		assert assigns(:group).slides.where(public: false).count == 0
	end
	
end
