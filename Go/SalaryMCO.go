package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
	"strconv"
	"strings"
)

// Default configurations
var (
	baseSalary         = 500.0
	maxHoursPerDay     = 8
	regularHoursPerDay = 8
	morningInHours     = 9
	morningOutHours    = 18
	nightInHours       = 22
	nightOutHours      = 6
)

// Reads and validates a float64 input from the user
func readDoubleInput(prompt string) float64 {
	fmt.Print(prompt)
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Scan()
	input := scanner.Text()
	value, err := strconv.ParseFloat(input, 64)

	if err != nil {
		fmt.Println("Invalid input. Please enter a valid number.")
		return readDoubleInput(prompt)
	}
	return value
}

// Reads and validates a integer input from the user
func readIntInput(prompt string) int {
	fmt.Print(prompt)
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Scan()
	input := scanner.Text()
	value, err := strconv.Atoi(input)

	if err != nil {
		fmt.Println("Invalid input. Please enter a valid number.")
		return readIntInput(prompt)
	}
	return value
}

// Modifies default configuration values
func modifyDefaultConfigurations() {
	fmt.Println("\n----------------------------------------")
	fmt.Println("      MODIFY DEFAULT CONFIGURATION")
	fmt.Println("----------------------------------------")
	baseSalary = readDoubleInput("Enter new base salary: ")
	maxHoursPerDay = readIntInput("Enter new max working hours per day: ")
	regularHoursPerDay = readIntInput("Enter new regular working hours per day: ")
	morningInHours = readIntInput("Enter new morning IN hours: ")
	morningOutHours = readIntInput("Enter new morning OUT hours: ")
	nightInHours = readIntInput("Enter new night IN hours: ")
	nightOutHours = readIntInput("Enter new night OUT hours: ")

	fmt.Println("Default Configurations Modified Successfully!!")
	fmt.Printf("New base salary: %.2f\n", baseSalary)
	fmt.Println("New max working hours per day:", maxHoursPerDay)
	fmt.Println("New regular working hours per day:", regularHoursPerDay)
	fmt.Println("New morning IN hours:", morningInHours)
	fmt.Println("New morning OUT hours:", morningOutHours)
	fmt.Println("New night IN hours:", nightInHours)
	fmt.Println("New night OUT hours:", nightOutHours)
}

// Calculates the salary based on the various parameters
func calculateSalary(
	isNormal, isRest, isHoliday, isSpecialNonWorking, isNightShift, isOvertime, isOvertimeNightShift bool,
	workedHours, nightShiftHours, overtimeHours, overtimeNightShiftHours int,
) float64 {
	// Calculate hourly rate based on base salary and max hours per day
	hourlyRate := baseSalary / float64(maxHoursPerDay)

	// Variables for different components
	var (
		salary, over, overOn, nightShift, restPaid, specialNonWorking, holidayPaid, restSpecial, holidaySpecial float64
	)

	if isNormal {
		// Normal work conditions
		if isNightShift {
			// Night shift with potential overtime
			if isOvertime {
				overOn = (hourlyRate * 1.375) * float64(overtimeNightShiftHours)
			}
			nightShift = (hourlyRate * 1.10) * float64(nightShiftHours)
		} else {
			// Regular hours with potential overtime
			if isOvertime {
				over = (hourlyRate * 1.25) * float64(overtimeHours)
			}
			if isOvertimeNightShift {
				overOn = (hourlyRate * 1.375) * float64(overtimeNightShiftHours)
			}
		}
	} else if isRest || isSpecialNonWorking {
		if isSpecialNonWorking && !isRest {
			if isNightShift {
				if isOvertime {
					over = (hourlyRate * 1.859) * float64(overtimeHours)
				}
			} else {
				if isOvertime {
					over = (hourlyRate * 1.69) * float64(overtimeHours)
				}
				if isOvertimeNightShift {
					overOn = (hourlyRate * 1.859) * float64(overtimeNightShiftHours)
				}
				fullSnw := baseSalary * 1.30
				snw := fullSnw - baseSalary
				specialNonWorking = snw
			}
		}

		if isRest && !isSpecialNonWorking {
			if isNightShift {
				if isOvertime {
					over = (hourlyRate * 1.859) * float64(overtimeHours)
				}
			} else {
				if isOvertime {
					over = (hourlyRate * 1.69) * float64(overtimeHours)
				}
				if isOvertimeNightShift {
					overOn = (hourlyRate * 1.859) * float64(overtimeNightShiftHours)
				}
				fullRp := baseSalary * 1.30
				rp := fullRp - baseSalary
				restPaid = rp
			}
		}

		if isRest && isSpecialNonWorking {
			if isNightShift {
				if isOvertime {
					over = (hourlyRate * 2.145) * float64(overtimeHours)
				}
			} else {
				if isOvertime {
					over = (hourlyRate * 1.95) * float64(overtimeHours)
				}
				if isOvertimeNightShift {
					overOn = (hourlyRate * 2.145) * float64(overtimeNightShiftHours)
				}
				fullRpsnw := baseSalary * 1.50
				rpsnw := fullRpsnw - baseSalary
				restSpecial = rpsnw
			}
		}
	} else if isHoliday || isRest {
		if !isRest && isHoliday {
			if isNightShift {
				if isOvertime {
					over = (hourlyRate * 2.86) * float64(overtimeHours)
				}
			} else {
				if isOvertime {
					over = (hourlyRate * 2.60) * float64(overtimeHours)
				}
				if isOvertimeNightShift {
					overOn = (hourlyRate * 2.86) * float64(overtimeNightShiftHours)
				}
				fullHol := baseSalary * 2.00
				hol := fullHol - baseSalary
				holidayPaid = hol
			}
		}

		if isRest && isHoliday {
			if isNightShift {
				if isOvertime {
					over = (hourlyRate * 3.718) * float64(overtimeHours)
				}
			} else {
				if isOvertime {
					over = (hourlyRate * 3.38) * float64(overtimeHours)
				}
				if isOvertimeNightShift {
					overOn = (hourlyRate * 3.718) * float64(overtimeNightShiftHours)
				}
				fullRphol := baseSalary * 2.50
				rphol := fullRphol - baseSalary
				holidaySpecial = rphol
			}
		}
	}

	salary = baseSalary + over + overOn + nightShift + restPaid + specialNonWorking + holidayPaid + restSpecial + holidaySpecial
	return round(salary, 2)
}

