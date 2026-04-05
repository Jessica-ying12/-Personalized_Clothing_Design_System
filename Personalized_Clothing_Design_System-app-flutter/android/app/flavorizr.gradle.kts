import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.explorex.camlink.dev"
            resValue(type = "string", name = "app_name", value = "LivHome Dev")
        }
        create("preview") {
            dimension = "flavor-type"
            applicationId = "com.explorex.camlink.preview"
            resValue(type = "string", name = "app_name", value = "LivHome Preview")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.explorex.camlink"
            resValue(type = "string", name = "app_name", value = "LivHome")
        }
    }
}