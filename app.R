#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

source("get-log-data.R")

library(shiny)
library(plotly)
library(lubridate)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    navbarPage("Mt Hood Meadows Parking Lots",
               tabPanel("Lot Trends",
                        sidebarLayout(
                            sidebarPanel(
                                selectInput('lot_name', 'Select Lot',
                                            lot_names, selectize=TRUE),
                                dateRangeInput('date_range',
                                               label = 'Select Dates',
                                               start = Sys.Date() - 21, end = Sys.Date())
                                ),
                            mainPanel(
                                plotlyOutput("lot_trends")
                            )
                        ),
               ),
               tabPanel("Summary",
                        verbatimTextOutput("summary")
               )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$lot_trends <- renderPlotly({
        
        lot_data <- lots %>%
            filter(lot_name == input$lot_name &
                       collection_timestamp >= input$date_range[1] &
                       collection_timestamp <= input$date_range[2] + days(1))
        
        plot <- plot_ly(data = lot_data, x = ~ date, y = ~ adjusted_timestamp,
                        text = ~ paste('<i>Date</i>: ', date,
                                       '<br><b>Time</b>: ', time,
                                       '<br><b>Week Day</b>: ', weekday,
                                       '<br><b>Lot Status</b>: ', status),
                        hoverinfo = 'text') %>%
            #make the markers small and color by status
            add_markers(marker = list(size = 5),
                        color = ~ status) %>%
            #add a straight line for the opening time at 9:00 AM
            add_segments(x = input$date_range[1] - hours(12),
                         xend = input$date_range[2] + hours(12),
                         y = opening_time, yend = opening_time,
                         line = list(color = "steelblue"),
                         name = "Opening Time",
                         opacity = 0.75) %>%
            layout(xaxis = list(title = "Date"),
                   yaxis = list(title = "Time",
                                tickformat = "%I:%M %p"))
        plot
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
