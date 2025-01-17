# -*- coding: utf-8 -*-
require "spec_helper"

describe "Subject pages" do

  subject { page }

  let(:root) { FactoryGirl.create(:root) }
  let(:other_root) { FactoryGirl.create(:root) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:other_admin) { FactoryGirl.create(:admin) }
  let(:user) { FactoryGirl.create(:user, rating: 200) } # Rating 200 is needed to have access to problems
  let(:other_user) { FactoryGirl.create(:user) }
  
  let!(:category) { FactoryGirl.create(:category) }
  let!(:category2) { FactoryGirl.create(:category) }
  
  let!(:section) { FactoryGirl.create(:section) }
  let!(:chapter) { FactoryGirl.create(:chapter, section: section, online: true) }
  let!(:question) { FactoryGirl.create(:exercise, chapter: chapter, online: true, position: 1) }
  let!(:problem) { FactoryGirl.create(:problem, section: section, online: true) }
  
  let(:sub_user) { FactoryGirl.create(:subject, user: user) }
  let(:sub_other_user) { FactoryGirl.create(:subject, user: other_user) }
  let(:sub_admin) { FactoryGirl.create(:subject, user: admin) }
  let(:sub_other_admin) { FactoryGirl.create(:subject, user: other_admin) }
  let(:sub_other_root) { FactoryGirl.create(:subject, user: other_root) }
  
  let(:sub_nothing) { FactoryGirl.create(:subject, user: user) }
  let(:sub_category) { FactoryGirl.create(:subject, user: other_user, category: category) }
  let(:sub_section) { FactoryGirl.create(:subject, user: admin, section: section) }
  let(:sub_chapter) { FactoryGirl.create(:subject, user: other_admin, section: section, chapter: chapter) }
  let(:sub_question) { FactoryGirl.create(:subject, user: root, section: section, chapter: chapter, question: question) }
  let(:sub_problem) { FactoryGirl.create(:subject, user: other_root, section: section, problem: problem) }
  
  let(:title) { "Mon titre" }
  let(:content) { "Mon message" }
  let(:newtitle) { "Mon nouveau titre" }
  let(:newcontent) { "Mon nouveau message" }
  
  let(:attachments_folder) { "./spec/attachments/" }
  let(:image1) { "mathraining.png" } # default image used in factory
  let(:image2) { "Smiley1.gif" }
  let(:exe_attachment) { "hack.exe" }
  
  describe "visitor" do
    describe "tries to visit subjects page" do
      before { visit subjects_path }
      it { should have_content(error_must_be_connected) }
    end
    
    describe "tries to create a subject" do
      before { visit new_subject_path }
      it { should have_content(error_must_be_connected) }
    end
    
    describe "tries to visit a subject" do
      before { visit subject_path(sub_user) }
      it { should have_content(error_must_be_connected) }
    end
  end
  
  describe "user" do
    before { sign_in user }
    
    # Force the creation of the following subjects:
    let!(:sub_nothing) { FactoryGirl.create(:subject, user: user) }
    let!(:sub_category) { FactoryGirl.create(:subject, user: other_user, category: category) }
    let!(:sub_section) { FactoryGirl.create(:subject, user: admin, section: section) }
    let!(:sub_chapter) { FactoryGirl.create(:subject, user: other_admin, section: section, chapter: chapter) }
    let!(:sub_question) { FactoryGirl.create(:subject, user: root, section: section, chapter: chapter, question: question) }
    let!(:sub_problem) { FactoryGirl.create(:subject, user: other_root, section: section, problem: problem) }
    
    describe "visits subjects page" do
      before { visit subjects_path }
      it do
        should have_selector("h1", text: "Forum")
        should have_link("Créer un sujet")
      
        should have_link(sub_nothing.title)
        should have_link(sub_category.title)
        should have_link(sub_section.title)
        should have_link(sub_chapter.title)
        should have_link(sub_question.title)
        should have_link(sub_problem.title)
      end
    end
    
    describe "visit subjects page for a category" do
      before { visit subjects_path(:q => category.id * 1000000) }
      
      it do
        should have_no_link(sub_nothing.title)
        should have_link(sub_category.title)
        should have_no_link(sub_section.title)
        should have_no_link(sub_chapter.title)
        should have_no_link(sub_question.title)
        should have_no_link(sub_problem.title)
      end
    end
    
    describe "visit subjects page for a section" do
      before { visit subjects_path(:q => section.id * 1000) }
      
      it do
        should have_no_link(sub_nothing.title)
        should have_no_link(sub_category.title)
        should have_link(sub_section.title)
        should have_link(sub_chapter.title)
        should have_link(sub_question.title)
        should have_link(sub_problem.title)
      end
    end
    
    describe "visit subjects page for a chapter" do
      before { visit subjects_path(:q => chapter.id) }
      
      it do
        should have_no_link(sub_nothing.title)
        should have_no_link(sub_category.title)
        should have_no_link(sub_section.title)
        should have_link(sub_chapter.title)
        should have_link(sub_question.title)
        should have_no_link(sub_problem.title)
      end
    end
    
    describe "visit subjects page for problems of a section" do
      before { visit subjects_path(:q => section.id * 1000 + 1) }
      
      it do
        should have_no_link(sub_nothing.title)
        should have_no_link(sub_category.title)
        should have_no_link(sub_section.title)
        should have_no_link(sub_chapter.title)
        should have_no_link(sub_question.title)
        should have_link(sub_problem.title)
      end
    end
    
    describe "visits subject creation page" do
      before { visit new_subject_path }
      it { should have_selector("h1", text: "Créer un sujet") }

      describe "and creates a subject" do
        before do
          select category.name, from: "Catégorie"
          fill_in "Titre", with: title
          fill_in "MathInput", with: content
          click_button "Créer"
        end
        it do
          should have_success_message("Votre sujet a bien été posté.")
          should have_content("#{title} - #{category.name}")
          should have_selector("div", text: content)
        end
        
        describe "and visit all subjects page" do
          before { visit subjects_path }
          it { should have_link(title) }
        end
      end
      
      describe "and tries to create a subject with empty title" do
        before do
          select category.name, from: "Catégorie"
          fill_in "Titre", with: ""
          fill_in "MathInput", with: content
          click_button "Créer"
        end
        it { should have_error_message("Titre doit être rempli") }
      end
    end
    
    describe "visits his subject page" do
      before { visit subject_path(sub_user) }
      it do
        should have_content(sub_user.title)
        should have_link("Modifier ce sujet")
        should have_button("Répondre")
      end
      
      describe "and edits it" do
        before do
          select category2.name, from: "Catégorie"
          fill_in "Titre", with: newtitle
          fill_in "MathInputEditSubject", with: newcontent
          click_button "Modifier"
        end
        it do
          should have_success_message("Votre sujet a bien été modifié.")
          should have_content("#{newtitle} - #{category2.name}")
          should have_selector("div", text: newcontent)
        end
      end
      
      describe "and tries to edit it with empty content" do
        before do
          select category2.name, from: "Catégorie"
          fill_in "Titre", with: newtitle
          fill_in "MathInputEditSubject", with: ""
          click_button "Modifier"
          sub_user.reload
        end
        specify do
          expect(page).to have_error_message("Message doit être rempli")
          expect(sub_user.title).not_to eq(newtitle)
        end
      end
    end
    
    describe "visits the subject of another user" do
      before { visit subject_path(sub_other_user) }
      it do
        should have_content(sub_other_user.title)
        should have_no_link("Modifier ce sujet")
        should have_no_button("Modifier")
        should have_button("Répondre")
      end
      
      describe "and follows the subject" do
        before { click_link("link_follow") }
        specify do
          expect(page).to have_success_message("Vous recevrez dorénavant un e-mail à chaque fois qu'un nouveau message sera posté sur ce sujet.")
          expect(page).to have_link("link_unfollow")
          expect(user.followed_subjects.exists?(sub_other_user.id)).to eq(true)
        end
        
        describe "and unfollows the subject" do
          before { click_link("link_unfollow") }
          specify do
            expect(page).to have_success_message("Vous ne recevrez maintenant plus d'e-mail concernant ce sujet.")
            expect(page).to have_link("link_follow")
            expect(user.followed_subjects.exists?(sub_other_user.id)).to eq(false)
          end
        end
      end
      
      describe "try to unfollow a non-existing subject" do
        before { visit remove_followingsubject_path(:subject_id => 6543) }
        it { should have_content(error_access_refused) }
      end
    end
    
    describe "tries to visit a wepion subject" do
      before { sub_other_user.update_attribute(:for_wepion, true) }
      
      describe "while not in wepion" do
        before { visit subject_path(sub_other_user) }
        it { should have_content(error_access_refused) }
      end
      
      describe "while in wepion" do
        before do
          user.update_attribute(:wepion, true)
          visit subject_path(sub_other_user)
        end
        it do
          should have_content(sub_other_user.title)
          should have_content(sub_other_user.content)
        end
      end
    end
    
    describe "tries to visit a corrector subject" do
      before { sub_other_user.update_attribute(:for_correctors, true) }
      
      describe "while not coorrector" do
        before { visit subject_path(sub_other_user) }
        it { should have_content(error_access_refused) }
      end
      
      describe "while corrector" do
        before do
          user.update_attribute(:corrector, true)
          visit subject_path(sub_other_user)
        end
        it do
          should have_content(sub_other_user.title)
          should have_content(sub_other_user.content)
        end
      end
    end
  end

  describe "admin" do
    before { sign_in admin }

    describe "visits the subject of a student" do
      before { visit subject_path(sub_user) }
      specify do
        expect(page).to have_link("Modifier ce sujet")
        expect(page).to have_link("Supprimer ce sujet")
        expect { click_link("Supprimer ce sujet") }.to change(Subject, :count).by(-1)
      end
      
      describe "and edits it" do
        before do
          select category2.name, from: "Catégorie"
          fill_in "Titre", with: newtitle
          fill_in "MathInputEditSubject", with: newcontent
          click_button "Modifier"
          sub_user.reload
        end
        specify do
          expect(sub_user.title).to eq(newtitle)
          expect(sub_user.content).to eq(newcontent)
          expect(sub_user.category).to eq(category2)
          expect(page).to have_success_message("Votre sujet a bien été modifié.")
          expect(page).to have_content("#{newtitle} - #{category2.name}")
          expect(page).to have_selector("div", text: newcontent)
        end
      end
    end

    describe "visits his subject" do
      before { visit subject_path(sub_admin) }
      specify do
        expect(page).to have_link("Supprimer ce sujet")
        expect { click_link("Supprimer ce sujet") }.to change(Subject, :count).by(-1)
      end
    end
    
    describe "tries to edit the subject of another admin" do
      before { visit subject_path(sub_other_admin) }
      it do
        should have_no_link("Modifier ce sujet")
        should have_no_button("Modifier")
      end
    end

    describe "deletes a subject with a message (DEPENDENCY)" do
      let!(:mes) { FactoryGirl.create(:message, subject: sub_user) }
      before { visit subject_path(sub_user) }
      specify {	expect { click_link("Supprimer ce sujet") }.to change(Message, :count).by(-1) }
    end
    
    describe "visits a wepion subject" do
      before do
        sub_other_user.update_attribute(:for_wepion, true)
        visit subject_path(sub_other_user)
      end
      it do
        should have_content(sub_other_user.title)
        should have_content(sub_other_user.content)
      end
    end
    
    describe "visits a corrector subject" do
      before do
        sub_other_user.update_attribute(:for_correctors, true)
        visit subject_path(sub_other_user)
      end
      it do
        should have_content(sub_other_user.title)
        should have_content(sub_other_user.content)
      end
    end
  end

  describe "root" do
    before { sign_in root }

    describe "visits the subject of another root" do
      before { visit subject_path(sub_other_root) }
      specify do
        expect(page).to have_link("Modifier ce sujet")
        expect(page).to have_link("Supprimer ce sujet")
        expect { click_link("Supprimer ce sujet") }.to change(Subject, :count).by(-1)
      end
      
      describe "and edits it" do
        before do
          select category2.name, from: "Catégorie"
          fill_in "Titre", with: newtitle
          fill_in "MathInputEditSubject", with: newcontent
          click_button "Modifier"
        end
        it do
          should have_success_message("Votre sujet a bien été modifié.")
          should have_content("#{newtitle} - #{category2.name}")
          should have_selector("div", text: newcontent)
        end
      end
    end
    
    describe "visits the subject of an user" do
      let!(:mes) { FactoryGirl.create(:message, subject: sub_other_user) }
      before do
        # Set last_comment_time and last_comment_user_id correctly for sub_user and sub_other_user
        sub_user.last_comment_time = sub_user.created_at
        sub_user.last_comment_user_id = sub_user.user_id
        sub_user.save
        sub_other_user.last_comment_time = mes.created_at
        sub_other_user.last_comment_user_id = mes.user_id
        sub_other_user.save
        visit subject_path(sub_other_user)
      end
      it { should have_link("Migrer ce sujet") }
      
      describe "and migrates it" do
        let!(:sub_user) { FactoryGirl.create(:subject, user: user, created_at: sub_other_user.created_at - 1.day) } # Force the creation
        let!(:old_title) { sub_other_user.title }
        let!(:old_content) { sub_other_user.content }
        let!(:old_num_subjects) { Subject.count }
        let!(:old_num_messages) { Message.count }
        before do
          fill_in "migreur", with: sub_user.id
          click_button "Do it !"
          sub_user.reload
          mes.reload
        end
        specify do
          expect(page).to have_content(sub_user.title)
          expect(page).to have_content(old_content)
          expect(page).to have_content(mes.content)
          expect(Subject.count).to eq(old_num_subjects - 1)
          expect(Message.count).to eq(old_num_messages + 1)
          expect(Message.order(:id).last.content).to include(old_content)
          expect(Message.order(:id).last.content).to include(old_title) # In the remark saying that the message was migrated
          expect(Message.order(:id).last.subject).to eq(sub_user)
          expect(mes.subject).to eq(sub_user)
          expect(sub_user.last_comment_user_id).to eq(mes.user_id)
        end
      end
      
      describe "and migrates it to a wrong subject" do
        before do
          fill_in "migreur", with: Subject.order(:id).last.id + 1
          click_button "Do it !"
        end
        it { should have_error_message("Ce sujet n'existe pas.") }
      end
      
      describe "and migrates it to an older subject" do
        before do
          sub_user.created_at = sub_other_user.created_at + 1.day
          sub_user.save
          fill_in "migreur", with: sub_user.id
          click_button "Do it !"
        end
        it { should have_error_message("Le sujet le plus récent doit être migré vers le sujet le moins récent.") }
      end
    end
  end
  
  # -- TESTS THAT REQUIRE JAVASCRIPT --
  
  describe "user", :js => true do
    before { sign_in user }
    
    describe "creates a subject with a file" do
      before do
        visit new_subject_path
        fill_in "Titre", with: title
        fill_in "MathInput", with: content
        click_button "Ajouter une pièce jointe"
        wait_for_ajax
        attach_file("file_1", File.absolute_path(attachments_folder + image1))
        click_button "Créer"
      end
      let(:newsubject) { Subject.order(:id).last }
      specify do
        expect(newsubject.title).to eq(title)
        expect(newsubject.content).to eq(content)
        expect(newsubject.myfiles.count).to eq(1)
        expect(newsubject.myfiles.first.file.filename.to_s).to eq(image1)
      end
    end
    
    describe "tries to create a subject with a exe file" do
      before do
        visit new_subject_path
        fill_in "Titre", with: title
        fill_in "MathInput", with: content
        click_button "Ajouter une pièce jointe"
        wait_for_ajax
        attach_file("file_1", File.absolute_path(attachments_folder + exe_attachment))
        click_button "Créer"
      end
      it do
        should have_error_message("Votre pièce jointe '#{exe_attachment}' ne respecte pas les conditions")
        should have_selector("h1", text: "Créer un sujet")
      end
    end
    
    describe "modifies a subject with a fake file" do
      let!(:subjectmyfile) { FactoryGirl.create(:subjectmyfile, myfiletable: sub_user) }
      before do
        subjectmyfile.fake_del
        visit subject_path(sub_user)
        click_link("Modifier ce sujet")
        wait_for_ajax
        fill_in "MathInputEditSubject", with: newcontent
        uncheck "prevFakeFileEditSubject_1"
        click_button "addFileEditSubject" # Ajouter une pièce jointe
        wait_for_ajax
        attach_file("fileEditSubject_1", File.absolute_path(attachments_folder + image2))
        click_button "Modifier"
        sub_user.reload
      end
      specify do
        expect(sub_user.content).to eq(newcontent)
        expect(sub_user.fakefiles.count).to eq(0)
        expect(sub_user.myfiles.count).to eq(1)
        expect(sub_user.myfiles.first.file.filename.to_s).to eq(image2)
      end
    end
    
    describe "modifies a subject with too many files" do # 3 x image1 should do > 15 ko, which is the limit in test mode
      let!(:subjectmyfile) { FactoryGirl.create(:subjectmyfile, myfiletable: sub_user) }
      before do
        visit subject_path(sub_user)
        click_link("Modifier ce sujet")
        wait_for_ajax
        fill_in "MathInputEditSubject", with: newcontent
        click_button "addFileEditSubject" # Ajouter une pièce jointe
        wait_for_ajax
        attach_file("fileEditSubject_1", File.absolute_path(attachments_folder + image1))
        click_button "addFileEditSubject" # Ajouter une pièce jointe
        wait_for_ajax
        attach_file("fileEditSubject_2", File.absolute_path(attachments_folder + image1))
        click_button "Modifier"
        sub_user.reload
      end
      specify do
        expect(page).to have_error_message("Vos pièces jointes font plus de 15 ko au total")
        expect(sub_user.content).not_to eq(newcontent)
        expect(sub_user.myfiles.count).to eq(1)
        expect(sub_user.myfiles.first.file.filename.to_s).to eq(image1)
      end
    end
    
    describe "creates a subject in relation with a section" do
      before do
        visit new_subject_path
        select section.name, from: "Catégorie"
        fill_in "Titre", with: title
        fill_in "MathInput", with: content
        click_button "Créer"
      end
      let!(:newsubject) { Subject.order(:id).last }
      specify do
        expect(page).to have_success_message("Votre sujet a bien été posté.")
        expect(newsubject.title).to eq(title)
        expect(newsubject.content).to eq(content)
        expect(newsubject.category).to eq(nil)
        expect(newsubject.section).to eq(section)
        expect(newsubject.chapter).to eq(nil)
        expect(newsubject.question).to eq(nil)
        expect(newsubject.problem).to eq(nil)
      end
    end
    
    describe "creates a subject in relation with a chapter" do
      before do
        visit new_subject_path
        select section.name, from: "Catégorie"
        wait_for_ajax
        select chapter.name, from: "Chapitre"
        fill_in "Titre", with: title
        fill_in "MathInput", with: content
        click_button "Créer"
      end
      let!(:newsubject) { Subject.order(:id).last }
      specify do
        expect(page).to have_success_message("Votre sujet a bien été posté.")
        expect(newsubject.title).to eq(title)
        expect(newsubject.content).to eq(content)
        expect(newsubject.category).to eq(nil)
        expect(newsubject.section).to eq(section)
        expect(newsubject.chapter).to eq(chapter)
        expect(newsubject.question).to eq(nil)
        expect(newsubject.problem).to eq(nil)
      end
    end
    
    describe "creates a subject in relation with an exercise" do
      let!(:question2) { FactoryGirl.create(:exercise, chapter: chapter, online: true, position: 2) }
      before do
        visit new_subject_path
        select section.name, from: "Catégorie"
        wait_for_ajax
        select chapter.name, from: "Chapitre"
        wait_for_ajax
        select "Exercice 2", from: "Exercice" # NB: Exercise 1 should not appear because there is already a subject!
        wait_for_ajax # Titre should be automatically filled with "Exercice 2"
        fill_in "MathInput", with: content
        click_button "Créer"
      end
      let!(:newsubject) { Subject.order(:id).last }
      specify do
        expect(page).to have_success_message("Votre sujet a bien été posté.")
        expect(newsubject.title).to eq("Exercice 2")
        expect(newsubject.content).to eq(content)
        expect(newsubject.category).to eq(nil)
        expect(newsubject.section).to eq(section)
        expect(newsubject.chapter).to eq(chapter)
        expect(newsubject.question).to eq(question2)
        expect(newsubject.problem).to eq(nil)
      end
    end
    
    describe "creates a subject in relation with a problem" do
      let!(:problem2) { FactoryGirl.create(:problem, section: section, online: true) }
      before do
        visit new_subject_path
        select section.name, from: "Catégorie"
        wait_for_ajax
        select "Problèmes de #{section.name.downcase}", from: "Chapitre"
        wait_for_ajax
        select "Problème \##{problem2.number}", from: "Problème" # NB: problem should not appear because there is already a subject!
        wait_for_ajax # Titre should be automaticaly filled with "Problème #..."
        fill_in "MathInput", with: content
        click_button "Créer"
      end
      let!(:newsubject) { Subject.order(:id).last }
      specify do
        expect(page).to have_success_message("Votre sujet a bien été posté.")
        expect(newsubject.title).to eq("Problème \##{problem2.number}")
        expect(newsubject.content).to eq(content)
        expect(newsubject.category).to eq(nil)
        expect(newsubject.section).to eq(section)
        expect(newsubject.chapter).to eq(nil)
        expect(newsubject.question).to eq(nil)
        expect(newsubject.problem).to eq(problem2)
      end
    end
    
    describe "creates a subject in relation with no problem" do
      before do
        visit new_subject_path
        select section.name, from: "Catégorie"
        wait_for_ajax
        select "Problèmes de #{section.name.downcase}", from: "Chapitre"
        wait_for_ajax
        fill_in "Titre", with: title
        fill_in "MathInput", with: content
        click_button "Créer"
      end
      it { should have_error_message("Un problème doit être sélectionné.") }
    end
    
    describe "creates a subject when category filter is used" do
      before do
        visit new_subject_path(:q => category2.id * 1000000)
        fill_in "Titre", with: title
        fill_in "MathInput", with: content
        click_button "Créer"
      end
      let!(:newsubject) { Subject.order(:id).last }
      specify do
        expect(page).to have_success_message("Votre sujet a bien été posté.")
        expect(newsubject.title).to eq(title)
        expect(newsubject.content).to eq(content)
        expect(newsubject.category).to eq(category2)
        expect(newsubject.section).to eq(nil)
        expect(newsubject.chapter).to eq(nil)
        expect(newsubject.question).to eq(nil)
        expect(newsubject.problem).to eq(nil)
      end
    end
    
    describe "creates a subject when section filter is used" do
      before do
        visit new_subject_path(:q => section.id * 1000)
        select chapter.name, from: "Chapitre"
        wait_for_ajax
        fill_in "Titre", with: title
        fill_in "MathInput", with: content
        click_button "Créer"
      end
      let!(:newsubject) { Subject.order(:id).last }
      specify do
        expect(page).to have_success_message("Votre sujet a bien été posté.")
        expect(newsubject.title).to eq(title)
        expect(newsubject.content).to eq(content)
        expect(newsubject.category).to eq(nil)
        expect(newsubject.section).to eq(section)
        expect(newsubject.chapter).to eq(chapter)
        expect(newsubject.question).to eq(nil)
        expect(newsubject.problem).to eq(nil)
      end
    end
    
    describe "creates a subject when problems of a section filter is used" do
    let!(:problem2) { FactoryGirl.create(:problem, section: section, online: true) }
      before do
        visit new_subject_path(:q => section.id * 1000 + 1)
        select "Problème \##{problem2.number}", from: "Problème" # NB: problem should not appear because there is already a subject!
        wait_for_ajax # Titre should be automaticaly filled with "Problème #..."
        fill_in "MathInput", with: content
        click_button "Créer"
      end
      let!(:newsubject) { Subject.order(:id).last }
      specify do
        expect(page).to have_success_message("Votre sujet a bien été posté.")
        expect(newsubject.title).to eq("Problème \##{problem2.number}")
        expect(newsubject.content).to eq(content)
        expect(newsubject.category).to eq(nil)
        expect(newsubject.section).to eq(section)
        expect(newsubject.chapter).to eq(nil)
        expect(newsubject.question).to eq(nil)
        expect(newsubject.problem).to eq(problem2)
      end
    end
    
    describe "creates a subject when chapter filter is used" do
    let!(:question2) { FactoryGirl.create(:exercise, chapter: chapter, online: true, position: 2) }
      before do
        visit new_subject_path(:q => chapter.id)
        select "Exercice 2", from: "Exercice" # NB: Exercise 1 should not appear because there is already a subject!
        wait_for_ajax # Titre should be automatically filled with "Exercice 2"
        fill_in "MathInput", with: content
        click_button "Créer"
      end
      let!(:newsubject) { Subject.order(:id).last }
      specify do
        expect(page).to have_success_message("Votre sujet a bien été posté.")
        expect(newsubject.title).to eq("Exercice 2")
        expect(newsubject.content).to eq(content)
        expect(newsubject.category).to eq(nil)
        expect(newsubject.section).to eq(section)
        expect(newsubject.chapter).to eq(chapter)
        expect(newsubject.question).to eq(question2)
        expect(newsubject.problem).to eq(nil)
      end
    end
  end
  
  describe "root", :js => true do
    before { sign_in root }
    
    let!(:other_section) { FactoryGirl.create(:section) }
    let!(:other_chapter) { FactoryGirl.create(:chapter, section: section, online: true) }
    let!(:other_question) { FactoryGirl.create(:question, chapter: other_chapter, online: true) }
    let!(:other_problem) { FactoryGirl.create(:problem, section: section, online: true) }
    
    describe "updates a subject, from a question to a section" do
      before do
        visit subject_path(sub_question)
        click_link "Modifier ce sujet"
        wait_for_ajax
        select other_section.name, from: "Catégorie"
        wait_for_ajax
        fill_in "Titre", with: newtitle
        fill_in "MathInputEditSubject", with: newcontent
        click_button "Modifier"
        sub_question.reload
      end
      specify do
        expect(page).to have_success_message("Votre sujet a bien été modifié.")
        expect(sub_question.title).to eq(newtitle)
        expect(sub_question.content).to eq(newcontent)
        expect(sub_question.section).to eq(other_section)
        expect(sub_question.chapter).to eq(nil)
        expect(sub_question.question).to eq(nil)
        expect(sub_question.problem).to eq(nil)
      end
    end
    
    describe "updates a suject, from a category to a chapter" do
      before do
        visit subject_path(sub_category)
        click_link "Modifier ce sujet"
        wait_for_ajax
        select section.name, from: "Catégorie"
        wait_for_ajax
        select other_chapter.name, from: "Chapitre"
        fill_in "Titre", with: newtitle
        fill_in "MathInputEditSubject", with: newcontent
        click_button "Modifier"
        sub_category.reload
      end
      specify do
        expect(page).to have_success_message("Votre sujet a bien été modifié.")
        expect(sub_category.title).to eq(newtitle)
        expect(sub_category.content).to eq(newcontent)
        expect(sub_category.section).to eq(section)
        expect(sub_category.chapter).to eq(other_chapter)
        expect(sub_category.question).to eq(nil)
        expect(sub_category.problem).to eq(nil)
      end
    end
    
    describe "updates a suject, from a chapter to a question" do
      before do
        visit subject_path(sub_chapter)
        click_link "Modifier ce sujet"
        wait_for_ajax
        select other_chapter.name, from: "Chapitre"
        wait_for_ajax
        select "Exercice 1", from: "Exercice"
        wait_for_ajax # Titre should be automatically filled with "Exercice 1"
        fill_in "MathInputEditSubject", with: newcontent
        click_button "Modifier"
        sub_chapter.reload
      end
      specify do
        expect(page).to have_success_message("Votre sujet a bien été modifié.")
        expect(sub_chapter.title).to eq("Exercice 1")
        expect(sub_chapter.content).to eq(newcontent)
        expect(sub_chapter.section).to eq(section)
        expect(sub_chapter.chapter).to eq(other_chapter)
        expect(sub_chapter.question).to eq(other_question)
        expect(sub_chapter.problem).to eq(nil)
      end
    end
    
    describe "updates a suject, from a chapter to a problem" do
      before do
        visit subject_path(sub_chapter)
        click_link "Modifier ce sujet"
        wait_for_ajax
        select "Problèmes de #{section.name.downcase}", from: "Chapitre"
        wait_for_ajax
        select "Problème \##{other_problem.number}", from: "Problème"
        wait_for_ajax # Titre should be automatically filled with "Problème #..."
        fill_in "MathInputEditSubject", with: newcontent
        click_button "Modifier"
        sub_chapter.reload
      end
      specify do
        expect(page).to have_success_message("Votre sujet a bien été modifié.")
        expect(sub_chapter.title).to eq("Problème \##{other_problem.number}")
        expect(sub_chapter.content).to eq(newcontent)
        expect(sub_chapter.section).to eq(section)
        expect(sub_chapter.chapter).to eq(nil)
        expect(sub_chapter.question).to eq(nil)
        expect(sub_chapter.problem).to eq(other_problem)
      end
    end
    
    describe "updates a suject, from a question to no problem" do
      before do
        visit subject_path(sub_question)
        click_link "Modifier ce sujet"
        wait_for_ajax
        select "Problèmes de #{section.name.downcase}", from: "Chapitre"
        fill_in "Titre", with: newtitle
        fill_in "MathInputEditSubject", with: newcontent
        click_button "Modifier"
        sub_question.reload
      end
      it { should have_error_message("Un problème doit être sélectionné.") }
    end
  end
end
