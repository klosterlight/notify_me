require 'spec_helper'

RSpec.describe Notification, type: :model do
  subject {
    FactoryBot.build(:notification)
  }

  describe "associations" do
    it { should have_many(:user_notifications) }
    it { should have_many(:users) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:content_message) }
    it { should validate_presence_of(:notification_type) }
    it { should define_enum_for(:notification_type).with_values(alert: 0, action: 1) }
    it { should validate_length_of(:content_message).is_at_most(255) }

    it { should respond_to(:users_ids) }
    it { should respond_to(:roles_attributes) }
    it { should respond_to(:all_users) }
  end

  describe "#save_and_notify_users" do
    context "when users_ids param is set" do
      before(:all) do
        Notification.destroy_all
        User.destroy_all
        @users = FactoryBot.create_list :user, 20
        @other_users = FactoryBot.create_list :user, 10
        @notification_attributes = FactoryBot.attributes_for(:notification)
        @notification_attributes[:users_ids] = @users.map(&:id)
        @notification = Notification.new(@notification_attributes)
        @notification.save_and_notify_users
      end

      it "should create one notification" do
        expect(Notification.all.count).to eq 1
      end

      it "should create a user_notification for each user id found in the users_ids param" do
        expect(UserNotification.all.count).to eq @users.length
        expect(UserNotification.all.map(&:user_id)).to eq @users.map(&:id)
      end
    end

    context "when roles_attributes param is set" do
      context "when only the role names is set" do
        before(:all) do
          Notification.destroy_all
          User.destroy_all
          @admins = FactoryBot.create_list :user, 20, :admin
          @customers = FactoryBot.create_list :user, 10, :customer
          @notification_attributes = FactoryBot.attributes_for(:notification)
          @notification_attributes[:roles_attributes] = {}
          @notification_attributes[:roles_attributes][:role_names] = ["admin"]
          @notification = Notification.new(@notification_attributes)
          @notification.save_and_notify_users
        end

        it "should notify all the users with any of those roles" do
          expect(UserNotification.all.count).to eq 20
          @admins.each do |admin|
            expect(admin.user_notifications.count).to eq 1
          end
        end
      end
      context "when the role names and the resource is set" do
        before(:all) do
          Notification.destroy_all
          User.destroy_all
          @address = FactoryBot.create :address
          @scoped_customers = FactoryBot.create_list :user, 20, :scoped_customer, address: @address
          @customers = FactoryBot.create_list :user, 10, :customer
          @notification_attributes = FactoryBot.attributes_for(:notification)
          @notification_attributes[:roles_attributes] = {}
          @notification_attributes[:roles_attributes][:role_names] = ["customer"]
          @notification_attributes[:roles_attributes][:resource] = @address
          @notification = Notification.new(@notification_attributes)
          @notification.save_and_notify_users
        end

        it "should notify all the users with any role_name scoped to that resource" do
          expect(UserNotification.all.count).to eq 20
          @scoped_customers.each do |customer|
            expect(customer.user_notifications.count).to eq 1
          end
        end
      end

      context "when the roles_attributes is invalid" do
        before(:all) do
          Notification.destroy_all
          User.destroy_all
          @users = FactoryBot.create_list :user, 20
          @notification_attributes = FactoryBot.attributes_for(:notification)
          @notification_attributes[:roles_attributes] = {}
          @notification_attributes[:roles_attributes][:role_names] = ["asdf"]
          @notification = Notification.new(@notification_attributes)
          @notification.save_and_notify_users
        end

        it "should do nothing" do
          expect(Notification.all.count).to eq 0
          expect(UserNotification.all.count).to eq 0
        end
      end
    end

    context "when all_users param is set" do
      before(:all) do
        Notification.destroy_all
        User.destroy_all
        @users = FactoryBot.create_list :user, 20
        @notification_attributes = FactoryBot.attributes_for(:notification)
        @notification_attributes[:all_users] = true
        @notification = Notification.new(@notification_attributes)
        @notification.save_and_notify_users
      end

      it "should create one notification" do
        expect(Notification.all.count).to eq 1
      end

      it "should create a user_notification for each active user" do
        expect(UserNotification.all.count).to eq User.active.all.count
        expect(UserNotification.all.map(&:user_id)).to eq User.active.all.map(&:id)
      end
    end

    context "when no param is sent" do
      before(:all) do
        Notification.destroy_all
        User.destroy_all
        @users = FactoryBot.create_list :user, 20
        @notification_attributes = FactoryBot.attributes_for(:notification)
        @notification = Notification.new(@notification_attributes)
        @notification.save_and_notify_users
      end

      it "should do nothing" do
        expect(Notification.all.count).to eq 0
        expect(UserNotification.all.count).to eq 0
      end
    end
  end
end
