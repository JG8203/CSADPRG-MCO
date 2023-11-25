require 'date'

class Day
  attr_accessor :in_time, :out_time, :is_rest, :day_type

  def initialize(in_time = "0900", out_time = "2300", is_rest = true, day_type = "SNWH")
    @in_time = in_time
    @out_time = out_time
    @is_rest = is_rest
    @day_type = day_type
  end

  def to_s
    if @in_time != @out_time
      "IN: #{@in_time}, OUT: #{@out_time}, IsRest: #{@is_rest}, DayType: #{@day_type}"
    else
      "Absent."
    end
  end
end

module TimeHelper
  def self.is_valid_military_time(time_str)
    military_time_regex = /^([01]\d|2[0-3])([0-5]\d)$/
    !!military_time_regex.match(time_str)
  end

  def self.parse_time(time_str)
    DateTime.strptime(time_str, '%H%M')
  end

  def self.calculate_hours(in_time, out_time)
    in_dt = DateTime.strptime(in_time, '%H%M')
    out_dt = DateTime.strptime(out_time, '%H%M')
    # Define night shift hours using DateTime objects
    night_shift_start = DateTime.strptime("2200", '%H%M').hour
    night_shift_end = DateTime.strptime("0600", '%H%M').hour
    # Define overtime start as 9 hours after in_time
    overtime_start = in_dt + Rational(9, 24)

    # Adjust out_dt if out time is on the next day
    out_dt += 1 if out_dt < in_dt

    # Initialize counters for different types of hours
    overtime_hours = 0
    regular_night_shift_hours = 0
    overtime_night_shift_hours = 0

    # Iterate over each hour from in_time to out_time
    current_time = in_dt
    while current_time < out_dt
      hour_of_day = current_time.hour
      # Determine if current hour is during night shift
      is_night_shift = hour_of_day >= night_shift_start || hour_of_day < night_shift_end
      # Determine if current hour is overtime
      is_overtime = current_time >= overtime_start

      # Increment counters based on whether it's night shift, overtime, or both
      if is_night_shift
        if is_overtime
          overtime_night_shift_hours += 1
        else
          regular_night_shift_hours += 1
        end
      elsif is_overtime
        overtime_hours += 1
      end

      # Move to the next hour
      current_time += Rational(1, 24)
    end

    # Return an array with the counted hours
    [overtime_hours, regular_night_shift_hours, overtime_night_shift_hours]
  end
end

class SalaryCalculator
  DEFAULT_SALARY = 500

  def initialize(hourly_rate = DEFAULT_SALARY / 8.0)
    @hourly_rate = hourly_rate
  end

  def calculate_daily_salary(day)
    overtime_hours, regular_night_shift_hours, overtime_night_shift_hours = TimeHelper.calculate_hours(day.in_time, day.out_time)
    base_salary = calculate_base_salary(day)
    ot_rate, otns_rate = calculate_overtime_rates(day)

    ot_salary = overtime_hours * @hourly_rate * ot_rate
    ns_salary = regular_night_shift_hours * @hourly_rate * 1.10 # Night shift rate
    otns_salary = overtime_night_shift_hours * @hourly_rate * otns_rate

    base_salary + ot_salary + ns_salary + otns_salary
  end

  private

  def calculate_base_salary(day)
    # Calculate base salary based on day type and rest day
    case day.day_type
    when "Normal Day"
      day.is_rest ? DEFAULT_SALARY * 1.3 : DEFAULT_SALARY
    when "SNWH"
      day.is_rest ? DEFAULT_SALARY * 1.5 : DEFAULT_SALARY * 1.3
    when "RH"
      day.is_rest ? DEFAULT_SALARY * 2.6 : DEFAULT_SALARY * 2
    else
      DEFAULT_SALARY
    end
  end

  def calculate_overtime_rates(day)
    # Calculate overtime rates based on day type, rest day, and night shift
    case day.day_type
    when "Normal Day"
      [1.25, 1.375] # 125% for OT, 137.5% for OT Night Shift
    when "SNWH"
      if day.is_rest
        [1.95, 2.145] # 195% for OT, 214.5% for OT Night Shift if Rest Day
      else
        [1.69, 1.859] # 169% for OT, 185.9% for OT Night Shift otherwise
      end
    when "RH"
      if day.is_rest
        [3.38, 3.718] # 338% for OT, 371.8% for OT Night Shift if Rest Day
      else
        [2.6, 2.86] # 260% for OT, 286% for OT Night Shift otherwise
      end
    else
      [1.25, 1.375] # Default overtime rates for other day types
    end
  end
