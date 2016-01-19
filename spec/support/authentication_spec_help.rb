module AuthenticationSpecHelp
  
  def valid_signin(user)
    fill_in 'Email', with: user.email.upcase
    fill_in 'Password', with: user.password
    click_button 'Sign in'    
  end
end