// Rounds the value to the specified number of decimal places
func round(value float64, decimals int) float64 {
	precision := 1.0
	for i := 0; i < decimals; i++ {
		precision *= 10
	}
	return math.Round(value*precision) / precision
}

// Returns the name of the day based on the day number
func getDayName(day int) string {
	days := []string{"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"}
	return days[day-1]
}

// Generates the payroll for the week based on user input
func generatePayroll() {
	var totalSalary float64 = 0.0
	scanner := bufio.NewScanner(os.Stdin)
	var inHours int

	for day := 1; day <= 7; day++ {
		var (
			isNormalDay             = false
			isRestDay               = false
			isHolidayDay            = false
			isSpecialNonWorkingDay  = false
			isNightShift            = false
			isOvertime              = false
			isOvertimeNightShift    = false
			workHours               int
			nightShiftHours         int
			overtimeHours           int
			overtimeNightShiftHours int
		)

		fmt.Printf("Did you work on day %d? Y/N: ", day)
		scanner.Scan()
		worked := strings.ToLower(scanner.Text())

		if worked == "y" {
			fmt.Printf("Was it a night shift? Y/N: ")
			scanner.Scan()
			nightShiftInput := strings.ToLower(scanner.Text())

			if nightShiftInput == "y" {
				isNightShift = true
				fmt.Printf("Enter your IN hours for the nightshift: ")
				scanner.Scan()
				inHoursInput := scanner.Text()
				inHours, _ = strconv.Atoi(inHoursInput)
			}

			if !isNightShift {
				inHours = 9
			}

			fmt.Printf("Enter you OUT hours for the day")
			var outHours int
			fmt.Scanln(&outHours)

			if outHours <= 12 && outHours >= 0 {
				outHours += 24
			}

			workHours = (outHours - 1) - inHours

			fmt.Printf("You worked %d hours. Is this correct? Y/N: ", workHours)
			var correctInput string
			fmt.Scanln(&correctInput)

			if strings.ToLower(correctInput) == "n" {
				fmt.Printf("Enter correct work hours for day %d: ", day)
				fmt.Scanln(&workHours)
			}

			if isNightShift {
				fmt.Printf("How many hours of night shift worked: ")
				fmt.Scanln(&nightShiftHours)
			}

			fmt.Printf("Was it a normal work day? Y/N: ")
			var normalInput string
			fmt.Scanln(&normalInput)

			if strings.ToLower(normalInput) == "y" {
				isNormalDay = true
			} else {
				fmt.Printf("was it a rest work day? Y/N: ")
				var restInput string
				fmt.Scanln(&restInput)

				if strings.ToLower(restInput) == "y" {
					isRestDay = true
				}

				fmt.Printf("Was it a holiday work day? Y/N: ")
				var holidayInput string
				fmt.Scanln(&holidayInput)

				if strings.ToLower(holidayInput) == "y" {
					isHolidayDay = true
				}

				fmt.Printf("Was it a special non-working work day? Y/N: ")
				var snwInput string
				fmt.Scanln(&snwInput)

				if strings.ToLower(snwInput) == "y" {
					isSpecialNonWorkingDay = true
				}
			}

			if workHours > maxHoursPerDay {
				fmt.Printf("Did you work overtime? Y/N: ")
				var overtimeInput string
				fmt.Scanln(&overtimeInput)

				if strings.ToLower(overtimeInput) == "y" {
					isOvertime = true
					fmt.Printf("How much over hours did you have: ")
					fmt.Scanln(&overtimeHours)

					fmt.Printf("Did you work nightshift overtime? Y/N: ")
					var onInput string
					fmt.Scanln(&onInput)

					if strings.ToLower(onInput) == "y" {
						isOvertimeNightShift = true
						fmt.Printf("How much overtime nightshift hours did you have: ")
						fmt.Scanln(&overtimeNightShiftHours)
					}
				}
			}

			dailySalary := calculateSalary(
				isNormalDay, isRestDay, isHolidayDay, isSpecialNonWorkingDay, isNightShift,
				isOvertime, isOvertimeNightShift, workHours, nightShiftHours, overtimeHours, overtimeNightShiftHours,
			)

			fmt.Printf("%s: %.2f\n\n", getDayName(day), dailySalary)
			totalSalary += dailySalary

			isNormalDay = false
			isRestDay = false
			isHolidayDay = false
			isSpecialNonWorkingDay = false
			isNightShift = false
			isOvertime = false
			isOvertimeNightShift = false
		} else {
			fmt.Printf("Was it a rest work day? Y/N: ")
			var isRestWorkDay string
			fmt.Scanln(&isRestWorkDay)

			dailySalary := 0.0

			if isRestWorkDay == "n" {
				dailySalary = 0.0
			}

			fmt.Printf("Day %d: Daily Salary - %.2f\n", day, dailySalary)
			totalSalary += dailySalary
		}
	}
	fmt.Printf("Total Salary - %.2f\n", totalSalary)
}

