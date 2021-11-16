include ApplicationHelper

def sign_in(user)
  visit root_path
  click_link "Connexion"
  fill_in "tf1", with: user.email
  fill_in "tf2", with: user.password
  click_button "Connexion"
end

def sign_out
  visit root_path
  click_link "Déconnexion"
end

def error_access_refused
  return "Désolé... Cette page n'existe pas ou vous n'y avez pas accès."
end

def error_must_be_connected
  return "Vous devez être connecté pour accéder à cette page."
end

def create_discussion_between(user1, user2, content1, content2)
  d = Discussion.new
  d.last_message = DateTime.now
  d.save
  link = Link.new
  link.user_id = user1.id
  link.discussion_id = d.id
  link.nonread = 0
  link.save
  link2 = Link.new
  link2.user_id = user2.id
  link2.discussion_id = d.id
  link2.nonread = 0
  link2.save
  m = Tchatmessage.new
  m.user_id = user1.id
  m.content = content1
  m.discussion_id = d.id
  m.save
  m2 = Tchatmessage.new
  m2.user_id = user2.id
  m2.content = content2
  m2.discussion_id = d.id
  m2.save
  return d
end

def wait_for_ajax
  Timeout.timeout(Capybara.default_max_wait_time) do
    loop until finished_all_ajax_requests?
  end
end

def finished_all_ajax_requests?
  page.evaluate_script('jQuery.active').zero?
end

# The following method has some issues: instead of using it we prefer to remove confirmations when Rails.env.test? = true
def accept_browser_dialog
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  wait.until {
    begin
      page.driver.browser.switch_to.alert
      true
    rescue Selenium::WebDriver::Error::NoAlertPresentError
      false
    end
  }
  page.driver.browser.switch_to.alert.accept
  sleep(1) # This is the issue: it looks like we need to wait some time (how much?) manually
end

def take_screenshot
  Capybara::Screenshot.screenshot_and_open_image
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    expect(page).to have_selector("div.alert.alert-danger", text: message)
  end
end

RSpec::Matchers.define :have_info_message do |message|
  match do |page|
    expect(page).to have_selector("div.alert.alert-info", text: message)
  end
end

RSpec::Matchers.define :have_success_message do |message|
  match do |page|
    expect(page).to have_selector("div.alert.alert-success", text: message)
  end
end
