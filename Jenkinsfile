pipeline {
    agent { dockerfile true }
    stages {
        stage('Build Site') {
            steps {
                sh 'hugo'
            }
        }
      stage('Push to GCS') {
        when {
          branch 'master'
        }
        steps {
         step([$class: "ClassicUploadStep",
                credentialsId: "woven-computing-234012",
                bucket:"gs://www.harbur.io",
                pattern: "public/**",
                pathPrefix: "public/",
                showInline: true])
        }
      }
    }
}

