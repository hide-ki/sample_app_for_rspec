module LoginSupport
  def login_as(user)
    visit login_path
    fill_in "Email", with: user.email
    # user.passwordではなく、passwordじゃないとログインできない
    # データベースに保存されているpasswordはハッシュ化されているため
    # 常に"password"としておくことで使い回しがしやすい
    fill_in "Password", with: 'password'
    click_button "Login"
  end
end

