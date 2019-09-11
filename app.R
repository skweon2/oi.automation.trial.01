############################

##### Install packages #####

############################

install.packages("Rcpp")
install.packages("httpuv", type="binary")
install.packages('shiny', type='binary')
install.packages("flexdashboard", type="binary")
install.packages("plyr")
install.packages("tcltk2")
install.packages("chron")
install.packages("devtools", type="binary")
install.packages("reshape")
install.packages("pillar", type="binary")
install.packages('Rcpp', dependencies = TRUE)
install.packages("tidyverse", dependencies = TRUE)
install.packages('ggplot2', dependencies = TRUE)
install.packages('data.table', dependencies = TRUE)
install.packages("ggplot2", type="binary")
install.packages("svDialogs", type="binary")
install.packages("writexl")
install.packages("rlang", type="binary")
install.packages("plotly", type="binary")
install.packages("googleVis", type="binary")
install.packages("tidyverse")
install.packages("broom")
install.packages("ggQC", type="binary")
install.packages("rJava")

library(rJava)
library(shiny)
library(flexdashboard)
library(devtools)
#library(plyr)
library(tcltk2)
library(reshape)
library(reshape2)
install.packages("XLConnect")
library(XLConnect)
library(rJava)
install.packages("xlsxjars")
library(xlsxjars)
library(xlsx)
library(lubridate)
library(chron)
library(ggplot2)
library(ggQC)
library(svDialogs)
library(BH)
library(zoo)
library(writexl)
library(rlang)
library(dplyr)
library(plotly)
library(googleVis)
library(gridExtra)
library(grid)
library(lattice)
library(knitr)
install.packages("kableExtra")
library(kableExtra)
library(scales)
library(broom)
library(tidyverse)

install.packages("DBI", type="binary")
install.packages("spData", type="binary")
install.packages("units", type="binary")
install.packages("choroplethr", dependencies=TRUE)

library(DBI)
library(units)
library(spData)
library(readxl)
library(dplyr)
library(choroplethr)
library(choroplethrMaps)


##################################

##### Analysis Report Set Up #####

##################################

wdpath <- "C:/Users/kweons01/Desktop/Engineering Innovation"
#wdpath<- "J:/deans/Presidents/SixSigma/Individual Folders/Current Employees/Engineers/So Youn Kweon/Engineering Innovation"
#wdpath<- "J:/Presidents/SixSigma/Individual Folders/Current Employees/Engineers/So Youn Kweon/Engineering Innovation"
setwd(wdpath)


data.file <- "MSDUS_ScheduleData.csv"
data.raw1<- read.csv(data.file, stringsAsFactors = FALSE, strip.white = TRUE)
data.raw<- data.raw1

#######################
#                     #
# DATA PRE-PROCESSING #
#                     #
#######################

# Change names of columns - should have standardized column names

data.raw <- data.raw %>% rename(Appointment.Time=Appoi.PMtme.PMt.Time, Date.Arrived=Date.when.Arrived, 
                                Time.Arrived=Time.Whe.PM.Arrived, Appt.Name.Short=Short.Name, Appt.Name.Long=Long.Name)

data.raw$Appointment.Date <- strptime(data.raw$Appointment.Date, format="%m/%d/%Y")
data.raw$Appointment.Date<- as.POSIXct(data.raw$Appointment.Date)

# Add columns for YEAR, MONTH, and DAY 

data.raw$Appointment.Time <- strptime(data.raw$Appointment.Time, format = "%I:%M %p")
data.raw$Appointment.Time<- as.POSIXct(data.raw$Appointment.Time)

# Add columns for arrival times 
data.raw$Time.Arrived <- strptime(data.raw$Time.Arrived, format = "%I:%M %p")
data.raw$Time.Arrived<- as.POSIXct(data.raw$Time.Arrived)

#data.raw$Appointment.Time1<- format(data.raw$Appointment.Time, format = "%H:%M")
#data.raw$Appointment.Time1<- strptime(data.raw$Appointment.Time1, format = "%H:%M")

#data.raw$Appointment.Time1<- times(data.raw$Appointment.Time1)
#data.raw$Appointment.Time1<- strptime(data.raw$Appointment.Time1, format = "%H:%M")
#data.raw$Appointment.Time<- sub(".*\\s+", "",  data.raw$Appointment.Time1)

## Create date column
data.raw$Appt.Date <- format(as.Date(data.raw$Appointment.Date, format="%m/%d/%Y"), "%m/%d")

## Create month - year column
data.raw$Appt.Year.Month <- as.yearmon(data.raw$Appointment.Date)

## Create Year column
data.raw$Appt.Year <- format(as.Date(data.raw$Appointment.Date, format="%m/%d/%Y"), "%Y")

## Create Month colunm
data.raw$Appt.Month <- months(data.raw$Appointment.Date)

