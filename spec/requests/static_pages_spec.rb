# -*- coding: utf-8 -*-
require "spec_helper"

describe "Static pages" do

	subject { page }

	describe "Home page" do
		before { visit root_path }
		it { should have_selector("h1", text: "Actualités") }
	end

	describe "About page" do
		before { visit about_path }
		it { should have_selector("h1", text: "À propos") }
	end

	describe "Contact page" do
		before { visit contact_path }
		it { should have_selector("h1", text: "Contact") }
	end
	
	describe "Any page, starting benchmark" do
	  before { visit root_path(:start_benchmark => 1) }
	  it { should have_content("Temps total de chargement") }
	  
	  describe "visiting another page" do
	    before { visit contact_path }
	    it { should have_content("Temps total de chargement") }
	    
	    describe "and stopping benchmark" do
	      before { visit about_path(:stop_benchmark => 1) }
	      it { should have_no_content("Temps total de chargement") }
	      
	      describe "and visiting another page" do
	        before { visit users_path }
	        it { should have_no_content("Temps total de chargement") }
	      end
	    end
	  end
	end
end
