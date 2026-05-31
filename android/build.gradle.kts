import org.gradle.api.tasks.wrapper.Wrapper

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.named<Wrapper>("wrapper") {
    gradleVersion = "8.13"
    distributionType = Wrapper.DistributionType.BIN
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
