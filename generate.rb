require 'nokogiri'
require 'date'

FILE = '/tmp/uts'
TARGET_POSITION = 'UROP-2015SP-T Machover'

html = Nokogiri::HTML(File.read(FILE))

date = html.at_css('#g_gotodate option[selected]').text
ds, de = date.split('--')

puts "UROP Payroll: Week #{ds}-#{de} - Jiahao Li"
puts

total = 0

html.css('#content tr').each do |d|
  p = d.at_css('select[name*=position]')
  next unless p

  sel_p = p.at_css('option[selected]')
  next unless sel_p

  pos = sel_p.text.strip
  next unless (pos == TARGET_POSITION)

  dt = d.at_css('input[name*=timesheet-date]')['value']
  year = dt[0...4]
  month = dt[4...6]
  day = dt[6...8]

  hrs = min = 0

  m = d.at_css('select[name*="timesheet-min"]')
  am = m.at_css('option[selected]')

  min = am.text.to_f if am

  h = d.at_css('select[name*="timesheet-hrs"]')
  ah = h.at_css('option[selected]')

  hrs = ah.text.to_f

  hh = hrs + min

  print "#{year}/#{month}/#{day}: #{hh} "

  puts (hh == 1 ? 'hour' : 'hours')
  total += hh
end

puts
puts "Total: #{total} hours"