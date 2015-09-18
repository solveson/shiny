## ui.R
## https://solveson.shinyapps.io/shiney_project

# strat   <- 'or'   
# b_limit <- 5
# s_limit <- 2
# reps    <- 1000

shinyUI(pageWithSidebar(
  headerPanel('Zombie Dice Strategy Simulator'),
  
  sidebarPanel(
    h3('Pass when you reach'),
    numericInput('s_limit', 'Shotgun Blast(s)', 1, min=1, max= 2  ),
    selectInput( 'strat',   'AND / OR ',        c('and','or'),'or'),
    numericInput('b_limit', 'Brains',           5, min=1, max=13  ),
    
    helpText("In the next box you select how many"),
    # numericInput('reps',    'Turns to Simulate', 100, min=50, max=500, step=50),
    sliderInput('reps',     'Turns to Simulate', min=50, max=500, value=100, step=25, 
                round = FALSE, ticks = TRUE, 
                animate = FALSE, width = NULL, sep = ",", pre = NULL, post = NULL),
    
    submitButton(text = "Caclulate Mean Brains", icon = NULL)
  ),
  
  mainPanel(
    h5(paste0(
      "This app simulates playing many turns of Zombie Dice (ZD).",
      " You-a Zombie-roll sets of 3 dice. Possible results",
      " are brains (your goal), shotgun blasts (which hurt), or runners",
      " (which you may reroll).  Your turn ends when you",
      " A) get shot 3 times, B) roll all 13 dice, or C) pass.",
      " You set the number of blasts or brains whereupon",
      " you will pass.  The AND/OR box allows you to pass upon reaching either", 
      " limit (OR), or both limits (AND).  You can also select how many turns to",
      " simulate.  Your goal is to discover the",
      " strategy that gets you the most brains!"
    )),
    plotOutput('zd_plot')
  )
))
