import jenkins
import json
import os


host = "http://51.16.13.139:8080"
username = "admin"
password = "11d3b6aa2846cf748ccafd1fad86443cfe"


server = jenkins.Jenkins(host, username, password)

# Test the api communication
# user = server.get_whoami()
# version = server.get_version()
# print('Hello %s from Jenkis %s'%(version))


## Jobs 

# Create empty job
#server.create_job("job1", jenkins.EMPTY_CONFIG_XML)


# copy job1 to job2


# create a job and put it in a xml file
# job2_xml = open("job2.xml",mode="r", encoding="utf-8").read()
# server.create_job("job2", job2_xml)


# View jobs
# jobs = server.get_jobs()
# print(jobs)


# Get all jobs from the specific view
jobs = server.get_jobs(view_name='all')
# print jobs

# get the job config
# job1 = server.get_job_config('job1')
# print(job1)

# disable a job 
# server.disable_job('job1')

# enable disabled job
# server.enable_job('job1')


# delete a job
# server.delete_job('job1')
# server.delete_job('job2')


job_name = jobs[0]['name']
server.build_job(job_name)
job_number = server.get_job_info(job_name)['lastCompletedBuild']['number']

print(job_number)
print(f'Job {job_name} has been started!')

print(server.get_build_console_output(job_name, job_number))