## Create day of week column 
data.raw$Appt.Day <- format(as.Date(data.raw$Appointment.Date, format="%m/%d/%Y"), "%A")
data.raw$Appt.Day<- factor(data.raw$Appt.Day, levels = c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"))


## Create rounded appointment times in hour
data.raw$Appt.Time.Hour<- lubridate::floor_date(data.raw$Appointment.Time, "hour")
data.raw$Appt.Time.Hour<- sub(".*\\s+", "",  data.raw$Appt.Time.Hour)

## Create rounded appointment times in 30 minute interval
data.raw$Appt.Time.30min<- lubridate::floor_date(data.raw$Appointment.Time, "30 minutes")
data.raw$Appt.Time.30min<- sub(".*\\s+", "",  data.raw$Appt.Time.30min)

## Craete rounded appointment itmes in 15 minute interval 
data.raw$Appt.Time.15min<- lubridate::floor_date(data.raw$Appointment.Time, "15 minutes")
data.raw$Appt.Time.15min<- sub(".*\\s+", "",  data.raw$Appt.Time.15min)

## Create rounded arrivedt times in hour
data.raw$Arr.Time.Hour<- lubridate::floor_date(data.raw$Time.Arrived, "hour")
data.raw$Arr.Time.Hour<- sub(".*\\s+", "",  data.raw$Arr.Time.Hour)

## Create rounded arrived times in 30 minute interval
data.raw$Arr.Time.30min<- lubridate::floor_date(data.raw$Time.Arrived, "30 minutes")
data.raw$Arr.Time.30min<- sub(".*\\s+", "",  data.raw$Arr.Time.30min)

## Craete rounded arrived itmes in 15 minute interval 
data.raw$Arr.Time.15min<- lubridate::floor_date(data.raw$Time.Arrived, "15 minutes")
data.raw$Arr.Time.15min<- sub(".*\\s+", "",  data.raw$Arr.Time.15min)


# Sort data to identify duplicated records
data.raw$unique<- paste(data.raw$IDX.MRN, data.raw$Department, data.raw$Location, data.raw$Provider, data.raw$Appointment.Date, 
                        data.raw$Appointment.Time, data.raw$Appointment.Time, data.raw$Status, sep = "")

data.raw<- data.raw[order(data.raw$unique, decreasing = FALSE),]


################################################################################
####### Pre-process arrived data ###############################################
################################################################################

# Dataset of arrived patients only.
data.arrived <- data.raw[which(data.raw$Status == "ARR"),]

#WriteXLS("data",ExcelFileName="data.xlsx",row.names=F,col.names=T)
#write_xlsx(data.arrived, "data.arrived.xlsx")

# Are there any duplicated data records? 
duplicates<- data.arrived[duplicated(data.arrived$unique),]

if(nrow(duplicates) == 0){
  tkmessageBox(title = "NOTE",
               message = "There are no duplicative records founds. Press OK to continue.", icon="info", type="ok")
} else {
  tkmessageBox(title= "NOTE",
               message = print(paste0(nrow(duplicates)," duplicative data records removed. Press OK to continue.")))
}

# 1. Total Patient visits over time
pts.over.time<- aggregate(unique ~ Appt.Year + Appt.Date, data = data.arrived, NROW)

#pts.over.time1<- pts.over.time
pts.over.time$Appt.Date <- strptime(pts.over.time$Appt.Date, format = "%m/%d")

# 2. Total Patient visits by month
pts.by.month<- aggregate(unique ~ Appt.Year + Appt.Month, data = data.arrived, NROW)

# Average patient visits by month
avg.pts.by.month<- aggregate(unique ~ Appt.Year + Appt.Month, data = pts.by.month, mean)
avg.pts.by.month$unique<- round(avg.pts.by.month$unique, 1)

# write.xlsx(as.data.frame(pts.by.month), file='pts.by.month.xlsx', sheetName="Sheet1", col.names=TRUE, row.names=FALSE, append=TRUE)

# 3. Average patient visits by day of week
pts.by.day<- aggregate(unique ~ Appt.Year + Appt.Day + Appt.Date, data = data.arrived, NROW)
#pts.by.day$Appt.Day<- factor(pts.by.day$Appt.Day, levels = c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"))
avg.pts.by.day<- aggregate(unique ~ Appt.Year + Appt.Day, data = pts.by.day, mean)
avg.pts.by.day$unique <- round(avg.pts.by.day$unique,1)


# 4. Average patient visits by day of week and time of day 
## In hour interval 
pts.by.hour<- aggregate(unique ~ Appt.Year + Appt.Date + Appt.Day + Appt.Time.Hour, data = data.arrived, NROW)
pts.by.hour<- aggregate(unique ~ Appt.Year + Appt.Day + Appt.Time.Hour, data = pts.by.hour, mean)
pts.by.hour$unique<- round(pts.by.hour$unique,1)

## In 30 minutes interval
pts.by.30min<- aggregate(unique ~ Appt.Year + Appt.Date + Appt.Day + Appt.Time.30min , data = data.arrived, NROW)
pts.by.30min<- aggregate(unique ~ Appt.Year + Appt.Day + Appt.Time.30min, data = pts.by.30min, mean)
pts.by.30min$unique<- round(pts.by.30min$unique,1)

## In 15 minutes interval
pts.by.15min<- aggregate(unique ~ Appt.Year + Appt.Date + Appt.Day + Appt.Time.15min , data = data.arrived, NROW)
pts.by.15min<- aggregate(unique ~ Appt.Year + Appt.Day + Appt.Time.15min, data = pts.by.15min, mean)
pts.by.15min$unique<- round(pts.by.15min$unique,1)


# Black cells to N/A under Primary Category field in dataset
data.raw[which(data.raw$Primary.Category == " "), "Primary.Category"] <- "N/A"

dRecords <- length(unique(data.raw$unique)) # number of unique records in data
tRange.min <- min(data.raw$Appointment.Date) # Data time range
tRange.max <- max(data.raw$Appointment.Date) # Data time range

arrived.all <- data.raw[which(data.raw$Status == "ARR"),]


####################################
# Data frame for space utilization #
####################################

scheduled.data <- data.raw %>%
  filter(data.raw$Status %in% c("NOS","ARR"))

scheduled.data$Appt.Start <- as.POSIXct(scheduled.data$Appointment.Time, format = "%H:%M")
scheduled.data$Appt.End <- as.POSIXct(scheduled.data$Appt.Start + scheduled.data$Duration*60, format = "%H:%M")



## Data frame for hourly interval (including both NOS and ARR)

#print.POSIXct <- function(x,...)print(format(x,"%Y-%m-%d %H:%M:%S"))

#time.hour <- format(seq.POSIXt(as.POSIXct(Sys.Date()), as.POSIXct(Sys.Date()+1), by = "hour"),"%H:%M", tz="GMT")
#time.hour <- time.hour[1:24]

#time.hour.df <- data.frame(matrix(ncol=length(time.hour), nrow=nrow(scheduled.data)))

#colnames(time.hour.df) <- time.hour
#time.hour.df <- cbind(scheduled.data,time.hour.df)

#c.start <- which(colnames(time.hour.df)=="00:00") 
#c.end <- which(colnames(time.hour.df)=="23:00") + 1

#midnight <- data.frame(matrix(ncol=1, nrow=nrow(scheduled.data)))
#colnames(midnight) <- "00:00"

#time.hour.df <- cbind(time.hour.df,midnight)

#i <- 1
#n <- nrow(time.hour.df) + 1

#while(c.start!=c.end){
 # i <- 1
  #while(i!=n){
    #if(time.hour.df$Appt.Start[i] >= as.POSIXct(colnames(time.hour.df)[c.start], format = "%H:%M") &
      # time.hour.df$Appt.Start[i] < as.POSIXct(colnames(time.hour.df)[c.start+1], format = "%H:%M")){
      #time.hour.df[i,c.start] <- pmin(time.hour.df$Duration[i],difftime(as.POSIXct(colnames(time.hour.df)[c.start+1],format = "%H:%M"), 
      #                                                                  as.POSIXct(colnames(time.hour.df)[c.start],format = "%H:%M"), unit="mins"))
    #}else if(time.hour.df$Appt.End[i] >= as.POSIXct(colnames(time.hour.df)[c.start], format = "%H:%M") &
     #        time.hour.df$Appt.End[i] < as.POSIXct(colnames(time.hour.df)[c.start+1], format = "%H:%M")){
      #time.hour.df[i,c.start] <- difftime(time.hour.df$Appt.End[i],as.POSIXct(colnames(time.hour.df)[c.start], format = "%H:%M"), unit="mins")
    #}else if(time.hour.df$Appt.Start[i] >= as.POSIXct(colnames(time.hour.df)[c.start+1], format = "%H:%M")){
     # time.hour.df[i,c.start] <- 0
    #}else if(time.hour.df$Appt.End[i] <= as.POSIXct(colnames(time.hour.df)[c.start], format = "%H:%M")){
     # time.hour.df[i,c.start] <- 0
    #}else{
     # time.hour.df[i,c.start] <- 60
    #}
    #i <- i+1
  #}
  #c.start <- c.start+1
#}

#time.hour.df <- time.hour.df[1:length(time.hour.df)-1]


#write_xlsx(time.hour.df, "time.hour.df.xlsx")

time.hour.df1 <- "time.hour.df.csv"
time.hour.df <- read_csv(time.hour.df1)
head(time.hour.df)



## Data frame for 30-min interval (including both NOS and ARR)

#print.POSIXct <- function(x,...)print(format(x,"%Y-%m-%d %H:%M:%S"))

#time.30min <- format(seq.POSIXt(as.POSIXct(Sys.Date()), as.POSIXct(Sys.Date()+1), by = "30 min"),"%H:%M", tz="GMT")
#time.30min <- time.30min[1:48]

#time.30min.df <- data.frame(matrix(ncol=length(time.30min), nrow=nrow(scheduled.data)))

#colnames(time.30min.df) <- time.30min
#time.30min.df <- cbind(scheduled.data,time.30min.df)

#c.start <- which(colnames(time.30min.df)=="00:00") 
#c.end <- which(colnames(time.30min.df)=="23:30") + 1

#midnight <- data.frame(matrix(ncol=1, nrow=nrow(scheduled.data)))
#colnames(midnight) <- "00:00"

#time.30min.df <- cbind(time.30min.df,midnight)

#i <- 1
#n <- nrow(time.30min.df) + 1


#while(c.start!=c.end){
  #i <- 1
  #while(i!=n){
    #if(time.30min.df$Appt.Start[i] >= as.POSIXct(colnames(time.30min.df)[c.start], format = "%H:%M") &
      # time.30min.df$Appt.Start[i] < as.POSIXct(colnames(time.30min.df)[c.start+1], format = "%H:%M")){
      #time.30min.df[i,c.start] <- pmin(time.30min.df$Duration[i],difftime(as.POSIXct(colnames(time.30min.df)[c.start+1],format = "%H:%M"), 
     #                                                                   as.POSIXct(colnames(time.30min.df)[c.start],format = "%H:%M"), unit="mins"))
    #}else if(time.30min.df$Appt.End[i] >= as.POSIXct(colnames(time.30min.df)[c.start], format = "%H:%M") &
     #        time.30min.df$Appt.End[i] < as.POSIXct(colnames(time.30min.df)[c.start+1], format = "%H:%M")){
      #time.30min.df[i,c.start] <- difftime(time.30min.df$Appt.End[i],as.POSIXct(colnames(time.30min.df)[c.start], format = "%H:%M"), unit="mins")
    #}else if(time.30min.df$Appt.Start[i] >= as.POSIXct(colnames(time.30min.df)[c.start+1], format = "%H:%M")){
     # time.30min.df[i,c.start] <- 0
    #}else if(time.30min.df$Appt.End[i] <= as.POSIXct(colnames(time.30min.df)[c.start], format = "%H:%M")){
     # time.30min.df[i,c.start] <- 0
    #}else{
     # time.30min.df[i,c.start] <- 30
    #}
    #i <- i+1
  #}
  #c.start <- c.start+1
#}

#time.30min.df <- time.30min.df[1:length(time.30min.df)-1]

#write_xlsx(time.30min.df, "time.30min.df.xlsx")

time.30min.df1 <- "time.30min.df.csv"
time.30min.df <- read_csv(time.30min.df1)

################################################################################
####### Pre-process no-show data ###############################################
################################################################################

groupByDepartments <- function(dt, departments, mindateRange, maxdateRange, weekdays, insurance, apptType){
  result <- dt %>% filter(Department %in% departments, mindateRange <= Appointment.Date, maxdateRange >= Appointment.Date, 
                          Appt.Day %in% weekdays, Primary.Category %in% insurance, Appt.Name.Long %in% apptType)
  return(result)
}


apptType <- function(dt, departments){
  result <- dt %>% filter(Department %in% departments)
  result <- unique(result$Appt.Name.Long)
  as.list(result)
}

##################################################################################################################################

################################################## UI CODES ######################################################################

##################################################################################################################################

## Analysis Report Setup
# User input title for the analysis report
user.title.input <- dlgInput(paste("Name the analysis report","(i.e. MSDUS OB/GYN Report - Jan - June, 2018):",sep="\n"), Sys.info()[""])$res
# User input for data source
user.source.input <- dlgInput(paste("Input data source","(i.e. Epic Scheduling Data - Jan - June, 2018):",sep="\n"), Sys.info()[""])$res


ui <- fluidPage(
  #titlePanel(user.title.input),
  
  tags$div(
    tags$h1(user.title.input), 
    tags$h3(paste("Data Source: ",user.source.input,sep = ""))
  ),
  hr(), br(),
  #sidebarLayout(
  sidebarPanel(
    width = 3,
    h4("Format Dataset:"),
    checkboxInput(inputId = "sel_dept",
                  label = strong("Location"),
                  value = FALSE),
    
    conditionalPanel(
      condition = "input.sel_dept == true",
      # Buttons for department selection
      uiOutput("departmentsControl"), # the id
      actionButton(inputId = "clearAllBottom",
                   label = "Clear selection",
                   icon = icon("square-o")),
      actionButton(inputId = "selectAllBottom",
                   label = "Select all",
                   icon = icon("check-square-o"))
    ),
    
    checkboxInput(inputId = "sel_date",
                  label = strong("Date"),
                  value = FALSE),
    
    conditionalPanel(
      condition = "input.sel_date == true",
      dateRangeInput("dateRange",
                     label = 'Select date range (yyyy-mm-dd):',
                     start = as.Date(min(data.raw$Appointment.Date)), end = as.Date(max(data.raw$Appointment.Date)))
    ),
    
    checkboxInput(inputId = "sel_day",
                  label = strong("Days of Week"),
                  value = FALSE),
    
    conditionalPanel(
      condition = "input.sel_day == true",
      # Buttons for days of week selection
      uiOutput("weekdaysControl"), # the id
      actionButton(inputId = "clearAllBottom1",
                   label = "Clear selection",
                   icon = icon("square-o")),
      actionButton(inputId = "selectAllBottom1",
                   label = "Select all",
                   icon = icon("check-square-o"))
    ),
    
    checkboxInput(inputId = "sel_ins",
                  label = strong("Insurance"),
                  value = FALSE),
    
    conditionalPanel(
      condition = "input.sel_ins == true",
      # Buttons for primary insurance category selection
      uiOutput("insuranceControl"), # the id
      actionButton(inputId = "clearAllBottom2",
                   label = "Clear selection",
                   icon = icon("square-o")),
      actionButton(inputId = "selectAllBottom2",
                   label = "Select all",
                   icon = icon("check-square-o"))),
    
    checkboxInput(inputId = "sel_appt",
                  label = strong("Appointment Type"),
                  value = FALSE),
    
    conditionalPanel(
      condition = "input.sel_appt == true",
      # Buttons for Appt Type selection
      uiOutput("appointmentControl"), # the id
      actionButton(inputId = "clearAllBottom3",
                   label = "Clear selection",
                   icon = icon("square-o")),
      actionButton(inputId = "selectAllBottom3",
                   label = "Select all",
                   icon = icon("check-square-o"))),
    
    hr(),
    
    conditionalPanel(
      condition = "input.tabs==2 || input.tabs==3 || input.tabs==4",
      h4("Format Graphs:"),
      checkboxInput(inputId = "label_axes",
                    label = strong("Change Axis Labels"),
                    value = FALSE),
      
      conditionalPanel(
        condition = "input.label_axes == true",
        textInput("lab_x", "X-axis:", value = "label x-axis")
      ),
      conditionalPanel(
        condition = "input.label_axes == true",
        textInput("lab_y", "Y-axis:", value = "label y-axis")
      ),
      checkboxInput(inputId = "add_title",
                    label = strong("Change Titles"),
                    value = FALSE),
      
      conditionalPanel(
        condition = "input.add_title == true",
        textInput("title", "Title:", value = "Title")
      ),
      
      checkboxInput(inputId = "adj_fnt_sz",
                    label = strong("Change Font Size"),
                    value = FALSE),
      conditionalPanel(
        condition = "input.adj_fnt_sz == true",
        numericInput("fnt_sz_ttl",
                     "Size axis titles:",
                     value = 12),
        numericInput("fnt_sz_ax",
                     "Size axis labels:",
                     value = 10)
      ))
  ),
  
  # MAIN PANEL
  mainPanel(
    tabsetPanel(id="tabs",
                # Dataset tab
                tabPanel(p(icon("table"), "Dataset"), value =1,
                         dataTableOutput(outputId = "dTable")),
                
                # Population analysis tab
                tabPanel(p(icon("street-view"), "Population Analysis"), br(), br(),
                         plotOutput("population1", width = "1400px", height = "500px"), br(), hr(), br(),
                         plotOutput("population2", width = "1400px", height = "900px"), br(), hr(), br()),
                
                # Volume analysis tab
                tabPanel(p(icon("signal"), "Volume Analysis"), value=2, br(), br(),
                         plotlyOutput("volume1", width = "1200px", height = "500px"), br(), hr(), br(),
                         plotOutput("volume2", width = "1200px", height = "500px"), br(), hr(), br(),
                         plotlyOutput("volume3", width = "1200px", height = "500px"), br(), br(),
                         tableOutput("volume3.1"), br(), hr(), br(),
                         plotOutput("volume4", width = "1200px", height = "500px"), br(), hr(), br(),
                         plotlyOutput("volume5", width = "1200px", height = "500px"), br(), hr(), br(),
                         plotlyOutput("volume6", width = "1200px", height = "500px"), br(), br(), br()),
                
                # Scheduling Analysis tab
                tabPanel(p(icon("calendar"), "Scheduling Analysis"), value=3, br(), br(),
                         plotlyOutput("schedule1", width = "1200px", height = "450px"),br(), br(),
                         tableOutput("schedule1.1"), br(), hr(), br(),
                         plotlyOutput("schedule2", width = "1200px", height = "600px"),br(), hr(), br(),
                         plotOutput("schedule3", width = "1200px", height = "600px"),br(), hr(), br(),
                         plotlyOutput("schedule4", width = "1200px", height = "600px"),br(), hr(), br(),
                         plotOutput("schedule5", width = "1200px", height = "600px"),br(), hr(), br(),
                         plotOutput("schedule6", width = "1220px", height = "900px"), br(),
                         tableOutput("noShow.day"), br(), hr(), br(),
                         plotOutput("schedule7", width = "1220px", height = "600px"),br(), hr(), br(),
                         plotOutput("schedule8", width = "1200px", height = "600px"),br(), hr(), br(),
                         plotOutput("schedule9", width = "1200px", height = "600px"),br(), hr(), br(),
                         plotOutput("schedule10", width = "1200px", height = "1400px"),br(), hr(), br()),
                
                # Space Analysis tab
                tabPanel(p(icon("bed"), "Space Analysis"), value=4, br(), br(),
                         plotOutput("space1", width = "1200px", height = "600px"),br(), hr(), br(),
                         plotOutput("space2", width = "1200px", height = "600px"),br(), hr(), br(),
                         plotOutput("space3", width = "1200px", height = "600px"),br(), hr(), br(),
                         plotOutput("space4", width = "1200px", height = "600px"),br(), hr(), br(),
                         plotOutput("space5", width = "1200px", height = "600px"),br(), hr(), br(),
                         plotOutput("space6", width = "1200px", height = "600px"),br(), hr(), br())
                
    )
  )
) # Close fluidpage for ui server





##########################################################################################################################

########### SERVER LOGIC #################################################################################################

##########################################################################################################################

# Create department list for panel

departments <- sort(unique(data.raw$Department))
weekdays <- sort(unique(data.raw$Appt.Day))
insurance <- sort(unique(data.raw$Primary.Category))

# Shiny server

server <- function(input, output, session){
  
###########################################################################
################### Reactive Variables Setup ##############################
###########################################################################
 
  
  # Initialize reactive values for department selection
  values <- reactiveValues()
  values$departments <- departments
  
  observe({
    if(input$selectAllBottom > 0) {
      updateCheckboxGroupInput(session=session, inputId="departments", 
                               choices=departments, selected=departments)
      values$departments <- departments
    }
  })
  
  observe({
    if(input$clearAllBottom > 0) {
      updateCheckboxGroupInput(session=session, inputId="departments", 
                               choices=departments, selected=NULL)
      values$departments <- c()
    }
  })
  
  # Create event type checkbox - department selection
  output$departmentsControl <- renderUI({
    checkboxGroupInput('departments', 'Select department(s) to include:',
                       departments, selected = NULL)
  })
  
  
  # Initialize reactive values for days of week selection
  values1 <- reactiveValues()
  values1$weekdays <- weekdays
  
  observe({
    if(input$selectAllBottom1 > 0) {
      updateCheckboxGroupInput(session=session, inputId="weekdays", 
                               choices=weekdays, selected=weekdays)
      values1$weekdays <- weekdays
    }
  })
  
  observe({
    if(input$clearAllBottom1 > 0) {
      updateCheckboxGroupInput(session=session, inputId="weekdays", 
                               choices=weekdays, selected=NULL)
      values1$weekdays <- c()
    }
  })
  
  # Create event type checkbox - days of week selection
  output$weekdaysControl <- renderUI({
    checkboxGroupInput('weekdays', 'Select day(s) to include:',
                       weekdays, selected = NULL)
  })
  
  
  # Initialize reactive values for primary insurance selection
  values2 <- reactiveValues()
  values2$insurance <- insurance
  
  observe({
    if(input$selectAllBottom2 > 0) {
      updateCheckboxGroupInput(session=session, inputId="insurance", 
                               choices=insurance, selected=insurance)
      values2$insurance <- insurance
    }
  })
  
  observe({
    if(input$clearAllBottom2 > 0) {
      updateCheckboxGroupInput(session=session, inputId="insurance", 
                               choices=insurance, selected=NULL)
      values2$insurance <- c()
    }
  })
  
  # Create event type checkbox - primary insurance selection
  output$insuranceControl <- renderUI({
    checkboxGroupInput('insurance', 'Select primary insurance type(s) to include:',
                       insurance, selected = NULL)
  })
  
  
  # Initialize reactive values for appointment type selection based on department selection
  values3 <- reactiveValues()

  observe({
    if(input$selectAllBottom3 > 0) {
      updateCheckboxGroupInput(session=session, inputId="apptType", 
                               choices=sort(unique(data.raw[data.raw$Department %in% input$departments, "Appt.Name.Long"])), selected=sort(unique(data.raw[data.raw$Department %in% input$departments, "Appt.Name.Long"])))
    }
  })
  
  observe({
    if(input$clearAllBottom3 > 0) {
      updateCheckboxGroupInput(session=session, inputId="apptType", 
                               choices=sort(unique(data.raw[data.raw$Department %in% input$departments, "Appt.Name.Long"])), selected=NULL)
    }
  })
  
  # Create event type checkbox - appointment type selection
  output$appointmentControl <- renderUI({
    checkboxGroupInput('apptType', 'Select appointment type(s) to include:',
                        choices=sort(unique(data.raw[data.raw$Department %in% input$departments, "Appt.Name.Long"])), selected = NULL)
  })
  

  
  ###########################################################################
  ################### Prepare dataset #######################################
  ###########################################################################
  
  # Set up data table for Dataset Tab
  dataTable <- reactive({
    groupByDepartments(arrived.all[, c('Department','MSMRN','Appointment.Date','Appt.Day',
                                       'Appointment.Time','Appt.Name.Long','Provider','Primary.Category','Status')], 
                       input$departments, input$dateRange[1], input$dateRange[2],
                       input$weekdays, input$insurance, input$apptType)
  })
  
  
  # Arrived patients only 
  dataset <- reactive({
    groupByDepartments(arrived.all, 
                       input$departments, input$dateRange[1], input$dateRange[2],
                       input$weekdays, input$insurance, input$apptType)
  })
  
  
  # All patients 
  dataset.all <-  reactive({
    groupByDepartments(data.raw, 
                       input$departments, input$dateRange[1], input$dateRange[2],
                       input$weekdays, input$insurance, input$apptType)
  })
  
  
  # No-show patients 
  dataset.noShow <-  reactive({
    groupByDepartments(data.raw, 
                       input$departments, input$dateRange[1], input$dateRange[2],
                       input$weekdays, input$insurance, input$apptType)
  })
  
  # Scheduled patients by hour
  dataset.scheduled.hour <- reactive({
    groupByDepartments(time.hour.df, 
                       input$departments, input$dateRange[1], input$dateRange[2],
                       input$weekdays, input$insurance, input$apptType)
  })

  # Scheduled patients by 30 minute 
  dataset.scheduled.30min <- reactive({
    groupByDepartments(time.30min.df, 
                       input$departments, input$dateRange[1], input$dateRange[2],
                       input$weekdays, input$insurance, input$apptType)
  })  
  
  
  ################################################################################
  ######### (1) Dataset Tab ######################################################
  ################################################################################
  
  # Render data table 
  
  output$dTable <- renderDataTable({
    dataTable()
  })
  
  ################################################################################
  ######### (2) Population Analysis Tab ##########################################
  ################################################################################
  
  output$population1 <- renderPlot({
    
    arrived.all <- dataset.all()
    
    arrived.all$ZIP <- clean.zipcodes(arrived.all$ZIP)
    arrived.zip <- aggregate(arrived.all$unique, by=list(arrived.all$ZIP), FUN=NROW)
    names(arrived.zip) <- c("region","value")
    
    # New York City is comprised of 5 counties: Bronx, Kings (Brooklyn), New York (Manhattan),
    # Queens, Richmond (Staten Island). Their numeric FIPS codes are:
    nyc_fips = c(36005, 36047, 36061, 36081, 36085)
    
    zip_choropleth(arrived.zip,
                   num_colors = 1,
                   title       = "Total Patient Volume across New York City",
                   legend      = "Total Patient Count",
                   county_zoom = nyc_fips)+
      scale_fill_continuous(name = "Patient Count", low = "darkseagreen1", high = "firebrick1", space = "Lab", na.value = "transparent", guide = "colourbar", limits=c(0,NA))+
      theme(plot.title = element_text(hjust=0.5, face = "bold"))
    
    
  })
  
  
  output$population2 <- renderPlot({
    
    arrived.all <- dataset.all()
    
    arrived.all$ZIP <- clean.zipcodes(arrived.all$ZIP)
    arrived.zip <- aggregate(arrived.all$unique, by=list(arrived.all$ZIP), FUN=NROW)
    names(arrived.zip) <- c("region","value")
    
    # New York City is comprised of 5 counties: Bronx, Kings (Brooklyn), New York (Manhattan),
    # Queens, Richmond (Staten Island). Their numeric FIPS codes are:
    nyc_fips = c(36005, 36047, 36061, 36081, 36085)
    
    zip_choropleth(arrived.zip,
                   num_colors = 1,
                   title       = "Total Patient Volume across New York City",
                   legend      = "Total Patient Count",
                   county_zoom = nyc_fips)+
      scale_fill_continuous(name = "Patient Count", low = "darkseagreen1", high = "firebrick1", space = "Lab", na.value = "transparent", guide = "colourbar", limits=c(0,NA))+
      theme(plot.title = element_text(hjust=0.5, face = "bold"))
    
    manhattan_fips = c(36061)
    manhattan <- zip_choropleth(arrived.zip,
                                num_colors = 1,
                                title = "Total Patient Volume within Manhattan",
                                county_zoom = manhattan_fips)+
      scale_fill_continuous(name = "Patient Count", low = "darkseagreen1", high = "firebrick1", space = "Lab", na.value = "transparent", guide = "colourbar", limits=c(0,NA))+
      theme(plot.title = element_text(hjust=0.5, face = "bold"))
    
    bronx_fips = c(36005)
    bronx <- zip_choropleth(arrived.zip,
                            num_colors = 1,
                            title = "Total Patient Volume within Bronx",
                            county_zoom = bronx_fips)+
      scale_fill_continuous(name = "Patient Count", low = "darkseagreen1", high = "firebrick1", space = "Lab", na.value = "transparent", guide = "colourbar", limits=c(0,NA))+
      theme(plot.title = element_text(hjust=0.5, face = "bold"))
    
    brooklyn_fips = c(36047)
    brooklyn <- zip_choropleth(arrived.zip,
                               num_colors = 1,
                               title = "Total Patient Volume within Brooklyn",
                               county_zoom = brooklyn_fips)+
      scale_fill_continuous(name = "Patient Count", low = "darkseagreen1", high = "firebrick1", space = "Lab", na.value = "transparent", guide = "colourbar", limits=c(0,NA))+
      theme(plot.title = element_text(hjust=0.5, face = "bold"))
    
    queens_fips = c(36081)
    queens <- zip_choropleth(arrived.zip,
                             num_colors = 1,
                             title = "Total Patient Volume within Queens",
                             county_zoom = queens_fips)+
      scale_fill_continuous(name = "Patient Count", low = "darkseagreen1", high = "firebrick1", space = "Lab", na.value = "transparent", guide = "colourbar", limits=c(0,NA))+
      theme(plot.title = element_text(hjust=0.5, face = "bold"))
    
    staten_fips = c(36085)
    staten <- zip_choropleth(arrived.zip,
                             num_colors = 1,
                             title = "Patient Volume within Staten Island",
                             county_zoom = staten_fips)+
      scale_fill_continuous(name = "Patient Count", low = "darkseagreen1", high = "firebrick1", space = "Lab", na.value = "transparent", guide = "colourbar", limits=c(0,NA))+
      theme(plot.title = element_text(hjust=0.5, face = "bold"))
    
    a <- grid.arrange(bronx, brooklyn, queens, staten, ncol=2)
    b <- grid.arrange(manhattan, a, ncol=2, widths=c(3,6))
    grid.arrange(main=textGrob("Breakdown of Patient Population by Zip code",gp=gpar(fontsize=20,font=3), hjust=1.7), b, heights=c(1,9))
    
    
  })
  
  ################################################################################
  ######### (3) Volume Analysis Tab ##############################################
  ################################################################################
  
  ## 1. Total patient visit volume over time (line graph) 
  
  output$volume1 <- renderPlotly({
    
    pts.count <- aggregate(dataset()$unique, 
                           by=list(dataset()$Appt.Year, dataset()$Appt.Date), FUN=NROW)
    
    names(pts.count) <- c("App.Year","Appt.Date","Count")
    #pts.count$Appt.Date <- strptime(pts.count$Appt.Date, format = "%Y-%m")
    #pts.count$Appt.Date <- as.Date(pts.count$Appt.Date, format = "%Y-%m")
    
    
    pts.count.graph <- ggplot(pts.count, aes(x=Appt.Date, y=Count))+
      geom_line(color="maroon1")+
      geom_point(color="maroon1")+
      ggtitle("Daily Patient Visit Volume over Time")+
      ylab("Patient Count")+
      theme_bw()+
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 15),
            text = element_text(size=12),
            legend.position = "top",
            legend.title = element_blank(),
            axis.title.x = element_blank(),
            axis.title = element_text(size="10"),
            axis.text.x = element_text(angle=90, hjust=1, margin = margin(t=30)),
            axis.text.y = element_text(margin = margin(r=30)),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(size = 0.3, colour = "black"),
            plot.margin = margin(30,30,30,30))
    
    #scale_x_datetime(labels = date_format("%b"))
    
    ggplotly(pts.count.graph)
    
  })
  
  
  
  ## 2. Total patient visit volume by month (line graph)
  
  output$volume2 <- renderPlot({
    
    pts.by.month <- aggregate(dataset()$unique,
                              by=list(dataset()$Appt.Year, dataset()$Appt.Month), FUN=NROW)
    
    names(pts.by.month) <- c("Appt.Year","Appt.Month","Count")
    
    pts.by.month.graph <- 
      ggplot(pts.by.month, aes(x=Appt.Month, y=Count, col=Appt.Year, group=Appt.Year))+
      geom_line(color="midnightblue")+
      geom_point(color="midnightblue", size=4)+
      ggtitle("Total Patient Visit Volume by Month")+
      ylab("Patient Count")+
      theme_bw()+
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
            text = element_text(size=14),
            legend.position = "top",
            legend.title = element_blank(),
            axis.title.x = element_blank(),
            axis.title = element_text(size="14"),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(size = 0.3, colour = "black"),
            plot.margin = margin(30,30,30,30))+
      geom_text(aes(label=Count), vjust=-.1, hjust=-.3, color="grey50", fontface="bold",
                position = position_dodge(0.5), size=7)
    
    pts.by.month.graph
    
  })
  
  
  ## 3. Patient visits by day of week (boxplot)
  
  output$volume3 <- renderPlotly({
    
    pts.by.day <- aggregate(dataset()$unique,
                            by=list(dataset()$Appt.Year,dataset()$Appt.Day,dataset()$Appt.Date), FUN=NROW)
    
    names(pts.by.day) <- c("Appt.Year","Appt.Day","Appt.Date","Count")
    
    pts.by.day.graph <- 
      ggplot(pts.by.day, aes(x=Appt.Day, y=Count))+
      geom_boxplot(colour="black", fill="slategray1", outlier.shape=NA)+ # Exclude outliers in boxplot
      scale_y_continuous(name="Patient Count")+
      ggtitle("Patient Visit Volume Distribution by Day of Week")+
      stat_summary(fun.y=mean, geom="point", shape=18, size=3, color="maroon1", fill="maroon1")+
      theme_bw()+
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 15),
            text = element_text(size=12),
            legend.position = "top",
            legend.title = element_blank(),
            axis.title.x = element_blank(),
            axis.title = element_text(size="10"),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(size = 0.3, colour = "black"),
            plot.margin = margin(30,30,30,30))
    
    ggplotly(pts.by.day.graph)
    
  })
  
  
  ## 3.1 Summary of pts visits by day of week (boxplot - summary table) 
  
  output$volume3.1 <- function(){
    
    pts.by.day <- aggregate(dataset()$unique, by=list(dataset()$Appt.Year, dataset()$Appt.Day, dataset()$Appt.Date), FUN=NROW)
    names(pts.by.day) <- c("Appt.Year","Appt.Day","Appt.Date","Count")
    
    pts.med <- aggregate(pts.by.day$Count, by=list(pts.by.day$Appt.Day), FUN=median)
    pts.min <- aggregate(pts.by.day$Count, by=list(pts.by.day$Appt.Day), FUN=min)
    pts.max <- aggregate(pts.by.day$Count, by=list(pts.by.day$Appt.Day), FUN=max)
    pts.cnt <- aggregate(pts.by.day$Count, by=list(pts.by.day$Appt.Day), FUN=NROW)
    
    pts.summary <- cbind(pts.med, pts.min$x, pts.max$x, pts.cnt$x)
    names(pts.summary) <- c("","Median", "Min", "Max", "N")
    
    pts.summary <- setNames(data.frame(t(pts.summary[,-1])), pts.summary[,1])
    
    pts.summary %>%
      knitr::kable("html", align = "l") %>%
      kable_styling(bootstrap_options = c("striped", "hover"), full_width=F, position="center", font_size = 15) %>%
      row_spec(0, bold=T) %>%
      column_spec(1, bold=T, width = "3cm")
    
  }
  
  ## 4. Average patient visits by day of week (line graph)
  
  output$volume4 <- renderPlot({
    
    pts.by.day <- aggregate(dataset()$unique, by=list(dataset()$Appt.Year, dataset()$Appt.Day, dataset()$Appt.Date), FUN=NROW)
    names(pts.by.day) <- c("Appt.Year","Appt.Day","Appt.Date","Count")
    
    pts.avg <- aggregate(pts.by.day$Count, by=list(pts.by.day$Appt.Year, pts.by.day$Appt.Day), FUN=mean)
    names(pts.avg) <- c("Appt.Year","Appt.Day","Count")
    pts.avg$Count <- round(pts.avg$Count,1)
    
    pts.avg.graph <- 
      ggplot(pts.avg, aes(x=Appt.Day, y=Count, col=Appt.Year, group=Appt.Year))+
      geom_line(color="maroon1")+
      geom_point(color="maroon1", size=4)+
      ggtitle("Average Patient Visit Volume by Day of Week")+
      ylab("Patient Count")+
      theme_bw()+
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
            text = element_text(size=14),
            legend.position = "top",
            legend.title = element_blank(),
            axis.title.x = element_blank(),
            axis.title = element_text(size="14"),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(size = 0.3, colour = "black"),
            plot.margin = margin(30,30,30,30))+
    geom_text(aes(label=Count), vjust=-.1, hjust=-.3, color="grey50", fontface="bold",
              position = position_dodge(0.9), size=7)
    
    pts.avg.graph
    
  })
  
  ## 5. Average patient visits by day of week and time of day (line graph)
  
  output$volume5 <- renderPlotly({
    
    ## Hourly Interval
    pts.by.hour <- aggregate(dataset()$unique, by=list(dataset()$Appt.Year, dataset()$Appt.Date, 
                                                       dataset()$Appt.Day, dataset()$Appt.Time.Hour), FUN=NROW)
    
    names(pts.by.hour) <- c("Appt.Year","Appt.Date","Appt.Day","Appt.Time.Hour","Count")
    pts.by.hour <- aggregate(pts.by.hour$Count, by=list(pts.by.hour$Appt.Year, pts.by.hour$Appt.Day, 
                                                        pts.by.hour$Appt.Time.Hour), FUN=mean)
    
    names(pts.by.hour) <- c("Appt.Year","Appt.Day","Appt.Time.Hour","Count")
    pts.by.hour$Count <- round(pts.by.hour$Count,1)
    
    pts.by.hour.graph <- ggplot(pts.by.hour, aes(x=Appt.Time.Hour, y=Count, col=Appt.Day, group=Appt.Day))+
      geom_line()+
      ggtitle("Average Patient Visit Volume by Time of Day and Day of Week")+
      ylab("Patient Count")+
      theme_bw()+
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 15),
            text = element_text(size=12),
            legend.position = "top",
            legend.title = element_blank(),
            axis.title.x = element_blank(),
            axis.title = element_text(size="10"),
            axis.text.x = element_text(angle=90, hjust=1),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(size = 0.3, colour = "black"),
            plot.margin = margin(30, 30, 50, 30))
    
    ggplotly(pts.by.hour.graph)
    
  })
  
  
  ## 6. Average patient visits by day of week and time of day (line graph)
  
  output$volume6 <- renderPlotly({
    
    ## 30-Minute Interval
    pts.by.30min <- aggregate(dataset()$unique, by=list(dataset()$Appt.Year, dataset()$Appt.Date, 
                                                        dataset()$Appt.Day, dataset()$Appt.Time.30min), FUN=NROW)
    
    names(pts.by.30min) <- c("Appt.Year","Appt.Date","Appt.Day","Appt.Time.30min","Count")
    pts.by.30min <- aggregate(pts.by.30min$Count, by=list(pts.by.30min$Appt.Year, pts.by.30min$Appt.Day, 
                                                          pts.by.30min$Appt.Time.30min), FUN=mean)
    
    names(pts.by.30min) <- c("Appt.Year","Appt.Day","Appt.Time.30min","Count")
    pts.by.30min$Count <- round(pts.by.30min$Count,1)
    
    pts.by.30min.graph <- ggplot(pts.by.30min, aes(x=Appt.Time.30min, y=Count, col=Appt.Day, group=Appt.Day))+
      geom_line()+
      ggtitle("Average Patient Volume by Time of Day and Day of Week")+
      ylab("Patient Count")+
      theme_bw()+
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 15),
            #legend.position = "top",
            legend.title = element_blank(),
            axis.title.x = element_blank(),
            axis.title = element_text(size="12"),
            axis.text.x = element_text(angle=90, hjust=1),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(size = 0.3, colour = "black"),
            plot.margin = margin(30,30, 50, 30))
    #scale_x_datetime(labels = date_format("%H:%M"))
    
    ggplotly(pts.by.30min.graph)
    
  }) 
  
  ################################################################################
  ######### (4) SCheduling Analysis Tab ##########################################
  ################################################################################
  
  # 1. Breakdown of daily appointments by stauts and day of week (stacked bar)
  
  output$schedule1 <- renderPlotly({
    
    status.all <- aggregate(dataset.all()$unique, by=list(dataset.all()$Appt.Year, dataset.all()$Appt.Date, 
                                                          dataset.all()$Appt.Day, dataset.all()$Status), FUN=NROW)
    names(status.all) <- c("Appt.Year","Appt.Date","Appt.Day","Status","Count")
    
    status.all <- aggregate(status.all$Count, by=list(status.all$Appt.Year, status.all$Appt.Day, status.all$Status), FUN=mean)
    names(status.all) <- c("Appt.Year","Appt.Day","Status","Count")
    
    status.all$Count <- round(status.all$Count,1)
    
    status.graph <- ggplot(status.all, aes(x=Appt.Day, y=Count, fill=Status))+
      geom_bar(stat="identity", width=0.6)+
      ggtitle("Average Daily Appointment Volume by Status and Day of Week")+
      ylab("Patient Count")+
      theme_bw()+
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 15),
            legend.title = element_blank(),
            axis.title.x = element_blank(),
            axis.title.y = element_text(size = "10", margin = margin(l=30, r=100)),
            axis.text.x = element_text(size = "10", angle=0, vjust=0.5, margin = margin(t=30)),
            axis.text.y = element_text(size = "10", margin = margin(r=30, l=30)),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(size = 0.3, colour = "black"),
            plot.margin = margin(0,30,30,0))
    
    ggplotly(status.graph)
    
  })
  
  # 1.1 Breakdown of daily appointments by stauts and day of week (summary table)
  
  output$schedule1.1 <- function(){
    
    status.all <- aggregate(dataset.all()$unique, by=list(dataset.all()$Appt.Year, dataset.all()$Appt.Date, 
                                                          dataset.all()$Appt.Day, dataset.all()$Status), FUN=NROW)
    names(status.all) <- c("Appt.Year","Appt.Date","Appt.Day","Status","Count")
    
    status.all <- aggregate(status.all$Count, by=list(status.all$Appt.Day, status.all$Status), FUN=mean)
    names(status.all) <- c("Appt.Day","Status","Count")
    status.all$Count <- round(status.all$Count,1)
    
    status.all <- dcast(status.all, Status ~ Appt.Day, value.var = "Count")
    status.all[is.na(status.all)] <- 0

    status.all %>%
      knitr::kable("html", align = "l") %>%
      kable_styling(bootstrap_options = c("striped", "hover"), full_width=F, position="center", font_size = 15) %>%
      row_spec(0, bold=T) %>%
      column_spec(1, bold=T, width = "8cm")
    
  }
  
  
  # 2. Average Daily Breakdown of Appointments by insurance type (stacked bar)
  
  output$schedule2 <- renderPlotly({
    
    status.payer <- aggregate(dataset.all()$unique, by=list(dataset.all()$Appt.Year, dataset.all()$Appt.Date, 
                                                            dataset.all()$Primary.Category, dataset.all()$Status), FUN=NROW)
    names(status.payer) <- c("Appt.Year","Appt.Date","Primary.Category","Status","Count")
    
    status.payer <- aggregate(status.payer$Count, by=list(status.payer$Appt.Year, status.payer$Primary.Category, status.payer$Status), FUN=mean)
    names(status.payer) <- c("Appt.Year","Primary.Category","Status","Count")
    
    status.payer$Count <- round(status.payer$Count,1)
    
    status.payer.graph <- ggplot(status.payer, aes(x= reorder(Primary.Category, -Count), y=Count, fill=Status))+
      geom_bar(stat="identity", width=0.6)+
      ggtitle("Average Daily Appointment Volume Breakdown by Insurance Type")+
      ylab("Patient Count")+
      theme_bw()+
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 15),
            legend.title = element_blank(),
            axis.title.x = element_blank(),
            axis.title.y = element_text(size = "10", margin = margin(l=30, r=100)),
            axis.text.x = element_text(size = "10", angle=90, vjust=0.5, margin = margin(t=30)),
            axis.text.y = element_text(size = "10", margin = margin(r=30, l=30)),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(size = 0.3, colour = "black"),
            plot.margin = margin(0,30,30,0))
    
    ggplotly(status.payer.graph)
    
  })
  
  # 3. Breakdown of no show % by insurance type (bar + pareto graph)
  
  output$schedule3 <- renderPlot({
    
    noShow.payer <- aggregate(dataset.all()$unique, by=list(dataset.all()$Appt.Date, 
                                                            dataset.all()$Primary.Category, dataset.all()$Status), FUN=NROW)
    names(noShow.payer) <- c("Appt.Date","Primary.Category","Status","Count")
    
    noShow.payer <- aggregate(noShow.payer$Count, by=list(noShow.payer$Primary.Category, noShow.payer$Status), FUN=mean)
    names(noShow.payer) <- c("Primary.Category","Status","Count")
    
    noShow.payer <- noShow.payer[which(noShow.payer$Status == "NOS"),]
    names(noShow.payer) <- c("Primary.Category","Status","Count")
    noShow.payer$Count <- round(noShow.payer$Count,1)
    
    
    #noShow.payer %>% 
     # mutate(Cum = (cumsum(Count)/sum(Count))*100)
    
    #noShow.payer <- round(noShow.payer[,2:3],1)
    #names(noShow.payer) <- c("Insurance","NoShow", "Cumulative")
    
   # aes(x = reorder(Primary.Category, -Count)
    
    noShow.payer.graph <- ggplot(noShow.payer, aes(x = Primary.Category, y = Count))+
      ggtitle("Average Daily No Show Breakdown by Insurance Type")+
      ylab("Patient Count")+
      theme_bw()+
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
            axis.title = element_text(size="14"),
            axis.text = element_text(size="14"),
            axis.title.x = element_blank(),
            axis.title.y = element_text(margin = margin(r=5)),
            axis.text.x = element_text(angle = 90,hjust = 1, margin = margin(t=10)),
            axis.text.y = element_text(margin = margin(l=5, r=5)),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(size = 0.3, colour = "black"),
            plot.margin = margin(0,45,55,0))+
      stat_pareto(point.color = "maroon1",
                  point.size = 2,
                  line.color = "maroon1",
                  bars.fill = "midnightblue")
     
    noShow.payer.graph
    
  })
  
  
  # 4. Average Daily Breakdown of Appointments by appointment type (stacked bar)
  
  output$schedule4 <- renderPlotly({
    
    status.type <- aggregate(dataset.all()$unique, by=list(dataset.all()$Appt.Date, 
                                                            dataset.all()$Appt.Name.Long, dataset.all()$Status), FUN=NROW)
    names(status.type) <- c("Appt.Date","Appt.Type","Status","Count")
    
    status.type <- aggregate(status.type$Count, by=list(status.type$Appt.Type, status.type$Status), FUN=mean)
    names(status.type) <- c("Appt.Type","Status","Count")
    
    status.type$Count <- round(status.type$Count,1)
    
    status.type.graph <- ggplot(status.type, aes(x= reorder(Appt.Type, -Count), y=Count, fill=Status))+
      geom_bar(stat="identity", width=0.6)+
      ggtitle("Average Daily Appointment Volume Breakdown by Appointment Type")+
      theme_bw()+
      ylab("Patient Count")+
      theme_bw()+
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 15),
            legend.title = element_blank(),
            axis.title.x = element_blank(),
            axis.title.y = element_text(size = "10", margin = margin(l=30, r=100)),
            axis.text.x = element_text(size = "10", angle=90, vjust=0.5, margin = margin(t=30)),
            axis.text.y = element_text(size = "10", margin = margin(r=30, l=30)),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(size = 0.3, colour = "black"),
            plot.margin = margin(0,30,30,0))
    
    ggplotly(status.type.graph)
    
  })
  
  
  # 5. Average daily no show breakdown by appointment type (bar + pareto graph)
  
  output$schedule5 <- renderPlot({
    
    noShow.type <- aggregate(dataset.all()$unique, by=list(dataset.all()$Appt.Date, 
                                                            dataset.all()$Appt.Name.Long, dataset.all()$Status), FUN=NROW)
    names(noShow.type) <- c("Appt.Date","Appt.Type","Status","Count")
    
    noShow.type <- aggregate(noShow.type$Count, by=list(noShow.type$Appt.Type, noShow.type$Status), FUN=mean)
    names(noShow.type) <- c("Appt.Type","Status","Count")
    
    noShow.type <- noShow.type[which(noShow.type$Status == "NOS"),]
    names(noShow.type) <- c("Appt.Type","Status","Count")
    noShow.type$Count <- round(noShow.type$Count,1)
    
    
    #noShow.payer %>% 
    # mutate(Cum = (cumsum(Count)/sum(Count))*100)
    
    #noShow.payer <- round(noShow.payer[,2:3],1)
    #names(noShow.payer) <- c("Insurance","NoShow", "Cumulative")
    
    noShow.type.graph <- ggplot(noShow.type, aes(x = Appt.Type, y = Count))+
      ggtitle("Average Daily No Show Breakdown by Appointment Type")+
      ylab("Patient Count")+
      theme_bw()+
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
            axis.title = element_text(size="14"),
            axis.text = element_text(size="14"),
            axis.title.x = element_blank(),
            axis.title.y = element_text(margin = margin(r=5)),
            axis.text.x = element_text(angle = 90,hjust = 1, margin = margin(t=10)),
            axis.text.y = element_text(margin = margin(l=5, r=5)),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(size = 0.3, colour = "black"),
            plot.margin = margin(0,45,55,0))+
      stat_pareto(point.color = "maroon1",
                  point.size = 2,
                  line.color = "maroon1",
                  bars.fill = "midnightblue")
    
    noShow.type.graph
    
  })
  

  # 6. No-show analysis by time of day and day of week (heat map)
  
  output$schedule6 <- renderPlot({
    
    noShow <- aggregate(dataset.noShow()$unique, by=list(dataset.noShow()$Appt.Date,
                                                         dataset.noShow()$Appt.Day, dataset.noShow()$Appt.Time.Hour), FUN=NROW)
    names(noShow) <- c("Appt.Date", "Appt.Day", "Appt.Time.Hour", "noShow")
    
    noShow <- aggregate(noShow$noShow, by=list(noShow$Appt.Day, noShow$Appt.Time.Hour), FUN=mean)
    names(noShow) <- c("Appt.Day", "Appt.Time.Hour", "noShow")
    
    noShow$noShow <- round(noShow$noShow,0)
    
    noShowCt.graph <- ggplot(noShow, aes(x=Appt.Day, y=Appt.Time.Hour))+
      labs(x=NULL, y=NULL)+
      geom_tile(aes(fill=noShow), colour = "black", size=0.3)+
      ggtitle("Avg. No Show by Day of Week and Time of Day")+
      scale_fill_gradient(low = "white", high = "red", space = "Lab", na.value = "white", guide = "colourbar", name="No Show Count ")+
      scale_y_discrete(limits = rev(unique(sort(noShow$Appt.Time.Hour))))+
      scale_x_discrete(position = "top")+
      theme_bw()+
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
            legend.position = "bottom",
            legend.direction = "horizontal",
            legend.key.size = unit(0.7,"cm"),
            legend.text = element_text(size="12"),
            axis.title.x = element_text(size="14", margin = unit(c(8, 8, 8, 8), "mm")),
            axis.title.y = element_text(size="14", margin = unit(c(8, 8, 8, 8), "mm")),
            axis.text.x = element_text(color="black", angle=45, vjust=0.5, hjust = 0, margin = margin(b=30, t=100)),
            axis.text.y = element_text(color= "black", margin = margin(r=15)),
            axis.text = element_text(size="14"),
            panel.background = element_blank(),
            panel.grid.minor = element_blank(),
            panel.grid.major = element_blank(),
            #panel.border = element_rect(colour = "black", size = 0.5),
            plot.margin = margin(30,30,30,30))+
      geom_text(aes(label=noShow), color="black", size=5, fontface="bold")
    
    
    ## 6.1 % of no show 
    arrived <- aggregate(dataset()$unique, by=list(dataset()$Appt.Date,
                                                   dataset()$Appt.Day, dataset()$Appt.Time.Hour), FUN=NROW)
    names(arrived) <- c("Appt.Date", "Appt.Day", "Appt.Time.Hour", "Arrived")
    
    arrived <- aggregate(arrived$Arrived, by=list(arrived$Appt.Day, arrived$Appt.Time.Hour), FUN=mean)
    names(arrived) <- c("Appt.Day", "Appt.Time.Hour", "Arrived")
    
    arrived$id <- paste(arrived$Appt.Day,arrived$Appt.Time.Hour, sep = "")
    noShow$id <- paste(noShow$Appt.Day,noShow$Appt.Time.Hour, sep = "")
    
    arrived$noShow <- noShow$noShow[match(arrived$id, noShow$id)]
    arrived <- mutate(arrived, total = Arrived + noShow)
    arrived$noShow[is.na(arrived$noShow)] <- 0
    arrived$total[is.na(arrived$total)] <- 0
    
    arrived$noShow.percent <- round((arrived$noShow / arrived$total)*100, 0)
    arrived$noShow.percent[is.nan(arrived$noShow.percent)] <- 0
    
    noShowPercent.graph <- ggplot(arrived, aes(x=Appt.Day, y=Appt.Time.Hour))+
      labs(x=NULL, y=NULL)+
      geom_tile(aes(fill=noShow.percent), colour = "black", size=0.3)+
      ggtitle("Avg. No Show % by Day of Week and Time of Day")+
      scale_fill_gradient(low = "white", high = "red", space = "Lab", na.value = "white", guide = "colourbar", name="No Show % ")+
      scale_y_discrete(limits = rev(unique(sort(noShow$Appt.Time.Hour))))+
      scale_x_discrete(position = "top")+
      theme_bw()+
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
            legend.position = "bottom",
            legend.direction = "horizontal",
            legend.key.size = unit(0.7,"cm"),
            legend.text = element_text(size="12"),
            axis.title.x = element_text(size="14", margin = unit(c(8, 8, 8, 8), "mm")),
            axis.title.y = element_text(size="14", margin = unit(c(8, 8, 8, 8), "mm")),
            axis.text.x = element_text(color="black", angle=45, vjust=0.5, hjust = 0, margin = margin(b=15, t=100)),
            axis.text.y = element_text(color= "black", margin = margin(r=15)),
            axis.text = element_text(size="14"),
            panel.background = element_blank(),
            panel.grid.minor = element_blank(),
            panel.grid.major = element_blank(),
            plot.margin = margin(30,30,30,30))+
      geom_text(aes(label=paste(noShow.percent,"%", sep = " ")), color="black", size=5, fontface="bold")
   
     grid.arrange(noShowCt.graph, noShowPercent.graph, ncol=2)
    
  })
  
  
  
  ## 6.2 Average no show count and % by day of week (summary table) 
  
  output$noShow.day <- function(){

    noShow.day <- aggregate(dataset.noShow()$unique, by=list(dataset.noShow()$Appt.Date, dataset.noShow()$Appt.Day), FUN=NROW)
    names(noShow.day) <- c("Appt.Date", "Appt.Day", "noShow")
    
    noShow.day <- aggregate(noShow.day$noShow, by=list(noShow.day$Appt.Day), FUN=mean)
    names(noShow.day) <- c("Appt.Day", "noShow")
    noShow.day$noShow <- round(noShow.day$noShow,0)
    
    arrived.day <- aggregate(dataset()$unique, by=list(dataset()$Appt.Date, dataset()$Appt.Day), FUN=NROW)
    names(arrived.day) <- c("Appt.Date", "Appt.Day", "Arrived")
    
    arrived.day <- aggregate(arrived.day$Arrived, by=list(arrived.day$Appt.Day), FUN=mean)
    names(arrived.day) <- c("Appt.Day", "Arrived")
    
    noShow.day <- full_join(noShow.day, arrived.day, by="Appt.Day")
    noShow.day[is.na(noShow.day)] <- 0
    noShow.day$percent <- paste(round((noShow.day$noShow / (noShow.day$noShow + noShow.day$Arrived)*100),1),"%",sep=" ")
    
    
    noShow.day$Arrived <- NULL
    names(noShow.day) <- c("Day","Average No Show Count per Day", "Average No Show % per Day ")
    noShow.day <- setNames(data.frame(t(noShow.day[,-1])), noShow.day[,1]) #Transpose table
    
    noShow.day %>%
      knitr::kable("html", align = "l") %>%
      kable_styling(bootstrap_options = c("striped", "hover"), full_width=F, position="center", font_size = 15) %>%
      row_spec(0, bold=T) %>%
      column_spec(1, bold=T, width = "8cm")
  }
 
  
  # 7. Lead days to cancelled appointments (bar graph)
  
  output$schedule7 <- renderPlot({
    
    cancelled.data <- dataset.all()[which(dataset.all()$Status == "CAN"),]
    cancelled.data$Date.Cancelled <- strptime(cancelled.data$Date.Cancelled , format="%m/%d/%Y")
    cancelled.data$Date.Cancelled <- as.POSIXct(cancelled.data$Date.Cancelled)
    cancelled.data$lead.days <- cancelled.data$Appointment.Date - cancelled.data$Date.Cancelled
    cancelled.data$lead.days <- cancelled.data$lead.days/(24*3600)
    
    cancelled.data$cancelled.status <- ifelse(cancelled.data$lead.days >= 7, ">= 7 days", 
                                              ifelse(cancelled.data$lead.days < 7 & cancelled.data$lead.days >= 5, "5-6 days",
                                                     ifelse(cancelled.data$lead.days < 5 & cancelled.data$lead.days >= 3, "3-4 days",
                                                            ifelse(cancelled.data$lead.days < 3 & cancelled.data$lead.days >= 1, "1-2 days",
                                                                   ifelse(cancelled.data$lead.days == 0, "0 day"," ")))))
    
    cancelled.status.data <- cancelled.data[-which(cancelled.data$cancelled.status == " "),]
    cancelled.status <- aggregate(cancelled.status.data$unique, by=list(cancelled.status.data$cancelled.status),FUN=NROW)
    names(cancelled.status) <- c("status","count")
    
    status <- c('>= 7 days','5-6 days','3-4 days','1-2 days','0 day')
    cancelled.status <- cancelled.status[order(factor(cancelled.status$status, levels=status)),]
    
    cancelled.status[is.na(cancelled.status)] <- 0
    cancelled.status$percent = round((cancelled.status$count / sum(cancelled.status$count))*100,1)
    cancelled.status[is.na(cancelled.status)] <- 0
    
    
  # Graph of .... Count (bar)
  cancelled.Ct.graph <-  ggplot(cancelled.status, aes(x=status, y=count))+
    geom_bar(stat="identity",  fill="midnightblue", width=0.6)+
    ggtitle("Breakdown of Lead Days to Appointment Cancellation")+
    scale_x_discrete(limits=cancelled.status$status)+
    ylab("Count of Cancelled Appointments")+
    #xlab("Appointment Cancelled Date - Scheduled Appointment Date")+
    theme_bw()+
    theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20,  margin = margin(b=50)),
          axis.title = element_text(size="14"),
          axis.text = element_text(size="14"),
          axis.title.x = element_blank(),
          axis.title.y = element_text(margin = margin(r=5)),
          axis.text.x = element_text(angle = 0,hjust = 0.5, margin = margin(t=20)),
          axis.text.y = element_text(margin = margin(l=5, r=5)),
          panel.grid.minor = element_blank(),
          panel.border = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(size = 0.3, colour = "black"),
          plot.margin = margin(0,45,55,0))+
      geom_text(aes(label=count), vjust=1.6, color="white", fontface="bold",
                position = position_dodge(0.9), size=4.5)
    
  # Graph of .... Percent (bar)
  cancelled.Pct.graph <- ggplot(cancelled.status, aes(x=status, y=percent))+
    geom_bar(stat="identity",  fill="midnightblue", width=0.6)+
    ggtitle("Breakdown of Lead Days to Appointment Cancellation")+
    scale_x_discrete(limits=cancelled.status$status)+
    ylab("Percent of Cancelled Appointments")+
    #xlab("Appointment Cancelled Date - Scheduled Appointment Date")+
    theme_bw()+
    theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20,  margin = margin(b=50)),
          axis.title = element_text(size="14"),
          axis.text = element_text(size="14"),
          axis.title.x = element_blank(),
          axis.title.y = element_text(margin = margin(r=5)),
          axis.text.x = element_text(angle = 0,hjust = 0.5, margin = margin(t=20)),
          axis.text.y = element_text(margin = margin(l=5, r=5)),
          panel.grid.minor = element_blank(),
          panel.border = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(size = 0.3, colour = "black"),
          plot.margin = margin(0,45,55,0))+
      geom_text(aes(label=paste(percent,"%",sep=" ")), vjust=1.6, color="white", fontface="bold",
                position = position_dodge(0.9), size=4.5)
  
  
    grid.arrange(cancelled.Ct.graph, cancelled.Pct.graph, ncol=2)
    
    
  })
  
  # 8. Average Daily Patients Scheduled vs. Actual Arrival Time Comparison - Hour-Interval (line graph)

  output$schedule8 <- renderPlot({
  
  arrived.data <- dataset.all()[which(dataset.all()$Status == "ARR"),]
  arrived.scheduled.hour <- aggregate(arrived.data$unique, by=list(arrived.data$Appt.Time.Hour, arrived.data$Appt.Date), FUN=NROW)
  names(arrived.scheduled.hour) <- c("Time","Date","Count")
  arrived.scheduled.hour <- aggregate(arrived.scheduled.hour$Count, by=list(arrived.scheduled.hour$Time), FUN=mean)
  names(arrived.scheduled.hour) <- c("Time","Count")
  
  arrived.arrived.hour <- aggregate(arrived.data$unique, by=list(arrived.data$Arr.Time.Hour, arrived.data$Appt.Date), FUN=NROW)
  names(arrived.arrived.hour) <- c("Time","Date","Count")
  arrived.arrived.hour <- aggregate(arrived.arrived.hour$Count, by=list(arrived.arrived.hour$Time), FUN=mean)
  names(arrived.arrived.hour) <- c("Time","Count")
  
  arrived.scheduled.hour$arrived <- round(arrived.arrived.hour$Count[match(arrived.scheduled.hour$Time, arrived.arrived.hour$Time)],1)
  arrived.scheduled.hour[is.na(arrived.scheduled.hour)] <- 0
  names(arrived.scheduled.hour) <- c("Time","Scheduled","Actual")
  arrived.scheduled.hour$Scheduled <- round(arrived.scheduled.hour$Scheduled,1)
  
  arrived.scheduled.hour <- melt(arrived.scheduled.hour, id="Time", measure = c("Scheduled","Actual"))
  names(arrived.scheduled.hour) <- c("Time","variable","Count")
  
  # Scheduled vs. Actual Arrival in Hour Interval 
  
  ggplot(arrived.scheduled.hour, aes(x=Time, y=Count, col=variable, group=variable))+
    geom_line(aes(linetype=variable), size=1)+
    scale_linetype_manual(values=c("dashed","solid"))+
    scale_color_manual(values=c("maroon1","midnightblue"))+
    ggtitle("Average Daily Patients Scheduled vs. Actual Arrival Time Comparison")+
    ylab("Patient Count")+
    theme_bw()+
    theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
          legend.position = "top",
          legend.text = element_text(size="12"),
          legend.direction = "horizontal",
          legend.key.size = unit(1.0,"cm"),
          legend.title = element_blank(),
          axis.title = element_text(size="14"),
          axis.text = element_text(size="14"),
          axis.title.x = element_blank(),
          axis.title.y = element_text(margin = margin(r=5)),
          axis.text.x = element_text(angle = 90,hjust = 0.5, margin = margin(t=10)),
          axis.text.y = element_text(margin = margin(l=5, r=5)),
          panel.grid.minor = element_blank(),
          panel.border = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(size = 0.3, colour = "black"),
          plot.margin = margin(30,30,30,30))
    
  })
  
  # 9. Average Daily Patients Scheduled vs. Actual Arrival Time Comparison - 30-Min Interval (line graph)
  
  output$schedule9 <- renderPlot({
    
    arrived.data <- dataset.all()[which(dataset.all()$Status == "ARR"),]
    arrived.scheduled.30min <- aggregate(arrived.data$unique, by=list(arrived.data$Appt.Time.30min, arrived.data$Appt.Date), FUN=NROW)
    names(arrived.scheduled.30min) <- c("Time","Date","Count")
    arrived.scheduled.30min <- aggregate(arrived.scheduled.30min$Count, by=list(arrived.scheduled.30min$Time), FUN=mean)
    names(arrived.scheduled.30min) <- c("Time","Count")
    
    arrived.arrived.30min <- aggregate(arrived.data$unique, by=list(arrived.data$Arr.Time.30min, arrived.data$Appt.Date), FUN=NROW)
    names(arrived.arrived.30min) <- c("Time","Date","Count")
    arrived.arrived.30min <- aggregate(arrived.arrived.30min$Count, by=list(arrived.arrived.30min$Time), FUN=mean)
    names(arrived.arrived.30min) <- c("Time","Count")
    
    arrived.scheduled.30min$arrived <- round(arrived.arrived.30min$Count[match(arrived.scheduled.30min$Time, arrived.arrived.30min$Time)],1)
    arrived.scheduled.30min[is.na(arrived.scheduled.30min)] <- 0
    names(arrived.scheduled.30min) <- c("Time","Scheduled","Actual")
    arrived.scheduled.30min$Scheduled <- round(arrived.scheduled.30min$Scheduled,1)
    
    arrived.scheduled.30min <- melt(arrived.scheduled.30min, id="Time", measure = c("Scheduled","Actual"))
    names(arrived.scheduled.30min) <- c("Time","variable","Count")
    
    # Scheduled vs. Actual Arrival in 30min Interval 
    
    ggplot(arrived.scheduled.30min, aes(x=Time, y=Count, col=variable, group=variable))+
      geom_line(aes(linetype=variable), size=1)+
      scale_linetype_manual(values=c("dashed","solid"))+
      scale_color_manual(values=c("maroon1","midnightblue"))+
      ggtitle("Average Daily Patients Scheduled vs. Actual Arrival Time Comparison (30min)")+
      ylab("Patient Count")+
      theme_bw()+
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
            legend.position = "top",
            legend.text = element_text(size="12"),
            legend.direction = "horizontal",
            legend.key.size = unit(1.0,"cm"),
            legend.title = element_blank(),
            axis.title = element_text(size="14"),
            axis.text = element_text(size="14"),
            axis.title.x = element_blank(),
            axis.title.y = element_text(margin = margin(r=5)),
            axis.text.x = element_text(angle = 90,hjust = 0.5, margin = margin(t=10)),
            axis.text.y = element_text(margin = margin(l=5, r=5)),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(size = 0.3, colour = "black"),
            plot.margin = margin(30,30,30,30))
    
    
  })
  
  
  # 10. Patient Lateness (bar graph)
  
  output$schedule10 <- renderPlot({
    
    arrived.data <- dataset.all()[which(dataset.all()$Status == "ARR"),]
    arrived.data$pt.late <- arrived.data$Time.Arrived - arrived.data$Appointment.Time
    arrived.data$pt.late <- arrived.data$pt.late/60
    
    arrived.data$status <- ifelse(arrived.data$pt.late <=-45, "<=-45 min", 
                                  ifelse(arrived.data$pt.late > -45 & arrived.data$pt.late <= -30, "-30 min",
                                         ifelse(arrived.data$pt.late > -30 & arrived.data$pt.late <= -15, "-15 min",
                                                ifelse(arrived.data$pt.late > -15 & arrived.data$pt.late <= 0, "0 min",
                                                       ifelse(arrived.data$pt.late > 0 & arrived.data$pt.late <= 15, "15 min",
                                                              ifelse(arrived.data$pt.late > 15 & arrived.data$pt.late <= 30, "30 min",
                                                                     ifelse(arrived.data$pt.late > 30 & arrived.data$pt.late <= 45, "45 min",
                                                                            ifelse(arrived.data$pt.late > 45, ">45 min", ""))))))))
    
    pt.late.status <- aggregate(unique ~ status + Appt.Date, data=arrived.data, FUN=NROW)
    pt.late.status <- aggregate(unique ~ status, data=pt.late.status, FUN=mean)
    names(pt.late.status) <- c("status","count")
    
    status <- c('<=-45 min','-30 min','-15 min','0 min','15 min','30 min','45 min','>45 min')
    pt.late.status <- pt.late.status[order(factor(pt.late.status$status, levels=status)),]
    
    pt.late.status[is.na(pt.late.status)] <- 0
    pt.late.status$percent = round((pt.late.status$count / sum(pt.late.status$count))*100,1)
    pt.late.status[is.na(pt.late.status)] <- 0

    pt.late.status[1:4,4] <- "Early Arrival"
    pt.late.status[5:8,4] <- "Late Arrival"
    
    names(pt.late.status) <- c("status","count","percent","lateness")
    pt.late.status$count <- round(pt.late.status$count,1)
    
    pt.late.status$lateness <- factor(pt.late.status$lateness, levels = c("Early Arrival","Late Arrival"))
    
    # Count of late patients (bar graph)
    
    late.Ct.graph <- ggplot(pt.late.status, aes(x=factor(status,level=status), y=count, group=lateness, fill=factor(lateness)))+
      geom_bar(stat="identity", width=0.6)+
      facet_grid(.~lateness, scales = "free_x",space = "free_x")+
      scale_fill_manual(values=c("midnightblue","maroon1"))+
      ggtitle("Breakdown of Patient Arrival Times: Scheduled vs. Actual Arrival Times)")+
      ylab("Average Daily Patient Count")+
      xlab("Time Difference (Actual - Scheduled Arrival Time)")+
      theme_bw()+
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20, margin = margin(b=50)),
            axis.title = element_text(size="14"),
            axis.text = element_text(size="14"),
            axis.title.x = element_text(margin = margin(t=15)),
            axis.title.y = element_text(margin = margin(r=5)),
            axis.text.x = element_text(angle = 0,hjust = 0.5, margin = margin(t=20)),
            axis.text.y = element_text(margin = margin(l=5, r=5)),
            legend.position = "none",
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(size = 0.3, colour = "black"),
            plot.margin = margin(0,45,100,0))+
      theme(strip.text = element_text(face="bold", size=14, colour = "black"),
            strip.background = element_rect(fill="grey93"))+
      geom_text(aes(label=count), vjust=1.6, color="white", fontface="bold",
                position = position_dodge(0.9), size=4.5)
    
    # Percent of late patients (bar graph)
    
    late.Pct.graph <- ggplot(pt.late.status, aes(x=factor(status,level=status), y=percent, group=lateness, fill=factor(lateness)))+
      geom_bar(stat="identity", width=0.6)+
      facet_grid(.~lateness, scales = "free_x",space = "free_x")+
      scale_fill_manual(values=c("midnightblue","maroon1"))+
      ggtitle("Breakdown of Patient Arrival Times: Scheduled vs. Actual Arrival Times)")+
      ylab("Percent of Patients")+
      xlab("Time Difference (Actual - Scheduled Arrival Time)")+
      theme_bw()+
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20, margin = margin(b=50)),
            axis.title = element_text(size="14"),
            axis.text = element_text(size="14"),
            axis.title.x = element_text(margin = margin(t=15)),
            axis.title.y = element_text(margin = margin(r=5)),
            axis.text.x = element_text(angle = 0,hjust = 0.5, margin = margin(t=20)),
            axis.text.y = element_text(margin = margin(l=5, r=5)),
            legend.position = "none",
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(size = 0.3, colour = "black"),
            plot.margin = margin(0,45,100,0))+
      theme(strip.text = element_text(face="bold", size=14, colour = "black"),
            strip.background = element_rect(fill="grey93"))+
      geom_text(aes(label=paste(percent,"%",sep=" ")), vjust=1.6, color="white", fontface="bold",
                position = position_dodge(0.9), size=4.5)
    
    grid.arrange(late.Ct.graph, late.Pct.graph)
    
    
  })
  
  
  ################################################################################
  ######### (4) Space Analysis Tab ##############################################
  ################################################################################
  
  # Average scheduled vs. actual space utilization 
  
  output$space1 <- renderPlot({
    
    time.hour.df <- dataset.scheduled.hour()
    
    c.start <- which(colnames(time.hour.df)=="00:00")
    c.end <- which(colnames(time.hour.df)=="23:00")
    
    space.scheduled <- aggregate(time.hour.df[c(c.start:c.end)], list(time.hour.df$Appointment.Date, time.hour.df$Status),FUN = sum)
    space.scheduled <- melt(space.scheduled, id=c("Group.1", "Group.2"))
    
    space.scheduled <- aggregate(space.scheduled$value, by=list(space.scheduled$Group.2, space.scheduled$variable), FUN=mean)
    
    space.arrived <- space.scheduled%>%
      filter(space.scheduled$Group.1 %in% c("ARR"))
    
    space.noshow <- space.scheduled%>%
      filter(space.scheduled$Group.1 %in% c("NOS"))
    
    space.arrived$noshow <- space.noshow$x[match(space.arrived$Group.2, space.noshow$Group.2)]
    space.arrived$total <- space.arrived$x + space.arrived$noshow
    
    space.arrived <- space.arrived[,c("Group.2","x","total")]
    
    space.arrived[,2:3] <- round(space.arrived[,2:3]/60, 1)
    names(space.arrived) <- c("Time","Arrived","Scheduled")
    space.arrived <- melt(space.arrived, id=c("Time"))
    
    ggplot(space.arrived, aes(x=Time, y=value, col=variable, group=variable))+
      geom_line(aes(linetype=variable), size=1)+
      scale_linetype_manual(values=c("solid","dashed"))+
      scale_color_manual(values=c("midnightblue","maroon1"))+
      ggtitle(label="Average Scheduled vs. Actual Room Utilization by Time of Day",
              subtitle = "Based on scheduled appointment time and duration")+
      ylab("Room Count")+
      theme_bw()+
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
            plot.subtitle = element_text(hjust=0.5, size = 15, face = "italic"),
            legend.position = "top",
            legend.text = element_text(size="12"),
            legend.direction = "horizontal",
            legend.key.size = unit(1.0,"cm"),
            legend.title = element_blank(),
            axis.title = element_text(size="14"),
            axis.text = element_text(size="14"),
            axis.title.x = element_blank(),
            axis.title.y = element_text(margin = margin(r=5)),
            axis.text.x = element_text(angle = 90,hjust = 0.5, margin = margin(t=10)),
            axis.text.y = element_text(margin = margin(l=5, r=5)),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(size = 0.3, colour = "black"),
            plot.margin = margin(30,30,30,30))
   
  })
  
  # Average space utilization by 30-min interval 
  
  #output$space2 <- renderPlot({
    
   # time.30min.df <- dataset.scheduled.30min()
    
    #c.start <- which(colnames(time.30min.df)=="00:00")
    #c.end <- which(colnames(time.30min.df)=="23:30")
    
    #space.scheduled <- aggregate(time.30min.df[c(c.start:c.end)], list(time.30min.df$Appointment.Date, time.30min.df$Status),FUN = sum)
    #space.scheduled <- melt(space.scheduled, id=c("Group.1", "Group.2"))
    
    #space.scheduled <- aggregate(space.scheduled$value, by=list(space.scheduled$Group.2, space.scheduled$variable), FUN=mean)
    
    #space.arrived <- space.scheduled%>%
     # filter(space.scheduled$Group.1 %in% c("ARR"))
    
    #space.noshow <- space.scheduled%>%
     # filter(space.scheduled$Group.1 %in% c("NOS"))
    
    #space.arrived$noshow <- space.noshow$x[match(space.arrived$Group.2, space.noshow$Group.2)]
    #space.arrived$total <- space.arrived$x + space.arrived$noshow
    
    #space.arrived <- space.arrived[,c("Group.2","x","total")]
    
    #space.arrived[,2:3] <- round(space.arrived[,2:3]/60, 1)
    #names(space.arrived) <- c("Time","Arrived","Scheduled")
    #space.arrived <- melt(space.arrived, id=c("Time"))
    
    #ggplot(space.arrived, aes(x=Time, y=value, col=variable, group=variable))+
     # geom_line(aes(linetype=variable), size=1)+
      #scale_linetype_manual(values=c("solid","dashed"))+
      #scale_color_manual(values=c("midnightblue","maroon1"))+
      #ggtitle(label="Average Scheduled vs. Actual Room Utilization by Time of Day",
       #       subtitle = "Based on scheduled appointment time and duration")+
      #ylab("Room Count")+
      #theme_bw()+
      #theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
       #     plot.subtitle = element_text(hjust=0.5, size = 15, face = "italic"),
        #    legend.position = "top",
         #   legend.text = element_text(size="12"),
          #  legend.direction = "horizontal",
           # legend.key.size = unit(1.0,"cm"),
            #legend.title = element_blank(),
            #axis.title = element_text(size="14"),
            #axis.text = element_text(size="14"),
            #axis.title.x = element_blank(),
            #axis.title.y = element_text(margin = margin(r=5)),
            #axis.text.x = element_text(angle = 90,hjust = 0.5, margin = margin(t=10)),
            #axis.text.y = element_text(margin = margin(l=5, r=5)),
            #panel.grid.minor = element_blank(),
            #panel.border = element_blank(),
            #panel.background = element_blank(),
            #axis.line = element_line(size = 0.3, colour = "black"),
            #plot.margin = margin(30,30,30,30))
    
  #})
  
  output$space3 <- renderPlot({
    
    time.hour.df <- dataset.scheduled.hour()
    
    c.start <- which(colnames(time.hour.df)=="00:00")
    c.end <- which(colnames(time.hour.df)=="23:00")
    
    space.hour <- aggregate(time.hour.df[c(c.start:c.end)], list(time.hour.df$Appointment.Date),FUN = sum)
    space.hour <- melt(space.hour, id=c("Group.1"))
    space.hour.med <- aggregate(space.hour$value, list(space.hour$variable), FUN=median)
    
    space.hour.70 <- aggregate(space.hour$value, list(space.hour$variable), FUN = function(x) quantile(x, probs = 0.70))
    space.hour.90 <- aggregate(space.hour$value, list(space.hour$variable), FUN = function(x) quantile(x, probs = 0.90))
    
    space.hour.med$percentile70 <- space.hour.70$x[match(space.hour.med$Group.1, space.hour.70$Group.1)]
    space.hour.med$percentile90 <- space.hour.90$x[match(space.hour.med$Group.1, space.hour.90$Group.1)]
    
    space.hour.med[,2:4] <- round(space.hour.med[,2:4]/60, 1)
    names(space.hour.med) <- c("Time","Median","70th Percentile","90th Percentile")
    
    space.hour.med <- melt(space.hour.med, id=c("Time"))
    
    ggplot(space.hour.med, aes(x=Time, y=value, col=variable, group=variable))+
      geom_line(size=1)+
      scale_color_manual(values=c("deepskyblue","maroon1","midnightblue"))+
      ggtitle(label="Room Utilization by Time of Day",
              subtitle = "Based on scheduled appointment time and duration")+
      ylab("Room Count")+
      theme_bw()+
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
            plot.subtitle = element_text(hjust=0.5, size = 15, face = "italic"),
            legend.position = "top",
            legend.text = element_text(size="12"),
            legend.direction = "horizontal",
            legend.key.size = unit(1.0,"cm"),
            legend.title = element_blank(),
            axis.title = element_text(size="14"),
            axis.text = element_text(size="14"),
            axis.title.x = element_blank(),
            axis.title.y = element_text(margin = margin(r=5)),
            axis.text.x = element_text(angle = 90,hjust = 0.5, margin = margin(t=10)),
            axis.text.y = element_text(margin = margin(l=5, r=5)),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(size = 0.3, colour = "black"),
            plot.margin = margin(30,30,30,30))
    
  })
  
  
  output$space4 <- renderPlot({
    
    time.30min.df <- dataset.scheduled.30min()
    
    c.start <- which(colnames(time.30min.df)=="00:00")
    c.end <- which(colnames(time.30min.df)=="23:30")
    
    space.30min <- aggregate(time.30min.df[c(c.start:c.end)], list(time.30min.df$Appointment.Date),FUN = sum)
    space.30min <- melt(space.30min, id=c("Group.1"))
    space.30min.med <- aggregate(space.30min$value, list(space.30min$variable), FUN=median)
    
    space.30min.70 <- aggregate(space.30min$value, list(space.30min$variable), FUN = function(x) quantile(x, probs = 0.70))
    space.30min.90 <- aggregate(space.30min$value, list(space.30min$variable), FUN = function(x) quantile(x, probs = 0.90))
    
    space.30min.med$percentile70 <- space.30min.70$x[match(space.30min.med$Group.1, space.30min.70$Group.1)]
    space.30min.med$percentile90 <- space.30min.90$x[match(space.30min.med$Group.1, space.30min.90$Group.1)]
    
    space.30min.med[,2:4] <- round(space.30min.med[,2:4]/60, 1)
    names(space.30min.med) <- c("Time","Median","70th Percentile","90th Percentile")
    
    space.30min.med <- melt(space.30min.med, id=c("Time"))
    
    ggplot(space.30min.med, aes(x=Time, y=value, col=variable, group=variable))+
      geom_line(size=1)+
      scale_color_manual(values=c("deepskyblue","maroon1","midnightblue"))+
      ggtitle(label="Room Utilization by Time of Day",
              subtitle = "Based on scheduled appointment time and duration")+
      ylab("Room Count")+
      theme_bw()+
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
            plot.subtitle = element_text(hjust=0.5, size = 15, face = "italic"),
            legend.position = "top",
            legend.text = element_text(size="12"),
            legend.direction = "horizontal",
            legend.key.size = unit(1.0,"cm"),
            legend.title = element_blank(),
            axis.title = element_text(size="14"),
            axis.text = element_text(size="14"),
            axis.title.x = element_blank(),
            axis.title.y = element_text(margin = margin(r=5)),
            axis.text.x = element_text(angle = 90,hjust = 0.5, margin = margin(t=10)),
            axis.text.y = element_text(margin = margin(l=5, r=5)),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(size = 0.3, colour = "black"),
            plot.margin = margin(30,30,30,30))
    
  })
  
  # Average utilization by time of day and day of week (hour interval)
  
  output$space5 <- renderPlot({
    
    time.hour.df <- dataset.scheduled.hour()
    
    c.start <- which(colnames(time.hour.df)=="00:00")
    c.end <- which(colnames(time.hour.df)=="23:00")
    
    space.hour.day <- aggregate(time.hour.df[c(c.start:c.end)], list(time.hour.df$Appt.Day, time.hour.df$Appointment.Date),FUN = sum)
    space.hour.day <- melt(space.hour.day, id=c("Group.1","Group.2"))
    space.hour.day <- aggregate(space.hour.day$value, list(space.hour.day$Group.1,space.hour.day$variable), FUN=mean)
    
    space.hour.day$x <- round(space.hour.day$x /60, 1)
    names(space.hour.day) <- c("Day","Time","value")
    
    
    ggplot(space.hour.day, aes(x=Time, y=value, col=Day, group=Day))+
      geom_line(size=1)+
      #scale_color_manual(values=c("deepskyblue","maroon1","midnightblue"))+
      ggtitle(label="Space Utilization by Time of Day and Day of Week",
              subtitle = "Based on scheduled appointment time and duration")+
      ylab("Room Count")+
      theme_bw()+
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
            plot.subtitle = element_text(hjust=0.5, size = 15, face = "italic"),
            legend.position = "top",
            legend.text = element_text(size="12"),
            legend.direction = "horizontal",
            legend.key.size = unit(1.0,"cm"),
            legend.title = element_blank(),
            axis.title = element_text(size="14"),
            axis.text = element_text(size="14"),
            axis.title.x = element_blank(),
            axis.title.y = element_text(margin = margin(r=5)),
            axis.text.x = element_text(angle = 90,hjust = 0.5, margin = margin(t=10)),
            axis.text.y = element_text(margin = margin(l=5, r=5)),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(size = 0.3, colour = "black"),
            plot.margin = margin(30,30,30,30))+
      guides(colour = guide_legend(nrow = 1))
    
  })
  
  # Average utilization by time of day and day of week (30-min interval)
  output$space6 <- renderPlot({
    
    time.30min.df <- dataset.scheduled.30min()
    
    c.start <- which(colnames(time.30min.df)=="00:00")
    c.end <- which(colnames(time.30min.df)=="23:30")
    
    space.30min.day <- aggregate(time.30min.df[c(c.start:c.end)], list(time.30min.df$Appt.Day, time.30min.df$Appointment.Date),FUN = sum)
    space.30min.day <- melt(space.30min.day, id=c("Group.1","Group.2"))
    space.30min.day <- aggregate(space.30min.day$value, list(space.30min.day$Group.1,space.30min.day$variable), FUN=mean)
    
    space.30min.day$x <- round(space.30min.day$x /60, 1)
    names(space.30min.day) <- c("Day","Time","value")
    
    
    ggplot(space.30min.day, aes(x=Time, y=value, col=Day, group=Day))+
      geom_line(size=1)+
      #scale_color_manual(values=c("deepskyblue","maroon1","midnightblue"))+
      ggtitle(label="Space Utilization by Time of Day and Day of Week",
              subtitle = "Based on scheduled appointment time and duration")+
      ylab("Room Count")+
      theme_bw()+
      theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
            plot.subtitle = element_text(hjust=0.5, size = 15, face = "italic"),
            legend.position = "top",
            legend.text = element_text(size="12"),
            legend.direction = "horizontal",
            legend.key.size = unit(1.0,"cm"),
            legend.title = element_blank(),
            axis.title = element_text(size="14"),
            axis.text = element_text(size="14"),
            axis.title.x = element_blank(),
            axis.title.y = element_text(margin = margin(r=5)),
            axis.text.x = element_text(angle = 90,hjust = 0.5, margin = margin(t=10)),
            axis.text.y = element_text(margin = margin(l=5, r=5)),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(size = 0.3, colour = "black"),
            plot.margin = margin(30,30,30,30))+ 
      guides(colour = guide_legend(nrow = 1))
    
  })
  
  
  
  
} # Close Server


