FactoryGirl.define do
  factory :user do
    name                  "Michael Hartl"
    email                 "example@railstutorial.org"
    password              "foobar"
    password_confirmation "foobar"
  end
end

