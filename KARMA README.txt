Running Karma for the very first time: 

	Download Web-Karma-Public-master from the Karma Github page. 
	Unzip and save to a directory that you can keep track of. 

	Check if the Maven and the Java JDK are installed. 
		- If Maven is installed, it should be in C:\Program Files\apache-maven-#.#.#
			where # represents current version number. 
		- Java JDK should be in C:\Program Files\Java\jdk#.#.#_##\
		
	Update environment variables. Add to SYSTEM variables (not user)
		MAVEN_HOME as your current directory where apache-maven is located\
		JAVA_HOME as your current directory where java-jdk is located
		
	Update PATH variable. 
		add "%MAVEN_HOME%\bin;%JAVA_HOME%\bin" to the end of path
		if not already there. 
		
	Open command prompt and move to directory where Web-Karma is located
		- the "cd DIRECTORY" command moves into DIRECTORY. 
		- the "dir" command lists all files and folders in current directory
		
	Run "mvn jetty:run", which should initialize the Karma web application
	Go to "localhost:8080/web-karma.html" to start Karma
	
DATABASE IMFORMATION
	To connect to the TMS database, use the following login information: 
	
		DB Type: SQL Server
		Host Name: bac5-prod
		Port: 1433
		User: dcp23
		Password: export23
		DB name: tms
		
		
		