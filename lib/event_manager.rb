require 'csv'
puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]
  zipcode = row[:zipcode]
  if zipcode.nil?
    zipcode = '00000'
  elsif zipcode.size < 5
    zipcode = "0#{zipcode}" until zipcode.size == 5
  elsif zipcode.size > 5
    zipcode.truncate(5)
  end
  puts "#{name} #{zipcode}"
end