###############################################################################################################################

#################################################### APPLICATION RUN ##########################################################

###############################################################################################################################

shinyApp(ui = ui, server = server)

arrived.data <- data.raw[which(data.raw$Status=="ARR"),]
noshow.data <- data.raw[which(data.raw$Status=="NOS"),]
cancelled.data <- data.raw[which(data.raw$Status=="CAN"),]

str(arrived.data)

arrived.data$pt.late <- arrived.data$Time.Arrived - arrived.data$Appointment.Time
arrived.data$pt.late <- arrived.data$pt.late/60

arrived.data$status <- ifelse(arrived.data$pt.late <=-45, "<=-45 min", 
                                            ifelse(arrived.data$pt.late > -45 & arrived.data$pt.late <= -30, "-30 min",
                                                   ifelse(arrived.data$pt.late > -30 & arrived.data$pt.late <= -15, "-15 min",
                                                          ifelse(arrived.data$pt.late > -15 & arrived.data$pt.late <= 0, "0 min",
                                                                 ifelse(arrived.data$pt.late > 0 & arrived.data$pt.late <= 15, "15 min",
                                                                        ifelse(arrived.data$pt.late > 15 & arrived.data$pt.late <= 30, "30 min",
                                                                               ifelse(arrived.data$pt.late > 30 & arrived.data$pt.late <= 45, "45 min",
                                                                                      ifelse(arrived.data$pt.late > 45, ">45 min", ""))))))))

