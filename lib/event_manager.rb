require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

puts 'EventManager initialized.'

def contents
  contents = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
  )
end

def check_phone(phone_number)
  phone_number = phone_number.to_s.gsub(/\D/, '')
  if phone_number.size == 11 && phone_number[0] == "1"
    phone_number = phone_number[1..-1]
  elsif phone_number.size < 10 || phone_number.size > 10
    phone_number = "Invalid number"
  end
  phone_number
end


def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end


def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def visited_hours(date)
  DateTime.strptime(date, '%m/%d/%Y %H:%M').hour
end

def visited_days(date)
  DateTime.strptime(date, '%m/%d/%Y %H:%M').strftime("%A")
end

def form
  template_letter = File.read('form_letter.erb')
  erb_template = ERB.new template_letter

  contents.each do |row|
    id = row[0]
    name = row[:first_name]

    zipcode = clean_zipcode(row[:zipcode])
    legislators = legislators_by_zipcode(zipcode)

    form_letter = erb_template.result(binding)

    save_thank_you_letter(id,form_letter)
  end
end

def get_phone_numbers(contents)
  contents.each {|row| p check_phone(row[:homephone])}
end
 get_phone_numbers(contents)

def get_most_visited_hour(contents)
  hours = []
  contents.each { |row| hours.push(visited_hours(row[:regdate]))}
  hours.max_by { |hour| hours.count(hour) }
end

p get_most_visited_hour(contents)

def get_most_visited_days(contents)
  days =[]
  contents.each {|row| days << visited_days(row[:regdate])}
  days.max_by {|day| days.count(day)}
end

p get_most_visited_days(contents)
