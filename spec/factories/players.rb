FactoryBot.define do
  factory :player do
    first_name { "MyString" }
    last_name { "MyString" }
    height { 1 }
    weight { 1 }
    birthday { "MyString" }
    graduation_year { 1 }
    position { "MyString" }
    recruit { false }
  end
end