pt.late.status <- aggregate(unique ~ status + Appt.Date, data=arrived.data, FUN=NROW)
pt.late.status <- aggregate(unique ~ status, data=pt.late.status, FUN=mean)
names(pt.late.status) <- c("status","count")

status <- c('<=-45 min','-30 min','-15 min','0 min','15 min','30 min','45 min','>45 min')
pt.late.status <- pt.late.status[order(factor(pt.late.status$status, levels=status)),]

pt.late.status[is.na(pt.late.status)] <- 0
pt.late.status$percent = round((pt.late.status$count / sum(pt.late.status$count))*100,1)
pt.late.status[is.na(pt.late.status)] <- 0

#pt.late.status <- rbind(pt.late.status, pt.late.status, pt.late.status)

pt.late.status[1:4,4] <- "Early Arrival"
pt.late.status[5:8,4] <- "Late Arrival"

names(pt.late.status) <- c("status","count","percent","lateness")

pt.late.status$lateness <- factor(pt.late.status$lateness, levels = c("Early Arrival","Late Arrival"))





  
  








ggplot(cancelled.data, aes(x=factor(lead.days)))+
  geom_bar(aes(y = (..count..)/sum(..count..)))+
  scale_y_continuous(labels = percent)+
  geom_text(aes(label=percent), vjust=1.6, color="white", fontface="bold", position = position_dodge(0.9), size=4.5)
  


