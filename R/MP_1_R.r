#********************
#Last names: Arguelles, Atanacio, Gilo, Paguiligan
#Language: R
#Paradigm(s): functional
#********************

# Given defaults
daily <- 500
max_hours <- 8
reg_hours <- 8
in_hours <- 9
out_hours_morning <- 18
in_hours_night <- 22
out_hours_night <- 6

# Function to modify default configuration
modify_default_configuration <- function() {
  cat("\nModify Default Configuration:\n")
  
  # Get user input for new values
  new_daily <- as.numeric(readline("Enter new daily salary: "))
  new_max_hours <- as.numeric(readline("Enter new maximum regular hours: "))
  new_reg_hours <- as.numeric(readline("Enter new regular hours per day: "))
  new_in_hours_morning <- as.numeric(readline("Enter new IN hours per day (morning): "))
  new_out_hours_morning <- as.numeric(readline("Enter new OUT hours per day (morning): "))
  new_in_hours_night <- as.numeric(readline("Enter new IN hours per day (night): "))
  new_out_hours_night <- as.numeric(readline("Enter new OUT hours per day (night): "))
  
  # Update the global variables
  daily <<- new_daily
  max_hours <<- new_max_hours
  reg_hours <<- new_reg_hours
  in_hours_morning <<- new_in_hours_morning
  out_hours_morning <<- new_out_hours_morning
  in_hours_night <<- new_in_hours_night
  out_hours_night <<- new_out_hours_night
  
  # Display a confirmation message
  cat("Default configuration modified successfully!\n")
  cat("New daily salary:", daily, "\n")
  cat("New maximum regular hours:", max_hours, "\n")
  cat("New regular hours per day:", reg_hours, "\n")
  cat("New IN hours per day (morning):", in_hours_morning, "\n")
  cat("New OUT hours per day (morning):", out_hours_morning, "\n")
  cat("New IN hours per day (night):", in_hours_night, "\n")
  cat("New OUT hours per day (night):", out_hours_night, "\n")
}

#reset function
reset_values <- function() {
  daily <<- 500
  max_hours <<- 8
  reg_hours <<- 8
  in_hours <<- 9
  out_hours_morning <<- 18
  in_hours_night <<- 22
  out_hours_night <<- 6

}

#Calculations
calculate_salary <- function(norm, rest, holiday, is_snw, night_shift, overtime, on, work_hours, night_hours, over_hours, ons_hours){
  hourly <- daily / max_hours
  # Initialize additional pay
  salary <- 0
  #normal <- 0
  over <- 0.0  
  over_on <- 0.0
  ns <- 0.0
  rp <- 0.0
  snw <- 0.0
  hol <- 0.0
  rpsnw <- 0.0
  rphol <- 0.0
  
  #check for the different types of days
  #normal version
  if(norm){
    
    #coumputes normal nightshift hours worked
    if(night_shift){ 
      if (overtime) {over_on <<- (hourly * 1.375) * ons_hours }
      ns <- (hourly * 1.10) * night_hours  
    }
    #not nightshift
    else{
      if(overtime){over <- (hourly * 1.25) * over_hours }
      if (on) {over_on <- (hourly * 1.375) * ons_hours  }
    }
    #normal <- 500
    
  }
  
  #rest or snw:>
  else if(rest || is_snw){
    
    #only snw
    if(is_snw && !rest){
      if(night_shift){
        if(overtime){over <- (hourly * 1.859) * over_hours }
      }
      else{
        if(overtime){over <- (hourly * 1.69) * over_hours}
        if(on){over_on <- (hourly * 1.859) * ons_hours}
        full_snw <- (daily * 1.30)
        snw <- full_snw - daily
      }
    }
    
    #only rest
    if(rest && !is_snw){
      if(night_shift){
        if(overtime){over <- (hourly * 1.859) * over_hours }
      }
      else{
        if(overtime){over <- (hourly * 1.69) * over_hours}
        if(on){over_on <- (hourly * 1.859) * ons_hours}
        full_rp <- (daily * 1.30)
        rp <- full_rp - daily
      }
    }
    
    #both
    if(rest && is_snw){
      if(night_shift){
        if(overtime){over <- (hourly * 2.145) * over_hours }
      }
      else{
        if(overtime){over <- (hourly * 1.95) * over_hours}
        if(on){over_on <- (hourly * 2.145) * ons_hours}
        full_rpsnw <- (daily * 1.50)
        rpsnw <- full_rpsnw - daily
      }
    }
  }
  #
  else if(holiday || rest){
    if(!rest && holiday){
      if(night_shift){
        if(overtime){over <- (hourly * 2.86) * over_hours }
      }
      else{
        if(overtime){over <- (hourly * 2.60) * over_hours}
        if(on){over_on <- (hourly * 2.86) * ons_hours}
        full_hol <- (daily * 2.00)
        hol <- full_hol - daily
      }
    }
    if(rest && holiday){
      if(night_shift){
        if(overtime){over <- (hourly * 3.718) * over_hours }
      }
      else{
        if(overtime){over <- (hourly * 3.38) * over_hours}
        if(on){over_on <- (hourly * 3.718) * ons_hours}
        full_rphol <- (daily * 2.60)
        rphol <- full_rphol - daily
      }
    }
  }
  #daily is normal pay without overtime :D
  salary <- daily + over + over_on + ns + rp + snw + hol + rpsnw + rphol
  return(round(salary, 2))
  
}

