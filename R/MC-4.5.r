# Given defaults
daily <- 500
max_hours <- 8
reg_hours <- 8
in_hours_morning <- 9
out_hours_morning <- 18
in_hours_night <- 22
out_hours_night <- 6
night_shift <- FALSE
overtime <- FALSE
over_time <- 0.00
over_hours <- 0
over <- 0
salary <- 0
# Function to modify default configuration
modify_default_configuration <- function() {
  cat("\nModify Default Configuration:\n")
  
  # Get user input for new values
  new_daily <- as.numeric(readline("Enter new daily salary: "))
  new_max_hours <- as.numeric(readline("Enter new maximum regular hours: "))
  new_reg_hours <- as.numeric(readline("Enter new regular hours per day: "))
  new_in_hours <- as.numeric(readline("Enter new IN hours per day: "))
  
  
  # Update the global variables
  daily <<- new_daily
  max_hours <<- new_max_hours
  reg_hours <<- new_reg_hours
  in_hours <<- new_in_hours
  
  # Display a confirmation message
  cat("Default configuration modified successfully!\n")
  cat("New daily salary:", daily, "\n")
  cat("New maximum regular hours:", max_hours, "\n")
  cat("New regular hours per day:", reg_hours, "\n")
  cat("New IN hours per day:", in_hours, "\n")
}

# Function to generate weekly payroll
generate_weekly_payroll <- function() {
  # Your logic for generating payroll goes here
  
  in_hours <- as.numeric(readline("Enter IN hours"))
  out_hours <- as.numeric(readline("Enter OUT hours"))
  
  #check in_hours if nightshift
  if(in_hours == in_hours_night) {
    night_shift <<- TRUE
  }
  #check in_hours if overtime
  #18- 1 = 17 - 9 = 8
  if(((out_hours - 1) - in_hours) > max_hours){ 
    overtime <<- TRUE
    over_hours <<- ((out_hours - 1) - in_hours) - max_hours
  }
  normal_ask <- readline("Was it a normal work day? Y/N: ")
  night_ask <- readline("Was it night shift? Y/N: ")
  
  if(normal_ask == 'Y'){
    if(overtime){ over_time <<- 1.25 }
    
    over <<- ((daily/max_hours) * over_time) * over_hours
    
    salary <<- daily + over
      
  }
  else{
    rest_ask <- readline("Was it a normal work day Y/N:")
    
    if(normal_ask == 'Y'){
      if(overtime){ over_time <<- 1.25 }
      
      over <<- ((daily/max_hours) * over_time) * over_hours
      
      salary <<- daily + over
      
    }
    
  }
  
  
  
  cat("\nGenerating Weekly Payroll...\n")
  
  cat("Salary:")
  #print(daily)
  print(salary)
  }

# Function to display the menu
menu <- function() {
  
  choice <- 0
  
  while (choice != 3) {
    
    menu_display()
    
    # Get user input for menu choice
    choice <- as.character(readline("Enter your choice (1-3): "))
    
    # Perform corresponding action based on user choice
    switch(choice,
           "1" = generate_weekly_payroll(),
           "2" = modify_default_configuration(),
           "3" = {
             cat("Exiting Payroll System. Goodbye!\n")
           },
           {
             cat("Invalid choice. Please enter a number between 1 and 3.\n")
           }
    )
  }
}

# Function to display the menu options
menu_display <- function() {
  cat("\nPayroll System Menu:\n")
  cat("1. Generate Weekly Payroll\n")
  cat("2. Modify Default Configuration\n")
  cat("3. Exit\n")
}

# Run the menu
menu()