noShow.payer <- aggregate(noshow.data$unique, by=list(noshow.data$Appt.Date, noshow.data$Primary.Category), FUN=NROW)
names(noShow.payer) <- c("Appt.Date","Primary.Category","Count")

noShow.payer <- aggregate(noShow.payer$Count, by=list(noShow.payer$Primary.Category), FUN=mean)
names(noShow.payer) <- c("Primary.Category","Count")

noShow.payer %>% 
  mutate(Cum = (cumsum(Count)/sum(Count))*100)

#noShow.payer <- round(noShow.payer[,2:3],1)
#names(noShow.payer) <- c("Insurance","NoShow", "Cumulative")

noShow.payer.graph <- ggplot(noShow.payer, aes(x = reorder(Primary.Category, -Count), y = Count))+
  geom_bar(stat = "identity", width = 0.6)+
  scale_y_continuous(limits= c(0,100))+
  theme(axis.text.x = element_text(angle = 90,hjust = 1))+
  stat_pareto(point.color = "maroon1",
              point.size = 2,
              line.color = "maroon1")

ggplotly(noShow.payer.graph)

departments <- c("BI UROLOGY")

apptType <- function(dt, departments){
  result <- dt %>% filter(Department %in% departments)
  result <- unique(result$Appt.Name.Long)+
    
  
  return(result)
}

