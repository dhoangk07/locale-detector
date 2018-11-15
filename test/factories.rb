include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :user do
    email {Faker::Internet.email }
    password "1234567"
    password_confirmation "1234567"
  end

  factory :repo do
    url {Faker::Internet.url('https://github.com', '/foobar.html')}
    name {Faker::Name.name}
    user
  end
end



