# Flutter Python Docker GitHub Actions Integration

## This project contains 
- A python script that can
  -  Pull a docker image from GitHub Container Registry and start it
  -  Stop a docker container given its id
- A test in flutter that
  - Runs the python script to boot up a mock web api image
  - Reads from the web api and prints it
  - Runs the python script again to stop the container
- A GitHub Actions workflow that sets up the environment and runs the flutter test.