apptType(arrived.data, departments)

noShow.day <- aggregate(unique ~ Appt.Date + Appt.Day, data=noshow.data, FUN=NROW)
names(noShow.day) <- c("Appt.Date", "Appt.Day", "noShow")
str(noShow.day)

noShow.day <- aggregate(noShow ~ Appt.Day, data=noShow.day, FUN=mean)
names(noShow.day) <- c("Appt.Day", "noShow")
noShow.day$noShow <- round(noShow.day$noShow,0)

arrived.day <- aggregate(unique ~ Appt.Date + Appt.Day, data=arrived.data, FUN=NROW)
names(arrived.day) <- c("Appt.Date", "Appt.Day", "Arrived")

arrived.day <- aggregate(Arrived ~ Appt.Day, data=arrived.day, FUN=mean)
names(arrived.day) <- c("Appt.Day", "Arrived")

noShow.day<- full_join(arrived.day, noShow.day, by="Appt.Day")
noShow.day[is.na(noShow.day)] <- 0

noShow.day$percent <- paste(round((noShow.day$noShow / (noShow.day$noShow + noShow.day$Arrived)*100),1),"%",sep=" ")

noShow.day$Arrived <- NULL
names(noShow.day) <- c("Day","AVerage No Show per Day", "Average No Show % per Day ")
noShow.day <- setNames(data.frame(t(noShow.day[,-1])), noShow.day[,1])

