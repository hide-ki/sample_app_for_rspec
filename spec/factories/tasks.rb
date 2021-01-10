FactoryBot.define do
  factory :task do
    title { "hoge" }
    content { "hogehoge"}
    status { "todo" }
    association :user
  end
end
