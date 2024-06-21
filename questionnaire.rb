require "pstore"

STORE_NAME = "tendable.pstore"
QUESTIONS = {
  "q1" => "Can you code in Ruby?",
  "q2" => "Can you code in JavaScript?",
  "q3" => "Can you code in Swift?",
  "q4" => "Can you code in Java?",
  "q5" => "Can you code in C#?"
}.freeze

def do_prompt
  store = PStore.new(STORE_NAME)
  answers = {}

  QUESTIONS.each do |question_key, question_text|
    print "#{question_text} (Yes/No): "
    answer = gets.chomp.downcase
    while !["yes", "no", "y", "n"].include?(answer)
      print "Please answer Yes or No: "
      answer = gets.chomp.downcase
    end
    answers[question_key] = (answer == "yes" || answer == "y")
  end

  store.transaction do
    store[:answers] ||= []
    store[:answers] << answers
  end

  answers
end


#calculate rating for answer provided by user
def calculate_rating(answers)
  num_yes = answers.count { |_, ans| ans }
  num_questions = QUESTIONS.size
  (100.0 * num_yes / num_questions).round(2)
end


#Generate report for each run and calculate average rating
def do_report
  store = PStore.new(STORE_NAME)
  ratings = []

  store.transaction do
    store[:answers]&.each_with_index do |answers, index|
      rating = calculate_rating(answers)
      puts "Rating for Run #{index + 1}: #{rating}%"
      ratings << rating
    end
  end

  if ratings.any?
    average_rating = (ratings.reduce(:+) / ratings.size).round(2)
    puts "Average Rating: #{average_rating}%"
  else
    puts "No ratings available."
  end
end

# Main execution flow
do_prompt
do_report


