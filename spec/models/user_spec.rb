require 'spec_helper'

describe User do


  before do
    @user  = User.new(name: "Example User", email: "user@example.com")    
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
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
end
