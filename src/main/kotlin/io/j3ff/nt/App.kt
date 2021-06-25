package io.j3ff.nt

import edu.wpi.first.networktables.NetworkTableInstance


fun main() {
    println("pwd = ${System.getProperty("user.dir")}")

    val nt = NetworkTableInstance.getDefault().apply {
        setNetworkIdentity("Docker")
        addLogger({ println(it.message) }, 11, 100)
        startServer()
    }

    do {
        Thread.sleep(2500L)
    } while (true)
}
