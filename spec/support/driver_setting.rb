RSpec.configure do |config|
  # spec実行時にブラウザの表示有無を切り替える設定
  config.before(:each, type: :system) do
    # driven_byで実行時のブラウザを設定
    driven_by(:selenium_chrome_headless)
  end
end