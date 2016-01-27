require 'spec_helper'

describe "MicropostPages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in user
    visit root_path
  end

  describe 'micropost creation' do
    describe 'with invalid information' do

      it 'should not create a micropost' do
        expect { click_button 'Post'}.not_to change(Micropost, :count)
      end

      describe 'error message' do
        before { click_button 'Post' }
        it { should have_error_message }
      end
    end

    describe 'with valid information' do
      before do
        fill_in 'Content', with: 'This is a message to test.'
      end

      it 'should create a micropost' do
        expect { click_button 'Post' }.to change(Micropost, :count).by(1)
      end
    end
  end

  describe 'micropost destruction' do
    let!(:micropost) { FactoryGirl.create(:micropost, user: user) }

    describe 'as correct user' do
      before { visit root_path }

      it 'should delete a micropost' do
        expect {click_link 'delete'}.to change(Micropost, :count).by(-1)
      end
    end

    describe 'as wrong user' do
      let(:wrong_user) { FactoryGirl.create(:user)  }

      before do
        sign_in wrong_user, no_capybara: true  
      end
      describe 'attempt to submitting a DELETE request to Micropost#destroy' do
        it 'should not delete a micropost' do
          expect { delete micropost_path(micropost) }.not_to change(Micropost, :count)
        end
      end
    end
  end
end
