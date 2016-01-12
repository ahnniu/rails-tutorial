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
  it { should respond_to(:authenticate) }
  it { should be_valid }

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
      addresses = %w[user_foo.com 123user@foo.com user@@foo.com user#123@foo.com user@foo+bar.com]
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

end
