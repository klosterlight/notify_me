require 'spec_helper'

RSpec.describe UserNotification, type: :model do
  subject {
    FactoryBot.build(:user_notification)
  }

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:notification) }
  end

  describe "validations" do
  end
end
