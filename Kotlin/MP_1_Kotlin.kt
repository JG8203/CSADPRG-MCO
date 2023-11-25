/********************
#Last names: Arguelles, Atanacio, Gilo, Paguiligan
#Language: Kotlin
#Paradigm(s): Functional, Imperative, Object-oriented, or Procedural programming
********************/

import java.util.*

var daily = 500.0
var maxHours = 8
var regHours = 8
var inHours = 9
var outHoursMorning = 18
var inHoursNight = 22
var outHoursNight = 6

fun modifyDefaultConfiguration() {
    println("\nModify Default Configuration:")

    val scanner = Scanner(System.`in`)

    // Get user input for new values
    print("Enter new daily salary: ")
    daily = scanner.nextDouble()
    print("Enter new maximum regular hours: ")
    maxHours = scanner.nextInt()
    print("Enter new regular hours per day: ")
    regHours = scanner.nextInt()
    print("Enter new IN hours per day (morning): ")
    inHours = scanner.nextInt()
    print("Enter new OUT hours per day (morning): ")
    outHoursMorning = scanner.nextInt()
    print("Enter new IN hours per day (night): ")
    inHoursNight = scanner.nextInt()
    print("Enter new OUT hours per day (night): ")
    outHoursNight = scanner.nextInt()

    // Display a confirmation message
    println("Default configuration modified successfully!")
    println("New daily salary: $daily")
    println("New maximum regular hours: $maxHours")
    println("New regular hours per day: $regHours")
    println("New IN hours per day (morning): $inHours")
    println("New OUT hours per day (morning): $outHoursMorning")
    println("New IN hours per day (night): $inHoursNight")
    println("New OUT hours per day (night): $outHoursNight")
}

fun resetValues() {
    daily = 500.0
    maxHours = 8
    regHours = 8
    inHours = 9
    outHoursMorning = 18
    inHoursNight = 22
    outHoursNight = 6
}

fun calculateSalary(
    norm: Boolean, rest: Boolean, holiday: Boolean, isSnw: Boolean, nightShift: Boolean,
    overtime: Boolean, on: Boolean, workHours: Int, nightHours: Int, overHours: Int, onsHours: Int
): Double {
    val hourly = daily / maxHours

    var salary = 0.0
    var over = 0.0
    var overOn = 0.0
    var ns = 0.0
    var rp = 0.0
    var snw = 0.0
    var hol = 0.0
    var rpsnw = 0.0
    var rphol = 0.0

    if (norm) {
        if (nightShift) {
            if (overtime) overOn = (hourly * 1.375) * onsHours
            ns = (hourly * 1.10) * nightHours
        } else {
            if (overtime) over = (hourly * 1.25) * overHours
            if (on) overOn = (hourly * 1.375) * onsHours
        }
    } else if (rest || isSnw) {
        if (isSnw && !rest) {
            if (nightShift) {
                if (overtime) over = (hourly * 1.859) * overHours
            } else {
                if (overtime) over = (hourly * 1.69) * overHours
                if (on) overOn = (hourly * 1.859) * onsHours
                val fullSnw = daily * 1.30
                snw = fullSnw - daily
            }
        }
        if (rest && !isSnw) {
            if (nightShift) {
                if (overtime) over = (hourly * 1.859) * overHours
            } else {
                if (overtime) over = (hourly * 1.69) * overHours
                if (on) overOn = (hourly * 1.859) * onsHours
                val fullRp = daily * 1.30
                rp = fullRp - daily
            }
        }
        if (rest && isSnw) {
            if (nightShift) {
                if (overtime) over = (hourly * 2.145) * overHours
            } else {
                if (overtime) over = (hourly * 1.95) * overHours
                if (on) overOn = (hourly * 2.145) * onsHours
                val fullRpsnw = daily * 1.50
                rpsnw = fullRpsnw - daily
            }
        }
    } else if (holiday || rest) {
        if (!rest && holiday) {
            if (nightShift) {
                if (overtime) over = (hourly * 2.86) * overHours
            } else {
                if (overtime) over = (hourly * 2.60) * overHours
                if (on) overOn = (hourly * 2.86) * onsHours
                val fullHol = daily * 2.00
                hol = fullHol - daily
            }
        }
        if (rest && holiday) {
            if (nightShift) {
                if (overtime) over = (hourly * 3.718) * overHours
            } else {
                if (overtime) over = (hourly * 3.38) * overHours
                if (on) overOn = (hourly * 3.718) * onsHours
                val fullRphol = daily * 2.60
                rphol = fullRphol - daily
            }
        }
    }

    salary = daily + over + overOn + ns + rp + snw + hol + rpsnw + rphol
    return salary.round(2)
}

