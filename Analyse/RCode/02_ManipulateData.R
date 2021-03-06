# 02_ManipulateData.R

# Purpose: Manipulate data as needed

# Contents:
#   0. Settings
#   1. Load data required
#   2. Change column names
#   3. Add Fold for partitioning 
#   4. Date Formatting
#   5. Unique identifier
#   6. Tools (Python vs R)
#   7. Grab Max Salary and clean data
#   8. Add London Flag
#   9. Remove redundant fields
#   10. Save results and gc()

# ----------------------------------------------------------
#  0. Settings

set.seed(2017)
nfolds <- 10

#---------------------------------------------------------------------
#  1. Load data required

dt_all <- readRDS(dt, file = file.path(dirRData, "01_dt_all.RData"))

#---------------------------------------------------------------------
#  2. Change column names

setnames(dt_all,
         old = c("jobResultsTitle",
                 "jobResultsSalary",
                 "jobResultsLoc",
                 "jobResultsType",
                 "jobpositionlink",
                 "skills",
                 "posted_date"),
         new = c("Title",
                 "Salary",
                 "Location",
                 "Type",
                 "Link",
                 "Skills",
                 "PostedDate"))

#---------------------------------------------------------------------
#  3. Add Fold for partitioning 

dt_all[,fold := sample(nfolds, size = nrow(dt_all), replace = TRUE)]

#---------------------------------------------------------------------
#  4. Date Formatting

dt_all[ ,PostedDate :=  as.POSIXct(dt_all$PostedDate, format="%d/%m/%Y %T", 'GMT')]

dt_all[, month:= as.Date(cut(PostedDate, breaks = "month"))]

#---------------------------------------------------------------------
#  5. Unique identifier

setorder(dt_all, 'PostedDate')
dt_all[,doc_id := 1:nrow(dt_all)]
setorder(dt_all, -'PostedDate')

#---------------------------------------------------------------------
#  6. Tools (Python vs R)

dt_all[, Python := grepl("[P|p]ython", Skills)]
dt_all[, R := grepl("R[ [:punct:]]", Skills)]
dt_all[,Python_R := paste(Python, R, sep = "_")]

dt_all[, Tools := ifelse(Python_R == "TRUE_TRUE", "Python or R",
                            ifelse(Python_R == "TRUE_FALSE", "Python but not R",
                                   ifelse(Python_R == "FALSE_TRUE", "R but not Python","Neither Language")))]

#---------------------------------------------------------------------
#  7. Grab Max Salary and clean data

# remove comma's so that 31,850 is treated as 31850 and can be detected as a whole word
dt_all[, Salary := gsub(',','',Salary)]

g <- gregexpr('[0-9]+',dt_all$Salary)

m <- regmatches(dt_all$Salary,g)

maxFun <- function(x){
  if (length(x)==0)
    return(NA)
  else 
    x %>% as.numeric() %>% max()
}

dt_all[,salaryMax := sapply(m, maxFun)] 

# convert all jobs to units of 1000
dt_all[, salaryMax:= ifelse(nchar(salaryMax)>=5, salaryMax/1000, salaryMax)]

# change job type to Contract if salary mentions a day rate
dt_all[grepl('[p|P]er [d|D]ay', dt_all$Salary), job_type := "Contract"]

# change job type to Permanent if salary mentions per year/annual salary
# '£17 - £18 per annum'
# '32816 - 40322 Annual GBP
dt_all[grepl('(annual|annum)', tolower(dt_all$Salary)), job_type := "Permanent"]

# change job type to Permanent if salary units in thousands
# '75k - 85k EUR'
dt_all[grepl('[0-9]+k', tolower(dt_all$Salary)), job_type := "Permanent"]

# Hourly contracts - assume 8 hour day
# 'Uxbridge - £35 - £40 Per Hour'
# '£60-70 p/h'
dt_all[grepl('[h|H]our', dt_all$Salary), salaryMax := salaryMax * 8]
dt_all[grepl('p/h', dt_all$Salary), salaryMax := salaryMax * 8]

# big day rates
# Salary salaryMax
# £400 - £5256 per Day
# London - £450 - £560 per hour
dt_all[job_type == "Contract" & salaryMax > 2500, salaryMax := salaryMax/10]

# big salarys
# Salary salaryMax
# £60k - £900k per annum + bonus benefits pension       900
dt_all[job_type == "Permanent" & salaryMax > 3000, salaryMax := salaryMax/100]
dt_all[job_type == "Permanent" & salaryMax > 330, salaryMax := salaryMax/10]

# zero salarys
# 'Up to £0.00 per annum'
dt_all[salaryMax <15, salaryMax := NA]

# Day rates incorrectly specified as 35 for 
#'Excellent outside IR35'
dt_all[job_type == "Contract" & salaryMax < 40, salaryMax := NA]


#---------------------------------------------------------------------
#  8. Add London Flag
dt_all[, London := grepl('london', tolower(dt_all$Location))]

table(dt_all$London)
#---------------------------------------------------------------------
#  9. Remove redundant fields

dt_all[,Type:= NULL]

#--------------------------------------------------------------
# 10. Save results and gc()

saveRDS(dt_all, file = file.path(dirRData, "02_dt_all.RData"))

cleanUp(functionNames)
gc()
