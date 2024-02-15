require 'csv'
puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

def clean_zipcode(zipcode)
  if zipcode.nil?
    zipcode = '00000'
  elsif zipcode.size < 5
    zipcode = "0#{zipcode}" until zipcode.size == 5
  elsif zipcode.size > 5
    zipcode.truncate(5)
  end
end

contents.each do |row|
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  puts "#{name} #{zipcode}"
end