fun Double.round(decimals: Int): Double {
    var multiplier = 1.0
    repeat(decimals) { multiplier *= 10 }
    return kotlin.math.round(this * multiplier) / multiplier
}

fun generateWeeklyPayroll() {
    var totalSalary = 0.0

    val scanner = Scanner(System.`in`)

    for (day in 1..7) {
        var norm = false
        var rest = false
        var holiday = false
        var snw = false
        var nightShift = false
        var overtime = false
        var on = false
        var workHours = 0
        var nightHours = 0
        var overHours = 0
        var onsHours = 0

        print("Did you work on $day? Y/N: ")
        val worked = scanner.next().toLowerCase()

        if (worked == "y") {
            print("Was it night shift? Y/N: ")
            if (scanner.next().toLowerCase() == "y") {
                nightShift = true
                print("Enter your IN hours for this nightshift: ")
                inHours = scanner.nextInt()
            }
            if (!nightShift) {
                inHours = 9
            }

            print("Enter OUT hours for day $day: ")
            var outHours = scanner.nextInt()

            if (outHours <= 12 && outHours >= 0) {
                outHours += 24
            }
            workHours = (outHours - 1) - inHours

            print("You worked $workHours hours. Is this correct? Y/N: ")
            if (scanner.next().toLowerCase() == "n") {
                print("Enter correct work hours for day $day: ")
                workHours = scanner.nextInt()
            }

            if (nightShift) {
                print("How many hours of nightshift worked: ")
                nightHours = scanner.nextInt()
            }

            print("Was it a normal work day? Y/N: ")
            if (scanner.next().toLowerCase() == "y") {
                norm = true
            } else {
                print("Was it a rest work day? Y/N:")
                if (scanner.next().toLowerCase() == "y") {
                    rest = true
                }
                print("Was it a holiday work day? Y/N: ")
                if (scanner.next().toLowerCase() == "y") {
                    holiday = true
                }
                print("Was it a special non-working work day? Y/N: ")
                if (scanner.next().toLowerCase() == "y") {
                    snw = true
                }
            }

            if (workHours > maxHours) {
                print("Did you work overtime? Y/N: ")
                if (scanner.next().toLowerCase() == "y") {
                    overtime = true
                    print("How much overtime hours did you have: ")
                    overHours = scanner.nextInt()

                    print("Did you work nightshift overtime? Y/N:")
                    if (scanner.next().toLowerCase() == "y") {
                        on = true
                        print("How much overtime nightshift hours did you have: ")
                        onsHours = scanner.nextInt()
                    }
                }
            }

            val dailySalary = calculateSalary(
                norm, rest, holiday, snw, nightShift, overtime, on, workHours, nightHours, overHours, onsHours
            )

            println("Day $day: Daily Salary - $dailySalary")
            totalSalary += dailySalary

            norm = false
            rest = false
            holiday = false
            snw = false
            nightShift = false
            overtime = false
            on = false
        } else {
            print("Was it a rest work day? Y/N:")
            val restAsk = scanner.next().toLowerCase()
            val dailySalary = if (restAsk == "n") 0.0 else daily
            println("Day $day: Daily Salary - $dailySalary")
            totalSalary += dailySalary
        }
    }

    println("\nTotal Weekly Salary: $totalSalary")
}

fun menu() {
    var choice: String

    val scanner = Scanner(System.`in`)

    do {
        menuDisplay()
        try {
            print("Enter your choice (1-4): ")
            choice = scanner.next()

            when (choice) {
                "1" -> generateWeeklyPayroll()
                "2" -> resetValues()
                "3" -> modifyDefaultConfiguration()
                "4" -> println("Exiting Payroll System. Goodbye!")
                else -> println("Invalid choice. Please enter a number between 1 and 4.")
            }
        } catch (e: NoSuchElementException) {
            // Handle the exception, for example, print an error message
            println("Error reading input. Please try again.")
            // Clear the buffer
            scanner.nextLine()
            // Set a default value for choice to avoid an infinite loop
            choice = "-1"
        }
    } while (choice != "4")
}


fun menuDisplay() {
    println("\nPayroll System Menu:")
    println("1. Generate Weekly Payroll")
    println("2. Reset Default Configuration")
    println("3. Modify Default Configuration")
    println("4. Exit")
}

fun main() {
    menu()
}

