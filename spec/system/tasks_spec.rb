require 'rails_helper'

RSpec.describe "Tasks", type: :system do
  let(:user) { create(:user) }
  describe "ログイン済みユーザー" do
    context "フォームの入力値が正常" do
      it "タスクを作成できること" do
        login_as user
        task = build(:task, user: user)
        expect{
          visit new_task_path
          fill_in "Title", with: task.title
          fill_in "Content", with: task.content
          select task.status, from: "Status"
          fill_in "Deadline", with: task.deadline
          click_button "Create Task"
        }.to change(Task, :count).by(1)
        expect(page).to have_content "Task was successfully created."
        expect(page).to have_content task.title
        # task_path(task)を指定すると、エラーが発生し、解消できなかった
        # "/tasks/1" のように指定するとエラーは発生しない
        expect(current_path).to eq "/tasks/1"
      end
      it "タスクを編集できること" do
        login_as user
        task = create(:task, user: user)
        visit edit_task_path(task)
        fill_in "Title", with: "foo"
        select "done", from: "Status"
        click_button "Update Task"
        expect(page).to have_content "Task was successfully updated"
        expect(page).to have_content "foo"
        expect(current_path).to eq task_path(task)
      end
    end
    context "使用済みのタイトル" do
      it "タスクを作成できないこと" do
        login_as user
        task = create(:task, user: user)
        expect{
          visit new_task_path
          fill_in "Title", with: task.title
          fill_in "Content", with: task.content
          select task.status, from: "Status"
          click_button "Create Task"
        }.to change(Task, :count).by(0)
        expect(page).to have_content "Title has already been taken"
      end
    end
    context "タスクの削除" do
      it "タスクを削除できること" do
        login_as user
        task = create(:task, user: user)
        expect{
          visit tasks_path
          click_link "Destroy"
          expect(page.accept_confirm).to eq "Are you sure?"
          expect(page).to have_content "Task was successfully destroyed."
        }.to change(Task, :count).by(-1)
      end
    end
  end
  describe "未ログインユーザー" do
    context "タスクの作成" do
      it "タスク作成ページに遷移できないこと" do
        visit new_task_path
        expect(current_path).to eq login_path
        expect(page).to have_content "Login required"
      end
    end
    context "タスクの編集" do
      it "タスク編集ページに遷移できないこと" do
        task = create(:task, user: user)
        visit edit_task_path(task)
        expect(current_path).to eq login_path
        expect(page).to have_content "Login required"
      end
    end
  end
end
