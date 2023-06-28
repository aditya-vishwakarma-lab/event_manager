require "csv"
require "google/apis/civicinfo_v2"
require "erb"



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
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
    return legislators
  rescue StandardError
    return 'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'Event Manager Initialized!'

puts

contents = CSV.open("../event_attendees.csv", headers: true, header_converters: :symbol)

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

# puts content