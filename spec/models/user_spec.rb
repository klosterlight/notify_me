require 'spec_helper'

RSpec.describe User, type: :model do
  subject {
    FactoryBot.build(:user)
  }

  describe 'associations' do
    it "should be rolified" do
      expect(subject).to respond_to(:has_role?)
      expect(subject).to respond_to(:roles)
    end
    it { should have_many(:user_notifications) }
    it { should have_many(:notifications) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it "should set email as downcase" do
      expect(subject.email).to eq(subject.email.downcase)
    end
    it "should set name as camelcase" do
      expect(subject.name).to eq(subject.name.camelize)
    end
    it "should have secure_password" do
      expect(subject).to respond_to(:password)
    end
    it "should have active_status" do
      expect(subject).to respond_to(:active?)
    end
    it "should have active_status" do
      expect(subject).to respond_to(:inactive?)
    end
  end
end
