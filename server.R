library(shiny)
library(dplyr)
library(ggplot2)
library(RCurl)

x <- getURL("https://www.google.org/flutrends/us/data.txt")
google_data <- read.csv(text=x, header=T,  skip=10)
google_data$Date <-as.Date(google_data$Date)

# The shiny server will take user input information and use that to create our plot
shinyServer(function(input, output) {
  
  
  # This is a function which filters our google_data information to only return data for
  # the location that we want and the dates that we want.
  selectedData <- reactive({
    
    # First we take our data table and select only two columns from it: 
    # 1. The location column corresponding to the location that the user chose from the drop down menu in ui.R (called input$location)
    # 2. The Date column, which we will need to plot our data
     selected_data <- select_(google_data, Search.Frequency=input$location, "Date") 
     
     # Next, we filter the data so that only dates that fall within the user's selected date range (input$dateRange) are returned.
     selected_data <- filter(selected_data, Date >=input$dateRange[1] & Date <= input$dateRange[2] )
     
     # Finally, we return the data that we have selected
     return(selected_data)
     })

  # Once we have selected our data, we can make our plot. We call our plot "google_plot", the same name that is 
  # referenced in the ui.R file
  output$google_plot <- renderPlot({
    
    # To use the qplot function (part of the ggplot2 library), specify:
    # the x variable (here, Date), 
    # the y variable( here, Location)
    # the data that you are using to make the plot.  Our data is provided by the selectedData() function above
    # the plot type you'd like to make. We use geom="line" to make a line connecting the data points in our plot
    plot <- qplot(Date, Search.Frequency , data=selectedData(), geom="line")
    
    # Then we return the plot that we've made
    return(plot)
  })
})
    
   
