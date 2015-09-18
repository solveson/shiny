## server.R

### UDF: Roll a die and return the upright face
roll <- function(die){
  if (die=='G') {f <- c(rep('runner',2), rep('brain',3), rep('shotgun',1))}
  if (die=='Y') {f <- c(rep('runner',2), rep('brain',2), rep('shotgun',2))}
  if (die=='R') {f <- c(rep('runner',2), rep('brain',1), rep('shotgun',3))}
  
  face <- sample(f, 1, replace=FALSE)
  return(face)
}


### UDF: Play a turn of Zombie Dice with a given strategy
zd_turn <- function(strategy, brain_limit, shotgun_limit){
  
  ### Set up the turn, which consists of zero or more rolls
  # set.seed(43)  # Use only during development
  # Order in which dice will appear. Color is the only factor
  die_color <- sample(c(rep('G',6), rep('Y',4), rep('R',3)), 13, replace=FALSE)
  # If a die has not rolled to brain or shotgun, it is in play
  die_face  <- rep('runner', 13)
  # Counters and status variables
  nDrawn <- 0;     nBrain <- 0;   nShotgun <- 0;
  status <- 'live'
  
  ### While alive (Or at least as alive as a Zombie can be) ...
  while(status=='live') {
    
    ## Employ the chosen strategy to roll or pass
    ## break ends the turn, which is a 'pass'
    if (strategy=='and' & 
        nShotgun>=shotgun_limit & nBrain>=brain_limit)   { break }
    
    if (strategy=='or' & 
        (nShotgun>=shotgun_limit | nBrain >=brain_limit)) { break }
    
    ## Try to get three dice, include runners already on table
    if (nDrawn==0) {
      nDrawn <- 3
    } else {
      nRunner <- sum(die_face[1:nDrawn]=='runner') ;
      nDrawn  <- min((3-nRunner)+nDrawn, 13) ;
    }
    dice <- die_color[die_face=='runner' & 1:13<=nDrawn]
    
    ## Roll each die. There are usually three dice, but may be less in a 
    ##  high scoring turn.  length(dice) returns number of dice available.
    ## I used tryCatch to discover this condition.
    faces <- rep('unk', length(dice))
    tryCatch(
      { for (i in 1:length(dice)) { faces[i] <- roll(dice[i]) } },
      error=function(cond) {
        message(paste("Number Drawn:", nDrawn))
        message(paste("Dice:",  dice     , "   "))
        message(paste("Color:", die_color, "   "))
        message(paste("Face:",  die_face , "   "))
      }
    )
    
    ## Tabulate roll results
    nBrain   <- sum(faces[]=='brain')   + nBrain
    nShotgun <- sum(faces[]=='shotgun') + nShotgun
    if(status=='live' & nShotgun>=3) { status <- 'dead'     }
    if(status=='live' & nDrawn>=13 ) { status <- 'complete' }
    
    ## Write this roll's die faces back to the turn face vector
    die_face[die_face=='runner' & 1:13<=nDrawn] <- faces
  }
  
  ## Tabulate turn results
  if(status=='live' | status=='complete') {
    score <- nBrain
  } else {
    score <- 0
  }
  return(score);
}


### UDF: Simulate strategy a gazillion turns
zd_sim <- function(strategy, brain_limit, shotgun_limit, runs){
  sv <- rep(NA, runs)         # score vector
  for (i in 1:runs) 
  {sv[i] <- zd_turn(strategy, brain_limit, shotgun_limit)}
  return(sv)
}


### Shiny specific code
shinyServer(function(input, output, session) {
  
  # Conduct simulations
  scores <- reactive({
    zd_sim(input$strat, input$b_limit, input$s_limit, input$reps) 
  })

  # Summary stat
  mu <- reactive({ mean(scores()) })
  
  # Generate output
  output$zd_plot <- renderPlot({
    hist(scores(), 
         main = paste("Strategy: Pass at ", input$b_limit, " Brains ", 
                      toupper(input$strat), " ", input$s_limit, " Shotguns", sep=""),
         xlab = paste("Brains: With", input$reps, "reps, your mean brains are", 
                      round(mu(), 2) ),
         xlim=c(0,12)
    )
    abline(v = mu(), col = "red", lwd = 7)
  })
})