end

class Payroll
  attr_accessor :days, :salary_calculator

  def initialize(days, salary_calculator)
    @days = days
    @salary_calculator = salary_calculator
  end

  def generate_report
    puts "Payroll Report"
    puts "--------------"
    total_salary = 0.0

    @days.each_with_index do |day, index|
      if day.in_time != day.out_time
        daily_salary = @salary_calculator.calculate_daily_salary(day)
      else
        daily_salary = 0
      end
      total_salary += daily_salary
      puts "Day #{index + 1}: #{day}"
      puts "Daily Salary: #{format('%.2f', daily_salary)}"
      puts ""
    end

    puts "Total Weekly Salary: #{format('%.2f', total_salary)}"
  end
end

class ConfigurationModifier
  attr_accessor :days

  def initialize(days)
    @days = days
  end

  def display_day_menu(day)
    puts "Selected Day: #{day}"
    puts "1) Modify IN time"
    puts "2) Modify OUT time"
    puts "3) Toggle IsRest"
    puts "4) Change DayType"
    puts "0) Back to main menu"
  end

  def modify_day(day)
    display_day_menu(day)

    choice = gets.chomp.to_i
    case choice
    when 1
      puts "Enter new IN time (HHMM):"
      new_in = gets.chomp
      day.in_time = new_in if TimeHelper.is_valid_military_time(new_in)
    when 2
      puts "Enter new OUT time (HHMM):"
      new_out = gets.chomp
      day.out_time = new_out if TimeHelper.is_valid_military_time(new_out)
    when 3
      day.is_rest = !day.is_rest
    when 4
      puts "Enter new Day Type (#{DayType::NORMAL_DAY}, #{DayType::SNWH}, #{DayType::RH}):"
      new_day_type = gets.chomp
      day.day_type = new_day_type if DayType.is_valid_day_type(new_day_type)
    when 0
    else
      puts "Invalid choice."
    end
  end

  def run
    (1..@days.length).each do |i|
      puts "#{i}) Day #{i}"
    end
    puts "0) Back to main menu"

    choice = gets.chomp.to_i
    return if choice == 0

    if choice < 1 || choice > @days.length
      puts "Invalid choice. Please enter a valid number."
    else
      modify_day(@days[choice - 1])
    end
  end
end

class UserInterface
  attr_accessor :payroll

  def initialize(payroll)
    @payroll = payroll
  end

  def display_main_menu
    puts "1) Generate Payroll Report"
    puts "2) Modify Configuration"
    puts "3) Exit"
  end

  def handle_payroll_generation
    @payroll.generate_report
  end

  def handle_configuration_modification
    configuration_modifier = ConfigurationModifier.new(@payroll.days)
    configuration_modifier.run
  end

  def run
    loop do
      display_main_menu
      choice = gets.chomp.to_i

      case choice
      when 1
        handle_payroll_generation
      when 2
        handle_configuration_modification
      when 3
        puts "Exiting..."
        break
      else
        puts "Invalid choice. Please try again."
      end
    end
  end
end

def main
  days = Array.new(7) { Day.new }
  salary_calculator = SalaryCalculator.new
  payroll = Payroll.new(days, salary_calculator)
  ui = UserInterface.new(payroll)
  ui.run
end

main if __FILE__ == $PROGRAM_NAME
