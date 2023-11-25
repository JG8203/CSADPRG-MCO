********************
Last names: Gilo
Language: Ruby
Paradigm(s): OOP, Procedral, Imperative, Modular, Scripting
********************
require 'date'

# Constants
DEFAULT_SALARY = 500

# Day class
class Day
  attr_accessor :in_time, :out_time, :is_rest, :day_type

  def initialize(in_time = "0900", out_time = "1800", is_rest = false, day_type = "Normal Day")
    @in_time = in_time
    @out_time = out_time
    @is_rest = is_rest
    @day_type = day_type
  end
end

# Helper functions for validation
def is_valid_military_time(time_str)
  military_time_regex = /^([01]\d|2[0-3])([0-5]\d)$/
  !!military_time_regex.match(time_str)
end

def is_valid_day_type(day_type)
  valid_day_types = ["Normal Day", "SNWH", "RH"]
  valid_day_types.include?(day_type)
end

# Function to calculate hours
def calculate_hours(in_time, out_time)
  in_dt = DateTime.strptime(in_time, '%H%M')
  out_dt = DateTime.strptime(out_time, '%H%M')
  night_shift_start = 22
  night_shift_end = 6

  # Adjust out_dt if out time is on the next day
  out_dt += 1 if out_dt <= in_dt

  overtime_start = in_dt + Rational(9, 24)

  overtime_hours = 0
  overtime_night_shift_hours = 0
  regular_night_shift_hours = 0

  current_time = in_dt
  while current_time < out_dt
    if current_time >= overtime_start
      # Overtime calculation
      if current_time.hour >= night_shift_start || current_time.hour < night_shift_end
        overtime_night_shift_hours += 1
      else
        overtime_hours += 1
      end
    else
      # Regular hours calculation
      if current_time.hour >= night_shift_start || current_time.hour < night_shift_end
        regular_night_shift_hours += 1
      end
    end

    # Move to the next hour
    current_time += Rational(1, 24)
  end

  [overtime_hours, regular_night_shift_hours, overtime_night_shift_hours]
end

# Function to compute payroll
def compute_payroll(days)
  weekly_salary = 0.0

  days.each_with_index do |day, i|
    daily_salary = 0.0
    overtime_hours, regular_night_shift_hours, overtime_night_shift_hours = calculate_hours(day.in_time, day.out_time)
    puts "Day #{i + 1}:"

    if day.in_time == day.out_time && !day.is_rest
      puts "ABSENT"
    elsif day.in_time == day.out_time && day.is_rest
      puts "REST DAY"
    else
      puts " IN: #{day.in_time}\n OUT: #{day.out_time}\n DayType: #{day.day_type}\n IsRest: #{day.is_rest}"
      hourly_rate = DEFAULT_SALARY / 8.0

      # Base Salary Calculation
      base_salary = case day.day_type
                    when "Normal Day"
                      day.is_rest ? DEFAULT_SALARY * 1.3 : DEFAULT_SALARY
                    when "SNWH"
                      day.is_rest ? DEFAULT_SALARY * 1.5 : DEFAULT_SALARY * 1.3
                    when "RH"
                      day.is_rest ? DEFAULT_SALARY * 2.6 : DEFAULT_SALARY * 2
                    else
                      DEFAULT_SALARY # Default case
                    end

      puts "Base Salary: #{'%.2f' % base_salary}"
      daily_salary += base_salary

      # Overtime Calculation
      ot_rate = case day.day_type
                when "Normal Day"
                  day.is_rest ? hourly_rate * 1.69 : hourly_rate * 1.25
                when "SNWH"
                  day.is_rest ? hourly_rate * 1.95 : hourly_rate * 1.69
                when "RH"
                  day.is_rest ? hourly_rate * 3.38 : hourly_rate * 2.6
                else
                  hourly_rate # Default case for other day types
                end
      ot = overtime_hours * ot_rate
      if overtime_hours > 0
        puts "Overtime: #{'%.2f' % ot}"
        daily_salary += ot
      end

      # Night Shift Calculation
      ns_rate = hourly_rate * 1.10 # Regular night shift rate
      ns = regular_night_shift_hours * ns_rate
      if regular_night_shift_hours > 0
        puts "Night Shift: #{'%.2f' % ns}"
        daily_salary += ns
      end

      # Overtime Night Shift Calculation
      otns_rate = ot_rate * 1.10 # Overtime night shift rate
      otns = overtime_night_shift_hours * otns_rate
      if overtime_night_shift_hours > 0
        puts "Overtime Night Shift: #{'%.2f' % otns}"
        daily_salary += otns
      end

      puts "Daily Salary = #{'%.2f' % daily_salary}"
    end

    weekly_salary += daily_salary
    puts ""
  end

  puts "Weekly Salary: #{'%.2f' % weekly_salary}\nPayroll Generated"
end

# Function to modify configuration
def modify_configuration(days)
  loop do
    (1..7).each do |i|
      puts "#{i}) Day #{i}"
    end

    choice = gets.chomp.to_i

    break if choice == 0
    if choice < 1 || choice > 7
      puts "Invalid choice. Please enter a number between 1 and 7, or 0 to exit."
      next
    end

    day_index = choice - 1
    selected_day = days[day_index]

    puts "Selected Day #{choice}:\nIN: #{selected_day.in_time}\nOUT: #{selected_day.out_time}\nIsRest: #{selected_day.is_rest}\nDayType: #{selected_day.day_type}\n"

    loop do
      puts "Select property to modify:"
      puts "1) IN"
      puts "2) OUT"
      puts "3) IsRest"
      puts "4) DayType"
      puts "0) Back to main menu"

      sub_choice = gets.chomp.to_i

      break if sub_choice == 0
      case sub_choice
      when 1
        new_in = gets.chomp
        selected_day.in_time = new_in if is_valid_military_time(new_in)
      when 2
        new_out = gets.chomp
        selected_day.out_time = new_out if is_valid_military_time(new_out)
      when 3
        new_is_rest = gets.chomp.downcase
        selected_day.is_rest = (new_is_rest == "yes")
      when 4
        new_day_type = gets.chomp
        selected_day.day_type = new_day_type if is_valid_day_type(new_day_type)
      else
        puts "Invalid choice."
      end
    end
  end

  puts "Exiting Modify Configuration..."
end

# Main function
def main
  days = Array.new(7) { Day.new }

  (5..6).each do |i|
    days[i].is_rest = true
  end

  loop do
    puts "1) Generate Payroll"
    puts "2) Modify Configuration"
    puts "3) Exit"
    puts ""

    choice = gets.chomp.to_i
    puts ""

    case choice
    when 1
      compute_payroll(days)
    when 2
      modify_configuration(days)
    when 3
      puts "Exiting..."
      exit
    else
      puts "Invalid Choice. Please try again."
    end
  end
end

main if __FILE__ == $PROGRAM_NAME