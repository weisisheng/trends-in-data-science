# trends-in-data-science
The objective of this project is to monitor the trends in data science job opportunities. We achieve this through scraping of the jobserve website. 

# Build Dockerfile with R and required libraries installed

```bash
docker build -t tonyjward/rstudio .
```

We only need to do this once

# Docker Compose

We use docker compose to launch our two services (Selenium and RStudio Server)

```bash
docker-compose up -d
```

Then navigate to 
* localhost:80 to view RStudio or
* localhost:4445 to view Selenium Browser

# Automation
In order to automate the web scraping process we do the following

1) Schedule Virtual Machine start up /shutdown 
2) Configure a cron job on linux host

## Schedule Virtual Machine start up/ shutdown
Follow instructures here
https://docs.microsoft.com/en-us/azure/automation/automation-solution-vm-management#modify-the-startup-and-shutdown-schedules

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




