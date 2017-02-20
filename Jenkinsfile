node('jenkins-slave-tensorflow') {
	stage('checkout') {
		checkout scm 
	}

	stage('build') {
		sh "./createDebNative.sh"
	}	

}
