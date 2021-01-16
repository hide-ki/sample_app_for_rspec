require 'rails_helper'

RSpec.describe "Tasks", type: :system do
  let(:user) { create(:user) }
  let(:task) { create(:task) }
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
        visit edit_task_path(task)
        expect(current_path).to eq login_path
        expect(page).to have_content "Login required"
      end
    end
    context "タスクの詳細ページにアクセス" do
      it "タスクの詳細情報が表示される" do
        visit task_path(task)
        expect(page).to have_content task.title
        expect(current_path).to eq task_path(task)
      end
    end
    context "タスクの一覧ページにアクセス" do
      it "全てのユーザーのタスク情報が表示される" do
        task_list = create_list(:task, 3)
        visit tasks_path
        expect(page).to have_content task_list[0].title
        expect(page).to have_content task_list[1].title
        expect(page).to have_content task_list[2].title
        expect(current_path).to eq tasks_path
      end
    end
  end


  describe "ログイン済みユーザー" do
    before { login_as user }

    describe "タスク新規登録" do
      context "フォームの入力値が正常" do
        it "タスクを作成できること" do
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
          # Task.firstとすることで納得
          expect(current_path).to eq task_path(Task.first)
        end 
      end
      context "タイトルが未入力" do
        it "タスクの新規作成が失敗する" do
          visit new_task_path
          fill_in "Title", with: ""
          fill_in "Content", with: "test_content"
          click_button "Create Task"
          expect(page).to have_content "1 error prohibited this task from being saved:"
          expect(page).to have_content "Title can't be blank"
          expect(current_path).to eq tasks_path
        end
        
      end
      context "使用済みのタイトル" do
        it "タスクを作成できないこと" do
          # other_taskを作らずに、fill_inの入力値にtask.titleではダメな理由がわからない
          # task.titleを呼び出した時にtaskがcreateされていない？
          other_task = create(:task)
          expect{
            visit new_task_path
            fill_in "Title", with: other_task.title
            fill_in "Content", with: other_task.content
            select other_task.status, from: "Status"
            click_button "Create Task"
          }.to change(Task, :count).by(0)
          expect(page).to have_content "Title has already been taken"
        end 
      end
    end
    describe "タスク編集" do
      let!(:task) { create(:task, user: user) }
      before { visit edit_task_path(task) }

      context " フォームの入力値が正常" do
        it "タスクを編集できること" do
          fill_in "Title", with: "foo"
          select "done", from: "Status"
          click_button "Update Task"
          expect(page).to have_content "Task was successfully updated"
          expect(page).to have_content "foo"
          expect(page).to have_content "Status: done"
          expect(current_path).to eq task_path(task)
        end
      end
      context "タイトルが未入力" do
        it "タスクの編集が失敗する" do
          fill_in 'Title', with: nil
          select :todo, from: 'Status'
          click_button 'Update Task'
          expect(page).to have_content '1 error prohibited this task from being saved'
          expect(page).to have_content "Title can't be blank"
          expect(current_path).to eq task_path(task)
        end
      end
      context "登録済みのタイトルを入力" do
        it "タスクを編集できないこと" do
          duplicate_title_task = create(:task)
          fill_in "Title", with: duplicate_title_task.title
          click_button "Update Task"
          expect(page).to have_content "1 error prohibited this task from being saved"
          expect(page).to have_content "Title has already been taken"
          expect(current_path).to eq task_path(task)
        end
      end
    end

    describe "タスク削除" do
      let!(:task) { create(:task, user: user) }
      context "タスクの削除" do
        it "タスクを削除できること" do
          expect{
            visit tasks_path
            click_link "Destroy"
            expect(page.accept_confirm).to eq "Are you sure?"
            expect(page).to have_content "Task was successfully destroyed."
          }.to change(Task, :count).by(-1)
          expect(current_path).to eq tasks_path
        end
      end
    end
  end
end