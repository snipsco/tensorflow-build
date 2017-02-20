node('jenkins-slave-tensorflow') {
	stage('checkout') {
		checkout scm 
	}

	stage('build') {
		sh "./createDebNative.sh"
	}	

	stage('upload') {
		aws s3 cp target s3://snips/tensorflow-deb/ --recursive  --exclude * --include "*.deb"
	}

}