// Resets the configuration values back to the default
func reset() {
	baseSalary = 500.0
	maxHoursPerDay = 8
	regularHoursPerDay = 8
	morningInHours = 9
	morningOutHours = 18
	nightInHours = 22
	nightOutHours = 6
}

// Displays the current configurations
func displayConfigurations() {
	fmt.Println("\n----------------------------------------")
	fmt.Println("      CURRENT CONFIGURATIONS")
	fmt.Println("----------------------------------------")
	fmt.Printf("Base salary: %.2f\n", baseSalary)
	fmt.Println("Max working hours per day:", maxHoursPerDay)
	fmt.Printf("Regular working hours per day: %d\n", regularHoursPerDay)
	fmt.Printf("Morning IN hours: %d\n", morningInHours)
	fmt.Printf("Morning OUT hours: %d\n", morningOutHours)
	fmt.Printf("Night IN hours: %d\n", nightInHours)
	fmt.Printf("Night OUT hours: %d\n", nightOutHours)
}

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	for {
		fmt.Println("\n----------------------------------------")
		fmt.Println("      MAIN MENU")
		fmt.Println("----------------------------------------")
		fmt.Println("1. See current configurations")
		fmt.Println("2. Modify configurations")
		fmt.Println("3. Reset to default configurations")
		fmt.Println("4. Generate payroll")
		fmt.Println("5. Exit")

		fmt.Print("Enter your choice: ")
		scanner.Scan()
		choice := scanner.Text()

		switch choice {
		case "1":
			displayConfigurations()
		case "2":
			modifyDefaultConfigurations()
		case "3":
			reset()
		case "4":
			generatePayroll()
		case "5":
			fmt.Println("Exiting Program...")
			return
		default:
			fmt.Println("Invalid choice. Please try again.")
		}
	}
}
