pipeline {
	agent any

	environment {
		TERM = 'rxvt'
	}

	stages {
		stage('Test') {
			steps {
				sh 'echo "Hello World"'
				sh '''
					cd tests
					./test-suite.sh
				'''
			}
		}
	}
}