noShow.day %>%
  knitr::kable("html", align = "l") %>%
  kable_styling(bootstrap_options = c("striped", "hover"), full_width=F, position="center", font_size = 15) %>%
  row_spec(0, bold=T) %>%
  column_spec(1, bold=T, width = "3cm")













#######################################################
#                                                     #
#                   Graph Formatting                  #
#                                                     #
#######################################################

#Non-Plotly Bar Graphs
theme_bw()+
theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
      axis.title = element_text(size="14"),
      axis.text = element_text(size="14"),
      axis.title.x = element_blank(),
      axis.title.y = element_text(margin = margin(r=5)),
      axis.text.x = element_text(angle = 45,hjust = 1, margin = margin(t=10)),
      axis.text.y = element_text(margin = margin(l=5, r=5)),
      panel.grid.minor = element_blank(),
      panel.border = element_blank(),
      panel.background = element_blank(),
      axis.line = element_line(size = 0.3, colour = "black"),
      plot.margin = margin(0,45,55,0))+

#Non-Plotly Heat Maps 
  theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
        legend.position = "bottom",
        legend.direction = "horizontal",
        legend.key.size = unit(0.7,"cm"),
        legend.text = element_text(size="12"),
        axis.title.x = element_text(size="14", margin = unit(c(8, 8, 8, 8), "mm")),
        axis.title.y = element_text(size="14", margin = unit(c(8, 8, 8, 8), "mm")),
        axis.text.x = element_text(color="black", angle=45, vjust=0.5, hjust = 0, margin = margin(b=15, t=100)),
        axis.text.y = element_text(color= "black", margin = margin(r=15)),
        axis.text = element_text(size="14"),
        panel.background = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        plot.margin = margin(30,30,30,30))+
  geom_text(aes(label=paste(noShow.percent,"%", sep = " ")), color="black", size=5, fontface="bold")

#Plotly Stacked Bars
theme_bw()+
theme(plot.title = element_text(hjust=0.5, face = "bold", size = 15),
        legend.title = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = "10", margin = margin(l=30, r=100)),
        axis.text.x = element_text(size = "10", angle=0, vjust=0.5, margin = margin(t=30)),
        axis.text.y = element_text(size = "10", margin = margin(r=30, l=30)),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(size = 0.3, colour = "black"),
        plot.margin = margin(0,30,30,0))

  
# Sinai color theme setup
# maroon1, midnightblue, deepskyblue

# Space Utilization
#time.hour.df
#time.30min.df
#space.hour.med <- setNames(data.frame(t(space.hour.med[,-1])), space.hour.med[,1])
noShow.payer <- aggregate(noshow.data$unique, by=list(noshow.data$Appt.Date, noshow.data$Primary.Category), FUN=NROW)


# Space utilization 
## Utilization in hourly interval

c.start <- which(colnames(time.hour.df)=="00:00")
c.end <- which(colnames(time.hour.df)=="23:00")

space.scheduled <- aggregate(time.hour.df[c(c.start:c.end)], list(time.hour.df$Appointment.Date, time.hour.df$Status),FUN = sum)
space.scheduled <- melt(space.scheduled, id=c("Group.1", "Group.2"))

space.scheduled <- aggregate(space.scheduled$value, by=list(space.scheduled$Group.2, space.scheduled$variable), FUN=mean)

space.arrived <- space.scheduled%>%
  filter(space.scheduled$Group.1 %in% c("ARR"))

space.noshow <- space.scheduled%>%
  filter(space.scheduled$Group.1 %in% c("NOS"))

space.arrived$noshow <- space.noshow$x[match(space.arrived$Group.2, space.noshow$Group.2)]
space.arrived$total <- space.arrived$x + space.arrived$noshow

space.arrived <- space.arrived[,c("Group.2","x","total")]

space.arrived[,2:3] <- round(space.arrived[,2:3]/60, 1)
names(space.arrived) <- c("Time","Arrived","Scheduled")
space.arrived <- melt(space.arrived, id=c("Time"))

ggplot(space.arrived, aes(x=Time, y=value, col=variable, group=variable))+
  geom_line(aes(linetype=variable), size=1)+
  scale_linetype_manual(values=c("solid","dashed"))+
  scale_color_manual(values=c("midnightblue","maroon1"))+
  ggtitle(label="Average Scheduled vs. Actual Room Utilization by Time of Day",
          subtitle = "Based on scheduled appointment time and duration")+
  ylab("Room Count")+
  theme_bw()+
  theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
        plot.subtitle = element_text(hjust=0.5, size = 15, face = "italic"),
        legend.position = "top",
        legend.text = element_text(size="12"),
        legend.direction = "horizontal",
        legend.key.size = unit(1.0,"cm"),
        legend.title = element_blank(),
        axis.title = element_text(size="14"),
        axis.text = element_text(size="14"),
        axis.title.x = element_blank(),
        axis.title.y = element_text(margin = margin(r=5)),
        axis.text.x = element_text(angle = 90,hjust = 0.5, margin = margin(t=10)),
        axis.text.y = element_text(margin = margin(l=5, r=5)),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(size = 0.3, colour = "black"),
        plot.margin = margin(30,30,30,30))


## Utilization in 30-min interval 

c.start <- which(colnames(time.30min.df)=="00:00")
c.end <- which(colnames(time.30min.df)=="23:30")

space.scheduled <- aggregate(time.30min.df[c(c.start:c.end)], list(time.30min.df$Appointment.Date, time.30min.df$Status),FUN = sum)
space.scheduled <- melt(space.scheduled, id=c("Group.1", "Group.2"))

