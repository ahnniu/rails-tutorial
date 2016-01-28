require 'spec_helper'

describe "StaticPages" do
  
  subject { page }

  shared_examples_for 'all static pages' do
    it { should have_content(heading) }
    it { should have_title(full_title(page_title)) }
  end

  describe 'Home page' do
    before { visit root_path }

    let(:heading) { 'Sample App' }
    let(:page_title) { '' }

    it_should_behave_like 'all static pages'
    it { should_not have_title('Home') }

    describe 'for signed-in users' do
      let(:user) { FactoryGirl.create(:user) }
      before do
        sign_in user
      end

      describe 'about feed' do
        before do
          FactoryGirl.create(:micropost, user: user, content: 'Hello')
          FactoryGirl.create(:micropost, user: user, content: 'World')
          visit root_path         
        end

        it 'should rend the user\'s feed' do
          user.feed.each do |item|
            expect(page).to have_selector("li##{item.id}", text: "#{item.content}")
          end
        end

        describe 'pagination' do
          before do
            50.times do |i|
              FactoryGirl.create(:micropost, user: user, content: "micropost##{i}")
            end
            visit root_path
          end

          it { should have_selector('div.pagination') }              
        end        
      end

      describe 'it should display correct micropost count' do

        describe 'when have only 1 micropost' do
          before do
            FactoryGirl.create(:micropost, user: user, content: '1 micropost')
            visit root_path
          end
          specify { expect(page).to have_content('1 micropost') }
        end

        describe 'when have more then 1 micropost' do
          before do
            10.times do |i|
              FactoryGirl.create(:micropost, user: user, content: "micropost##{i}")
            end
            visit root_path
          end
          specify { expect(page).to have_content('10 microposts') }
        end
      end
      describe 'follower / follwing counts' do

        describe 'with 1 follower' do
          let(:other_user) { FactoryGirl.create(:user) }
          before do
            other_user.follow!(user)
            visit root_path
          end

          it { should have_link('0 following', href: following_user_path(user)) }
          it { should have_link('1 follower', href: followers_user_path(user)) }
        end
        

        describe 'with more than 1 followers' do
          before do
            users = Array.new
            10.times do |i|
              users[i] = FactoryGirl.create(:user)
            end
            
            followed_users = users[0..5]
            followers = users[6..9]

            followed_users.each do |followed_user|
              user.follow!(followed_user)
            end
            followers.each do |follower|
              follower.follow!(user)
            end
            visit root_path
          end

          it { should have_link('6 following', href: following_user_path(user)) }         
          it { should have_link('4 followers', href: followers_user_path(user)) }
        end
      end
    end
  end

  describe 'Help page' do
    before { visit help_path }

    let(:heading) { 'Help' }
    let(:page_title) { 'Help'  }

    it_should_behave_like 'all static pages'
  end

  describe 'About page' do
    before { visit about_path }

    let(:heading) { 'About Us' }
    let(:page_title) { 'About Us' }

    it_should_behave_like 'all static pages'
  end

  describe 'Contact page' do
    before { visit contact_path }

    let(:heading) { 'Contact' }
    let(:page_title) { 'Contact' }

    it_should_behave_like 'all static pages'
  end

  it 'should have the right links on the layouts' do
    visit root_path

    click_link 'About'
    expect(page).to have_title(full_title('About Us'))

    click_link 'Help'
    expect(page).to have_title(full_title('Help'))

    click_link 'Contact'
    expect(page).to have_title(full_title('Contact'))

    click_link 'Sign up'
    expect(page).to have_title(full_title('Sign up'))
  end
end
