require 'spec_helper'

describe User do


  before do
    @user  = User.new(
      name: "Example User", 
      email: "user@example.com",
      password: "foobar",
      password_confirmation: "foobar")    
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:admin) }
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:follow!) }
  it { should respond_to(:unfollow!) }
  it { should respond_to(:following?) }

  it { should be_valid }
  it { should_not be_admin }

  describe 'when name is not present' do
    before do
      @user.name = ""
    end

    it { should_not be_valid }
  end

  describe 'when email is not present' do
    before do
      @user.email = ""      
    end

    it { should_not be_valid }
  end

  describe 'when name is too long' do
    before do
      @user.name = 'a' * 51
    end

    it { should_not be_valid }
  end

  describe 'when email address is invalid' do
    it 'should be invalid' do
      addresses = %w[user_foo.com 123user@foo.com user@@foo.com user#123@foo.com user@foo+bar.com user@foo.bar..com]
      addresses.each do |address|
        @user.email = address
        expect(@user).not_to be_valid
      end      
    end
  end

  describe 'when email address is valid' do
    it 'should be valid' do
      addresses = %w[user@foo.com user_name@foo.com user-name@foo-bar.com user.name@foo.com USER@FOO]
      addresses.each do |address|
        @user.email = address
        expect(@user).to be_valid
      end
    end
  end

  describe 'when email address is already taken' do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end
    
    it { should_not be_valid }
  end

  describe 'when email address with mixed case' do
    let(:mixed_case_email) { "Foo@BAR.com" }
    
    it 'should be saved as all lower-case' do
      @user.email = mixed_case_email
      @user.save
      expect(@user.reload.email).to eq mixed_case_email.downcase
    end

  end

  describe 'when password is not present' do
    before do
      @user.password = ""
      @user.password_confirmation = ""
    end

    it { should_not be_valid }
  end

  describe "when passrod doesn't match confirmation" do
    before do
      @user.password = "others"
    end

    it { should_not be_valid }
  end

  describe 'when authenticate password' do
    before do
      @user.save
    end
    let(:found_user) { User.find_by(email: @user.email) }

    describe 'with valid password' do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe 'with invalid password' do
      let(:user_for_invalid_password) { found_user.authenticate('invalid_password') }
      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be false }
    end
  end

  describe 'with a password too short' do
    before do
      @user.password = @user.password_confirmation = 'a' * 5
    end

    it { should_not be_valid }

  end

  describe 'remember token' do
    before { @user.save }
    subject { @user.remember_token }
    it { should_not be_blank }
  end

  describe 'micropost associations' do
    before { @user.save }
    let!(:older_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end

    it 'should have the right microposts in the right order' do
      expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
    end

    it 'should destroy associated microposts' do
      microposts = @user.microposts.to_a
      @user.destroy

      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end

    describe 'status' do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end
      let(:followed_user) { FactoryGirl.create(:user) }
      before do
        @user.follow!(followed_user)
        3.times { followed_user. microposts.create!(content: 'Hello')}
      end
      subject { @user.feed }

      it { should include(newer_micropost) }
      it { should include(older_micropost) }
      it { should_not include(unfollowed_post) }

      it 'should include followed user\'s microposts' do
        followed_user.microposts.each do |micropost|
          expect(@user.feed).to include(micropost)
        end
      end
    end
  end

  describe 'following' do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.follow!(other_user)
    end

    it { should be_following(other_user) }

    describe 'in following list' do
      subject { @user.followed_users }
      it { should include(other_user) }
    end

    describe 'and unfollowing' do
      before { @user.unfollow!(other_user) }

      describe 'in following user list' do
        subject { @user.followed_users }
        it { should_not include(other_user) }
      end
    end
  end

  describe 'relationship associations' do
    let(:followed_user) { FactoryGirl.create(:user) }
    let(:follower) { FactoryGirl.create(:user)}
    before do
      @user.save
      @user.follow!(followed_user)
      follower.follow!(@user)
    end

    it 'should destroyed associated relationship' do
      relationships = @user.relationships.to_a
      @user.destroy

      expect(relationships).not_to be_empty
      relationships.each do |relationship|
        expect(Relationship.where(id: relationship.id)).to be_empty
      end
    end
  end
end