#Generate Weeklky Payroll
generate_weekly_payroll <- function() {
  total_salary <- 0
  
  # Allow the user to input IN and OUT times for each day and calculate daily salary
  for (day in 1:7) {
    
    #Initilazation of boolean
    norm <- FALSE
    rest <- FALSE
    holiday <- FALSE
    snw <- FALSE
    night_shift <- FALSE
    overtime <- FALSE
    on <- FALSE
    
    #Check if they worked
    worked <- readline(paste("Did you work on", day,"? Y/N: "))
    if(worked == 'Y' || worked == 'y'){
      
      #Check if Nightshift (or just not morning shift cuz you can come in anytime)
      night_ask <- readline("Was it night shift? Y/N: ")
      if (night_ask == 'Y' || night_ask == 'y')  {    
        night_shift <- TRUE
        new_in <- as.numeric(readline("Enter your IN hours for this nightshift: "))
        in_hours <- new_in
      }
      if(night_ask == 'N' || night_ask == 'n'){in_hours <- 9   }
      
      #Ask for out hours then compute if need
      out_hours <- as.numeric(readline(paste("Enter OUT hours for day", day, ": ")))
      
      #Computing if worked til dawn was taken too seriously :D
      if(out_hours <= 12 && out_hours >= 0){
        new_out <- out_hours + 24
        out_hours <- new_out
      }
      work_hours <- (out_hours - 1) - in_hours
      
      #confirm work hours
      confirm <- readline(paste("You worked this many hours ", work_hours, " Y/N: "))
      if(confirm == 'N' || confirm == 'n'){ work_hours <- as.numeric(readline(paste("Enter correct work hours for day ", day, ": "))) }
      
      #clarify nightshift hours
      if (night_ask == 'Y' || night_ask == 'y')  {    
        night_hours <- as.numeric(readline("How many hours of nightshift worked: "))
      }
      
      
      
      #Ask if normal day
      normal_ask <- readline("Was it a normal work day? Y/N: ")
      
      #if norm move on
      if(normal_ask == 'Y' || normal_ask == 'y'){norm <- TRUE}
      
      #other days
      else{
        rest_ask <- readline("Was it a rest work day? Y/N:")
        if (rest_ask == 'Y' || rest_ask == 'y')   {    rest <- TRUE         }
        
        holi_ask <- readline("Was it a holiday work day? Y/N: ")
        if (holi_ask == 'Y' || holi_ask == 'y')   {    holiday <- TRUE      }
        
        SNW_ask <- readline("Was it a special non-working work day? Y/N: ")
        if (SNW_ask == 'Y' || SNW_ask == 'y')    {    snw <- TRUE          }
      }
      
      #check work hours if there is overtime
      if(work_hours > max_hours){
        
        #overtime
        over_ask <- readline("Did you work overtime? Y/N: ")
        
        #nightshift overtime
        if (over_ask == 'Y' || over_ask == 'y') {
          overtime <- TRUE
          over_hours <- as.numeric(readline("How much overtime hours did you have: "))
          
          on_ask <- readline("Did you work nightshift overtime? Y/N:")
          if(on_ask == 'Y' || on_ask == 'y'){
            on <- TRUE
            ons_hours <-  as.numeric(readline("How much overtime nightshift hours did you have: "))
          }
        }
      }
      
      #daily_salary comp
      daily_salary <- calculate_salary(norm, rest, holiday, snw, night_shift, overtime, on, work_hours, night_hours, over_hours, ons_hours)
    
    }
    #Check absent or rest absent no pay rest with pay
    else{
     rest_ask <- readline("Was it a rest work day? Y/N:")
     if(rest_ask == 'N' || rest_ask == 'n'){ daily_salary <- 0}
     else{ daily_salary <- daily}
    }
    
    cat("Day", day, ": Daily Salary -", daily_salary, "\n")
    total_salary <- total_salary + daily_salary
    
    #reset values
    
    norm <- FALSE
    rest <- FALSE
    holiday <- FALSE
    snw <- FALSE
    night_shift <- FALSE
    overtime <- FALSE
    on <- FALSE
  }
  
  cat("\nTotal Weekly Salary:", total_salary, "\n")
  
}

menu <- function() {
  choice <- 0
  
  while (choice != 4) {
    menu_display()
    
    # Get user input for menu choice
    choice <- as.character(readline("Enter your choice (1-4): "))
    
    # Perform corresponding action based on user choice
    switch(choice,
           "1" = generate_weekly_payroll(),
           "2" = reset_values(),
           "3" = modify_default_configuration(),
           "4" = {
             cat("Exiting Payroll System. Goodbye!\n")
           },
           {
             cat("Invalid choice. Please enter a number between 1 and 4.\n")
           }
    )
  }
}

# Function to display the menu options
menu_display <- function() {
  cat("\nPayroll System Menu:\n")
  cat("1. Generate Weekly Payroll\n")
  cat("2. Reset Default Configuration\n")
  cat("3. Modify Default Configuration\n")
  cat("4. Exit\n")
}

# Run the menu
menu()

