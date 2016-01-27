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
end
