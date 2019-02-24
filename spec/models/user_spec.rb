require 'spec_helper'

describe User do
  subject do
    @user = User.new
    @user.valid?
    @user
  end
  it {should have(1).errors_on(:name)}

  it "has many groups" do
    @user = User.make!
    @group = Group.make!
    @group.add_member!(@user)
    @user.groups.should include(@group)
  end

  it "has correct group request" do
    @user = User.make!
    @group = Group.make!
    Membership.make!(:group => @group, :user => @user)
    @user.group_requests.should include(@group)
  end

  it "can be invited" do
    @inviter = User.make!
    @group = Group.make!
    @user = User.invite_and_notify!({email: "foo@example.com"}, @inviter, @group)
    @group.users.should include(@user)
  end

  it "invited user should have email as name" do
    @user = User.invite_and_notify!({email: "foo@example.com"}, User.make!, Group.make!)
    @user.name.should == @user.email
  end

  it "can find user by email (case-insensitive)" do
    @user = User.make!(email: "foobar@example.com")
    User.find_by_email("foObAr@exaMPLE.coM").should == @user
  end

  it "can create a new motion_activity_read_log" do
    @user = User.make!
    @group = Group.make!
    @motion = create_motion(group: @group)
    @user.update_motion_activity_read_log(@motion)
    MotionActivityReadLog.count.should == 1
  end

  it "can update an existing motion_activity_read_log" do
    @user = User.make!
    @group = Group.make!
    @motion = create_motion(group: @group)
    @motion.activity_count = 2
    @user.update_motion_activity_read_log(@motion)
    @motion.activity_count = 7
    @user.motion_activity_last_read_at(@motion).should == 2
    @user.update_motion_activity_read_log(@motion)
    @user.motion_activity_last_read_at(@motion).should == 7
  end
end
