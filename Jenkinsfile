@NonCPS
def mapToList(depmap) {
	def dlist = []
	for (def entry2 in depmap) {
		dlist.add(new java.util.AbstractMap.SimpleImmutableEntry(entry2.key, entry2.value))
	}
	dlist
}

def cmds = [
	'x86_64':'./create-deb-native.sh',
	'armhf':'./create-deb-armhf.sh'
]
def builders = [:]
node {
	for ( def c in mapToList(cmds) ) {
		def label = "${c.key}"
		def cmd = "${c.value}"

		builders[label] = {

			node('jenkins-slave-tensorflow') {
				stage("checkout-${label}") {
					checkout scm 
				}

				stage("build-${label}") {
					sh "${cmd}"
				}	

				stage("upload-${label}") {
					sh 'aws s3 cp target/ s3://snips/tensorflow-deb/ --recursive  --exclude "*" --include "*.deb"'
				}

			}

		}
	}

	parallel builders
}
