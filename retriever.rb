require 'selenium-webdriver'
require 'fileutils'

URL = 'https://atlas.mit.edu'
OUTPUT_DIR = File.expand_path('~/.timesheets/')

driver = Selenium::WebDriver.for :chrome

master_window = driver.window_handle

driver.navigate.to URL

driver.find_element(:id, 'Select').click
driver.find_element(:name, 'login_certificate').click
driver.find_element(:id, 'group_timevaca').find_element(:tag_name, 'a').click
sleep 1
driver.find_element(:partial_link_text, 'Time Sheet Entry').click

while driver.window_handles.size == 1
  sleep 1
end

driver.window_handles.each do |w|
  if w != master_window
    driver.switch_to.window w
    break
  end
end

date_option = driver.find_element(:id, 'g_gotodate')
select = Selenium::WebDriver::Support::Select.new(date_option)
count = select.options.size

FileUtils.mkdir_p(OUTPUT_DIR)

0.upto(count - 1) do |c|
  date_option = driver.find_element(:id, 'g_gotodate')
  select = Selenium::WebDriver::Support::Select.new(date_option)
  w = select.options[c]
  t = w.text
  path = File.join(OUTPUT_DIR, t.gsub('/', '-') + '.html')

  if File.exists? path
    puts 'Skipping ' + t
  else
    puts 'Scraping ' + t
    select.select_by :text, t
    driver.execute_script "suit.fieldChange('~okcode','goto_week'); document.timesheet.submit();"
    sleep 0.5

    File.write(path, driver.execute_script("return document.body; ").attribute('innerHTML'))
  end
end