space.scheduled <- aggregate(space.scheduled$value, by=list(space.scheduled$Group.2, space.scheduled$variable), FUN=mean)

space.arrived <- space.scheduled%>%
  filter(space.scheduled$Group.1 %in% c("ARR"))

space.noshow <- space.scheduled%>%
  filter(space.scheduled$Group.1 %in% c("NOS"))

space.arrived$noshow <- space.noshow$x[match(space.arrived$Group.2, space.noshow$Group.2)]
space.arrived$total <- space.arrived$x + space.arrived$noshow

space.arrived <- space.arrived[,c("Group.2","x","total")]

space.arrived[,2:3] <- round(space.arrived[,2:3]/60, 1)
names(space.arrived) <- c("Time","Arrived","Scheduled")
space.arrived <- melt(space.arrived, id=c("Time"))

ggplot(space.arrived, aes(x=Time, y=value, col=variable, group=variable))+
  geom_line(aes(linetype=variable), size=1)+
  scale_linetype_manual(values=c("solid","dashed"))+
  scale_color_manual(values=c("midnightblue","maroon1"))+
  ggtitle(label="Average Scheduled vs. Actual Room Utilization by Time of Day",
          subtitle = "Based on scheduled appointment time and duration")+
  ylab("Room Count")+
  theme_bw()+
  theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
        plot.subtitle = element_text(hjust=0.5, size = 15, face = "italic"),
        legend.position = "top",
        legend.text = element_text(size="12"),
        legend.direction = "horizontal",
        legend.key.size = unit(1.0,"cm"),
        legend.title = element_blank(),
        axis.title = element_text(size="14"),
        axis.text = element_text(size="14"),
        axis.title.x = element_blank(),
        axis.title.y = element_text(margin = margin(r=5)),
        axis.text.x = element_text(angle = 90,hjust = 0.5, margin = margin(t=10)),
        axis.text.y = element_text(margin = margin(l=5, r=5)),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(size = 0.3, colour = "black"),
        plot.margin = margin(30,30,30,30))


# Space utilization by percentile 

## Utilization in hourly interval 

c.start <- which(colnames(time.hour.df)=="00:00")
c.end <- which(colnames(time.hour.df)=="23:00")

space.hour <- aggregate(time.hour.df[c(c.start:c.end)], list(time.hour.df$Appointment.Date),FUN = sum)
space.hour <- melt(space.hour, id=c("Group.1"))
space.hour.med <- aggregate(space.hour$value, list(space.hour$variable), FUN=median)

space.hour.70 <- aggregate(space.hour$value, list(space.hour$variable), FUN = function(x) quantile(x, probs = 0.70))
space.hour.90 <- aggregate(space.hour$value, list(space.hour$variable), FUN = function(x) quantile(x, probs = 0.90))

space.hour.med$percentile70 <- space.hour.70$x[match(space.hour.med$Group.1, space.hour.70$Group.1)]
space.hour.med$percentile90 <- space.hour.90$x[match(space.hour.med$Group.1, space.hour.90$Group.1)]

space.hour.med[,2:4] <- round(space.hour.med[,2:4]/60, 1)
names(space.hour.med) <- c("Time","Median","70th Percentile","90th Percentile")

space.hour.med <- melt(space.hour.med, id=c("Time"))

ggplot(space.hour.med, aes(x=Time, y=value, col=variable, group=variable))+
  geom_line(size=1)+
  scale_color_manual(values=c("deepskyblue","maroon1","midnightblue"))+
  ggtitle(label="Room Utilization by Time of Day",
          subtitle = "Based on scheduled appointment time and duration")+
  ylab("Room Count")+
  theme_bw()+
  theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
        plot.subtitle = element_text(hjust=0.5, size = 15, face = "italic"),
        legend.position = "top",
        legend.text = element_text(size="12"),
        legend.direction = "horizontal",
        legend.key.size = unit(1.0,"cm"),
        legend.title = element_blank(),
        axis.title = element_text(size="14"),
        axis.text = element_text(size="14"),
        axis.title.x = element_blank(),
        axis.title.y = element_text(margin = margin(r=5)),
        axis.text.x = element_text(angle = 90,hjust = 0.5, margin = margin(t=10)),
        axis.text.y = element_text(margin = margin(l=5, r=5)),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(size = 0.3, colour = "black"),
        plot.margin = margin(30,30,30,30))

## Utilization in 30-min interval 

c.start <- which(colnames(time.30min.df)=="00:00")
c.end <- which(colnames(time.30min.df)=="23:30")

space.30min <- aggregate(time.30min.df[c(c.start:c.end)], list(time.30min.df$Appointment.Date),FUN = sum)
space.30min <- melt(space.30min, id=c("Group.1"))
space.30min.med <- aggregate(space.30min$value, list(space.30min$variable), FUN=median)

space.30min.70 <- aggregate(space.30min$value, list(space.30min$variable), FUN = function(x) quantile(x, probs = 0.70))
space.30min.90 <- aggregate(space.30min$value, list(space.30min$variable), FUN = function(x) quantile(x, probs = 0.90))

space.30min.med$percentile70 <- space.30min.70$x[match(space.30min.med$Group.1, space.30min.70$Group.1)]
space.30min.med$percentile90 <- space.30min.90$x[match(space.30min.med$Group.1, space.30min.90$Group.1)]

space.30min.med[,2:4] <- round(space.30min.med[,2:4]/60, 1)
names(space.30min.med) <- c("Time","Median","70th Percentile","90th Percentile")

space.30min.med <- melt(space.30min.med, id=c("Time"))

ggplot(space.30min.med, aes(x=Time, y=value, col=variable, group=variable))+
  geom_line(size=1)+
  scale_color_manual(values=c("deepskyblue","maroon1","midnightblue"))+
  ggtitle(label="Room Utilization by Time of Day",
          subtitle = "Based on scheduled appointment time and duration")+
  ylab("Room Count")+
  theme_bw()+
  theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
        plot.subtitle = element_text(hjust=0.5, size = 15, face = "italic"),
        legend.position = "top",
        legend.text = element_text(size="12"),
        legend.direction = "horizontal",
        legend.key.size = unit(1.0,"cm"),
        legend.title = element_blank(),
        axis.title = element_text(size="14"),
        axis.text = element_text(size="14"),
        axis.title.x = element_blank(),
        axis.title.y = element_text(margin = margin(r=5)),
        axis.text.x = element_text(angle = 90,hjust = 0.5, margin = margin(t=10)),
        axis.text.y = element_text(margin = margin(l=5, r=5)),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(size = 0.3, colour = "black"),
        plot.margin = margin(30,30,30,30))


# Average space utilization by time of day and day of week

## Utilization in hourly interval 

c.start <- which(colnames(time.hour.df)=="00:00")
c.end <- which(colnames(time.hour.df)=="23:00")

space.hour.day <- aggregate(time.hour.df[c(c.start:c.end)], list(time.hour.df$Appt.Day, time.hour.df$Appointment.Date),FUN = sum)
space.hour.day <- melt(space.hour.day, id=c("Group.1","Group.2"))
space.hour.day <- aggregate(space.hour.day$value, list(space.hour.day$Group.1,space.hour.day$variable), FUN=mean)

space.hour.day$x <- round(space.hour.day$x /60, 1)
names(space.hour.day) <- c("Day","Time","value")


ggplot(space.hour.day, aes(x=Time, y=value, col=Day, group=Day))+
  geom_line(size=1)+
  #scale_color_manual(values=c("deepskyblue","maroon1","midnightblue"))+
  ggtitle(label="Space Utilization by Time of Day and Day of Week",
          subtitle = "Based on scheduled appointment time and duration")+
  ylab("Room Count")+
  theme_bw()+
  theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
        plot.subtitle = element_text(hjust=0.5, size = 15, face = "italic"),
        legend.position = "top",
        legend.text = element_text(size="12"),
        legend.direction = "horizontal",
        legend.key.size = unit(1.0,"cm"),
        legend.title = element_blank(),
        axis.title = element_text(size="14"),
        axis.text = element_text(size="14"),
        axis.title.x = element_blank(),
        axis.title.y = element_text(margin = margin(r=5)),
        axis.text.x = element_text(angle = 90,hjust = 0.5, margin = margin(t=10)),
        axis.text.y = element_text(margin = margin(l=5, r=5)),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(size = 0.3, colour = "black"),
        plot.margin = margin(30,30,30,30))+
  guides(colour = guide_legend(nrow = 1))


## Utilization in 30-min interval

c.start <- which(colnames(time.30min.df)=="00:00")
c.end <- which(colnames(time.30min.df)=="23:30")

space.30min.day <- aggregate(time.30min.df[c(c.start:c.end)], list(time.30min.df$Appt.Day, time.30min.df$Appointment.Date),FUN = sum)
space.30min.day <- melt(space.30min.day, id=c("Group.1","Group.2"))
space.30min.day <- aggregate(space.30min.day$value, list(space.30min.day$Group.1,space.30min.day$variable), FUN=mean)

space.30min.day$x <- round(space.30min.day$x /60, 1)
names(space.30min.day) <- c("Day","Time","value")


ggplot(space.30min.day, aes(x=Time, y=value, col=Day, group=Day))+
  geom_line(size=1)+
  #scale_color_manual(values=c("deepskyblue","maroon1","midnightblue"))+
  ggtitle(label="Space Utilization by Time of Day and Day of Week",
          subtitle = "Based on scheduled appointment time and duration")+
  ylab("Room Count")+
  theme_bw()+
  theme(plot.title = element_text(hjust=0.5, face = "bold", size = 20),
        plot.subtitle = element_text(hjust=0.5, size = 15, face = "italic"),
        legend.position = "top",
        legend.text = element_text(size="12"),
        legend.direction = "horizontal",
        legend.key.size = unit(1.0,"cm"),
        legend.title = element_blank(),
        axis.title = element_text(size="14"),
        axis.text = element_text(size="14"),
        axis.title.x = element_blank(),
        axis.title.y = element_text(margin = margin(r=5)),
        axis.text.x = element_text(angle = 90,hjust = 0.5, margin = margin(t=10)),
        axis.text.y = element_text(margin = margin(l=5, r=5)),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(size = 0.3, colour = "black"),
        plot.margin = margin(30,30,30,30))+ 
  guides(colour = guide_legend(nrow = 1))





#### Chropleth
install.packages("zipcode")
library(zipcode)
library(maps)
library(viridis)
library(viridisLite)

install.packages("choroplethr")
install.packages("units")
library(choroplethr)
install.packages("choroplethrMaps")
library(choroplethrMaps)

install_github('arilamstein/choroplethrZip@v1.5.0')
library(choroplethrZip)

install.packages("mapproj")
library(mapproj)

data(df_pop_zip)
head(df_pop_zip)
zip_choropleth(df_pop_zip, state_zoom = "new york", title="Population of New York State by county") + coord_map()
zip_choropleth(df_pop_zip, county_zoom = 36061) + coord_map()


arrived.all$ZIP <- clean.zipcodes(arrived.all$ZIP)
arrived.zip <- aggregate(arrived.all$unique, by=list(arrived.all$ZIP), FUN=NROW)
names(arrived.zip) <- c("region","value")

zip_choropleth(arrived.zip, county_zoom = 36061)

library(choroplethrZip)

data(df_zip_demographics)
df_zip_demographics$value = df_zip_demographics$per_capita_income


arrived.all$ZIP <- clean.zipcodes(arrived.all$ZIP)
arrived.zip <- aggregate(arrived.all$unique, by=list(arrived.all$ZIP), FUN=NROW)
names(arrived.zip) <- c("region","value")

# New York City is comprised of 5 counties: Bronx, Kings (Brooklyn), New York (Manhattan),
# Queens, Richmond (Staten Island). Their numeric FIPS codes are:
nyc_fips = c(36005, 36047, 36061, 36081, 36085)

zip_choropleth(arrived.zip,
               num_colors = 1,
               title       = "Total Patient Volume across New York City",
               legend      = "Total Patient Count",
               county_zoom = nyc_fips)+
  scale_fill_continuous(name = "Patient Count", low = "darkseagreen1", high = "firebrick1", space = "Lab", na.value = "transparent", guide = "colourbar", limits=c(0,NA))


zipcode

patients.by.borough = arrived.zip %>%
  select(Borough = BOROUGH) %>%
  group_bu(Borough)%>%
  summarise(Count=n())



manhattan_fips = c(36061)
manhattan <- zip_choropleth(arrived.zip,
                 num_colors = 1,
                 title = "Total Patient Volume within Manhattan",
                 county_zoom = manhattan_fips)+
  scale_fill_continuous(name = "Patient Count", low = "darkseagreen1", high = "firebrick1", space = "Lab", na.value = "transparent", guide = "colourbar", limits=c(0,NA))

bronx_fips = c(36005)
bronx <- zip_choropleth(arrived.zip,
               num_colors = 1,
               title = "Total Patient Volume within Bronx",
               county_zoom = bronx_fips)+
  scale_fill_continuous(name = "Patient Count", low = "darkseagreen1", high = "firebrick1", space = "Lab", na.value = "transparent", guide = "colourbar", limits=c(0,NA))

brooklyn_fips = c(36047)
brooklyn <- zip_choropleth(arrived.zip,
               num_colors = 1,
               title = "Total Patient Volume within Brooklyn",
               county_zoom = brooklyn_fips)+
  scale_fill_continuous(name = "Patient Count", low = "darkseagreen1", high = "firebrick1", space = "Lab", na.value = "transparent", guide = "colourbar", limits=c(0,NA))

queens_fips = c(36081)
queens <- zip_choropleth(arrived.zip,
               num_colors = 1,
               title = "Total Patient Volume within Queens",
               county_zoom = queens_fips)+
  scale_fill_continuous(name = "Patient Count", low = "darkseagreen1", high = "firebrick1", space = "Lab", na.value = "transparent", guide = "colourbar", limits=c(0,NA))

staten_fips = c(36085)
staten <- zip_choropleth(arrived.zip,
               num_colors = 1,
               title = "Patient Volume within Staten Island",
               county_zoom = staten_fips)+
scale_fill_continuous(name = "Patient Count", low = "darkseagreen1", high = "firebrick1", space = "Lab", na.value = "transparent", guide = "colourbar", limits=c(0,NA))+
  theme(plot.title = element_text(hjust=0.5, face = "bold"))

a <- grid.arrange(bronx, brooklyn, queens, staten, ncol=2)
b<- grid.arrange(manhattan, a, ncol=2, widths=c(3,6))
grid.arrange(main=textGrob("Breakdown of Patient Population by Zip code",gp=gpar(fontsize=20,font=3), hjust=1.73), b, heights=c(1,9))
