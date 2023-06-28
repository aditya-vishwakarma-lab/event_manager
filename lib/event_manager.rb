require "csv"
require 'google/apis/civicinfo_v2'
puts 'Event Manager Initialized!'

puts



# lines = File.readlines("../event_attendees.csv")

# lines.each_with_index do |line,index|
#   # puts line,index
#   # puts line
#   next if index==0
#   columns = line.split(",")
#   puts columns[2]
# end

def clean_zipcode(zipcode)
  return zipcode.to_s.rjust(5,"0").slice(0,5)
  # if zipcode.nil?
  #   return "00000"
  # elsif zipcode.length  > 5
  #   return zipcode[0...5]
  # elsif zipcode.length < 5
  #   return zipcode.rjust(5,"0")
  #   # zipcode = "0"*(5-zipcode.length) + zipcode
  # else
  #   return zipcode
  # end
end

def legislators_by_zipcode(zipcode)
  zipcode = clean_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    )
    legislators = legislators.officials

    legislator_names = legislators.map(&:name)

    legislators_string = legislator_names.join(", ")

    return legislators_string
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

contents = CSV.open("../event_attendees.csv", headers: true, header_converters: :symbol)
contents.each do |row|
  name = row[:first_name]
  zipcode = row[:zipcode]
  legislators = legislators_by_zipcode(zipcode)
  puts "#{name} #{zipcode} #{legislators}"
  puts
end

# puts content