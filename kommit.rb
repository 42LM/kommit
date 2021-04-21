# frozen_string_literal: true

require 'date'
require_relative 'kanye'
require_relative 'util_west'

@number_of_days = nil
@user_wants_kanye = nil
# @online_kanye_quotes = nil
@average_commits_per_day = nil
@commits_done = 0
@chance_to_commit_on_saturday = nil
@chance_to_commit_on_sunday = nil

def initial_info
  file = File.open('assets/ascii.txt')
  ascii = file.read
  puts ascii
  @number_of_days = ask_for('How many days back do you want the commits to start? 📅').to_i
  ask_about_ye = ask_for('Would you like to kanye-fy your commits for extra spice? 🎤')
  @user_wants_kanye = ask_about_ye.downcase.match?(/yes|ye|yup|yep|y/)
  # @kanye_quotes = load_kanye_quotes if @user_wants_kanye
  @average_commits_per_day = ask_for('What should be the average amount of commits per day? 🤔').to_i
  @chance_to_commit_on_saturday = ask_for('What should be the chance of commiting on Saturdays? 🌴 (percentage)').to_i
  @chance_to_commit_on_sunday = ask_for('What should be the chance of commiting on Sundays? ⛱️ (percentage)').to_i
end

def git_repo?
  File.directory?("#{Dir.home}/kommitr_commits/.git")
end

def init_repo
  unless git_repo?
    system('cd && gh repo create kommitr_commits --private --confirm')
  end
end

def create_commit(days_ago)
  if @user_wants_kanye
    commit_message = KANYE_QUOTES.sample
    system("cd && cd kommitr_commits && git commit --allow-empty --date=\"#{days_ago} day ago\" -m \"#{commit_message}\" --quiet")
    puts "Last commit message: #{commit_message}"
    @commits_done += 1
  else
    system("cd && cd kommitr_commits && git commit --allow-empty --allow-empty-message --date=\"#{days_ago} day ago\"  -m \"\" --quiet")
    print "#{@commits_done} commits made\r"
    @commits_done += 1
    $stdout.flush
  end
end

def handle_weekend_days(day_index)
  if random_chance_for_date(day_index)
    random_amount(@average_commits_per_day).times { create_commit(@number_of_days) }
  end
end

def yeezus_commit_it!
  init_repo
  while @number_of_days > 0
    temp_date = Date.today - @number_of_days

    # Check if Saturday or Sunday
    if temp_date.wday == 0 || temp_date.wday == 6
      handle_weekend_days(temp_date.wday)
    else
      random_amount(@average_commits_per_day).times { create_commit(@number_of_days) }
    end
    @number_of_days -= 1
  end
  $stdout.flush
  print "#{@commits_done} commits done 🤖👌"
end

def user_confirmation
  puts
  user_answer = ask_for("Would you like to push the #{@commits_done} commits?")
  push_confirmation = user_answer.downcase.match?(/yes|ye|yup|yep|y/)
  if push_confirmation
    system('cd && cd kommitr_commits && git push origin master')
    sleep 3
    puts 'All done! 😎'
  else
    puts 'All these commits for nothing! 😭'
  end
end

initial_info
yeezus_commit_it!
user_confirmation
