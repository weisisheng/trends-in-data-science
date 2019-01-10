# trends-in-data-science
The objective of this project is to monitor the trends in data science job opportunities. We achieve this in three stages

1) Scraping jobserve.com 
2) Analyse job data 
3) Visualisation output


# Scraping jobserve.com

# First Build Dockerfile with R and required libraries installed (RSelenium). 

This shell script builds the Dockerfile called DockerfileAnalyse, which creates an image with R installed together with the required libraries 

```bash
./build-analyse.sh
```

Then in order to do the web-scraping we run

```bash
sudo docker-compose up --force-recreate -d
```

This starts two services 
1) A selenium server
2) Our R image created above

The above code has an entry point set to be 'entrypointScraping.R' which is found in the RCode directory. 
Setting the code as an entry point means that it gets run automatically when the service starts. 
Modifying "entrypointScraping.r" controls which search terms are send to the jobserve website.

This all happens automatically, but sometimes to debug it is useful to run the code ourselves interactively. To do this we instead run

```bash
sudo docker-compose -f docker-compose-interactive.yml up --force-recreate -d
```
Then navigate to 
* localhost:80 to view RStudio or
* localhost:4445 to view Selenium Browser

# Analyse Job Data

## Build Dockerfile

```bash
./build-analyse.sh
```

This builds an image with R configured with the necessary machine learning libraries to analyse the data

We then run the analysis automatically using

```bash
./launch-analysis.sh
```

or we can do it interactively as well, by first launching the image

```bash
./launch-analysis-interactive.sh
```

then navigating to the Rserver at the relevant ip address and running the code manually

# Visualising Output
TCS

# Required steps for Automation
In order to automate the web scraping process we do the following

1) Schedule Virtual Machine start up /shutdown 
2) Configure a cron job on linux host

## Schedule Virtual Machine start up/ shutdown
Follow instructures here
https://docs.microsoft.com/en-us/azure/automation/automation-solution-vm-management#modify-the-startup-and-shutdown-schedules

Set the machine to start at 12:00 AM and shutdown at 01:00 AM

## Configure a cron job on linux host

Bring up the crontab for users with root permissions (so we don't have to prefix commands with sudo)

```bash
sudo crontab -e
```

Then add the following line to the file.

```bash
10 00 * * * cd /home/d14xj1/repos/trends-in-data-science && docker-compose up -d --force-recreate
```

Then at 12:10 AM the job will run. The job first changes directory to the location of the docker file, and then runs docker-compose.
It was necessary to use the --force-recreate option, otherwise somethings the rstudio container doesn't always start.




